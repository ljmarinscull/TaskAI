//
//  DataStoreService.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//
import Foundation

public enum LoadResquestResult{
   case found([WeatherData])
   case empty
   case failure(Error)
}

public protocol DataStoreService {
   
   typealias InsertCompletion = (Error?) -> Void
   typealias RetrieveCompletion = (Error?) -> Void
   
   func insert(data: LocalWeatherData, date: Date, completion: @escaping (Error?) -> Void)
   func load(completion: @escaping (LoadResquestResult) -> Void)
}
