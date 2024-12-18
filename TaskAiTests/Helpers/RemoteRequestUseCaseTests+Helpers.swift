//
//  RemoteRequestUseCaseTests.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//

import XCTest
import TaskAi

extension RemoteRequestUseCaseTests {
   func expect(_ sut: RemoteApiService, toCompleteWith expectedResult: RequestResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
      let exp = expectation(description: "Wait for load completion")

      sut.request { receivedResult in
         switch (receivedResult, expectedResult) {
         case let (.success(receivedItems), .success(expectedItems)):
            XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

         case let (.failure(receivedError), .failure(expectedError)):
            XCTAssertEqual(receivedError as! RemoteApiService.Error, expectedError as! RemoteApiService.Error, file: file, line: line)

         default:
            XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
         }

         exp.fulfill()
      }

      action()

      waitForExpectations(timeout: 0.1)
   }
}
