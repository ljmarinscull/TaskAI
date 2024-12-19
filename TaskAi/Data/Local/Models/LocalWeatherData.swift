//
//  LocalWeatherData.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//
import Foundation

public struct LocalWeatherData: Equatable {
   let name: String
   let latitude: Double
   let longitude: Double
   let weather: String
   let temp: Double
   let humidity: Int
}
