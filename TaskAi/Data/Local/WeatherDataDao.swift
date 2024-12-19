//
//  WeatherDataDao.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//
import Foundation
import SQLite

final class WeatherDataDao: DataStoreService {
   let connection: Connection
   
   var queue: DispatchQueue = {
      return DispatchQueue(label: "com.lj.TaskAi.WeatherDataDao")
   }()
   
   init(connection: Connection) {
      self.connection = connection
   }
   
   func load(completion: @escaping (LoadResquestResult) -> Void) {
      perform{ db, queue in
         queue.sync {
            do {
               let result = try db.prepare(WeatherDataTable.table)
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "M/d/yyyy h:mm:ss a"
               
               let items = result.map{
                  WeatherDataDao.map(
                     fromRow: $0,
                     formatter: dateFormatter.string
                  )
               }
               
               if items.isEmpty {
                  completion(.empty)
               }
               completion(.found(items))
            } catch {
               completion(.failure(error))
            }
         }
      }
   }
   
   func insert(data toInsert: LocalWeatherData, date: Date, completion: @escaping (Error?) -> Void) {
      perform{ [unowned self] db, queue in
         queue.sync {
            do {
               try db.run(WeatherDataTable.table.insert(self.generateSetters(fromWeatherData: toInsert, and: date)))
               completion(nil)
            } catch {
               completion(error)
            }
         }
      }
   }
   
   private func generateSetters(fromWeatherData item: LocalWeatherData, and date: Date) -> [Setter] {
      [
         WeatherDataTable.weather <- item.weather,
         WeatherDataTable.name <- item.name,
         WeatherDataTable.temp <- item.temp,
         WeatherDataTable.date <- date,
         WeatherDataTable.humidity <- item.humidity
      ]
   }
   
   
   private static func map(fromRow item: Row, formatter: (Date)-> String) -> WeatherData {
      WeatherData(
         id: item[WeatherDataTable.id],
         name: item[WeatherDataTable.name],
         weather: item[WeatherDataTable.weather],
         temp: item[WeatherDataTable.temp],
         humidity: item[WeatherDataTable.humidity],
         date: formatter(item[WeatherDataTable.date])
      )
   }
   
   private func perform(action: @escaping (Connection, DispatchQueue) -> Void){
      action(connection, queue)
   }
}
