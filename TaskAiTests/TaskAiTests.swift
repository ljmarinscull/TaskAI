//
//  TaskAiTests.swift
//  TaskAiTests
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//

import XCTest
@testable import TaskAi

public enum HTTPClientResult {
   case success(Data, HTTPURLResponse)
   case failure(Error)
}

public protocol HTTPClient {
   func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

class RemoteApiService: ApiService {
   let url: URL
   let client: HTTPClient
   
   init (url: URL, client: HTTPClient) {
      self.url = url
      self.client = client
   }

   func request(completion: @escaping (Result<Response, Error>) -> Void){
         client.get(from: url){ result in
         }
   }
}

class RemoteRequestUseCaseTests: XCTestCase {

   func test_init_doesNotRequestDataFromURL() {
      let (_, client) = makeSUT()

      XCTAssertTrue(client.requestedURLs.isEmpty)
   }
   
   func test_requestTwice_requestsDataFromURLTwice() {
      let url = URL(string: "https://a-given-url.com")!
      let (sut, client) = makeSUT(url: url)
   
      sut.request { _ in }
      sut.request { _ in }
   
      XCTAssertEqual(client.requestedURLs, [url, url])
   }
   
   // MARK: - Helpers

   private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteApiService, client: HTTPClientSpy) {
      let client = HTTPClientSpy()
      let sut = RemoteApiService(url: url, client: client)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(client, file: file, line: line)
      return (sut, client)
   }
}
