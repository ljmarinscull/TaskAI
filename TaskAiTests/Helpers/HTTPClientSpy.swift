//
//  HTTPClientSpy.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//
import Foundation
import XCTest
import TaskAi

class HTTPClientSpy: HTTPClient {
   private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

   var requestedURLs: [URL] {
      return messages.map { $0.url }
   }

   func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
      messages.append((url, completion))
   }
   
   func post(from url: URLRequest, completion: @escaping (HTTPClientResult) -> Void) {
      messages.append((url.url!, completion))
   }

   func complete(with error: Error, at index: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
      guard messages.count > index else {
         return XCTFail("Can't complete request never made", file: file, line: line)
      }

      messages[index].completion(.failure(error))
   }

   func complete(withStatusCode code: Int, data: Data, at index: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
      guard requestedURLs.count > index else {
         return XCTFail("Can't complete request never made", file: file, line: line)
      }

      let response = HTTPURLResponse(
         url: requestedURLs[index],
         statusCode: code,
         httpVersion: nil,
         headerFields: nil
      )!

      messages[index].completion(.success(data, response))
   }
}
