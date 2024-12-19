//
//  DataStoreService.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//

import Foundation
@testable import TaskAi

class DataStoreServiceStub: DataStoreService {
   
   func insert(data: LocalWeatherData, date: Date, completion: @escaping ((any Error)?) -> Void) {
      
   }
   
   func load(completion: @escaping (TaskAi.LoadResquestResult) -> Void) {
      
   }
}
