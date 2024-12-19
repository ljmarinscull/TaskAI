//
//  WeatherDataDaoStub.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//

import Foundation
@testable import TaskAi

class WeatherDataDaoStub: DataStoreService {
   
   var insertCallCount: Int = 0
   var loadCallCount: Int = 0
   
   func insert(data: LocalWeatherData, date: Date, completion: @escaping ((any Error)?) -> Void) {
      insertCallCount += 1
   }
   
   func load(completion: @escaping (LoadResquestResult) -> Void) {
      loadCallCount += 1
   }
}
