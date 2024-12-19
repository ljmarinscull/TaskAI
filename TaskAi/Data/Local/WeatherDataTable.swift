//
//  WeatherData.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//
import Foundation
import SQLite

final class WeatherDataTable {
   static let table = Table("weather_data_table")
   
   static let id = SQLite.Expression<Int>("id")
   static let weather = SQLite.Expression<String>("weather")
   static let name = SQLite.Expression<String>("name")
   static let temp = SQLite.Expression<Double>("temp")
   static let humidity = SQLite.Expression<Int>("humidity")
   static let date = SQLite.Expression<Date>("date")
}
