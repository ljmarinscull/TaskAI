//
//  ApiServiceStub.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//

import Foundation
import XCTest
@testable import TaskAi

class ApiServiceStub: ApiService {

   private var messages = [(index: Int, completion: (RequestResult) -> Void)]()
   private var callCounter = 0
   
   var requestedURLs: [Int] {
      return messages.map { $0.index }
   }
   
   func request(completion: @escaping (RequestResult) -> Void) {
      messages.append((index: callCounter, completion: completion))
      callCounter += 1
   }
   
   func complete(with error: Error, at index: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
      guard messages.count > index else {
         return XCTFail("Can't complete request never made", file: file, line: line)
      }

      messages[index].completion(.failure(error))
   }

   func complete(with response: LocalWeatherData, at index: Int = 0, file: StaticString = #filePath, line: UInt = #line) {
      guard requestedURLs.count > index else {
         return XCTFail("Can't complete request never made", file: file, line: line)
      }

      messages[index].completion(.success(response))
   }
}
