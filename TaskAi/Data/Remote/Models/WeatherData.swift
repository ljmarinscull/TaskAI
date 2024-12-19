//
//  RequestResponse.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//
import Foundation

public struct Coordinate: Equatable {
   let latitude: Double
   let longitude: Double
}

public struct WeatherData: Identifiable, Equatable {
   public let id: Int
   let name: String
   let weather: String
   let temp: Double
   let humidity: Int
   let date: String
}

public struct LocalWeatherData: Equatable {
   let name: String
   let latitude: Double
   let longitude: Double
   let weather: String
   let temp: Double
   let humidity: Int
}

