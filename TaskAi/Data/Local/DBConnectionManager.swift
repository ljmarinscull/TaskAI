//
//  DBConnectionManager.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//

import Foundation
import SQLite

final class DBConnectionManager {
   
   var connection: Connection = {
      let DB_NAME = "weather_database.sqlite3"
      let dbPath : String
      
      let docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
      
      dbPath = (docDir as NSString).appendingPathComponent(DB_NAME)
      
      return try! Connection(dbPath)
   }()
   
   init() {
      do {
         // if not, then create the table
         let statement = WeatherDataTable.table.create(ifNotExists: true) { t in
            t.column(WeatherDataTable.id, primaryKey: .autoincrement)
            t.column(WeatherDataTable.name)
            t.column(WeatherDataTable.weather)
            t.column(WeatherDataTable.temp)
            t.column(WeatherDataTable.humidity)
            t.column(WeatherDataTable.date)
         }
         try connection.run(statement)
      } catch {
         // show error message if any
         print(error.localizedDescription)
      }
   }
}
