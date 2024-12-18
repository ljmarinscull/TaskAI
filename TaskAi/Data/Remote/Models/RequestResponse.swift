//
//  RequestResponse.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//
import Foundation

public struct RequestResponse: Equatable {
   let id: Int
   let coordinate: Coordinate
   let weather: String
   let main: Main
   let wind: Wind
   let clouds: Clouds
   let dt: Int
   let name: String
}

struct Clouds: Equatable {
   let all: Int
}

struct Coordinate: Equatable {
   let longitude: Double
   let latitude: Double
   
   init(lat: Double, lon: Double) {
      latitude = lat
      longitude = lon
   }
}

struct Main: Equatable {
   let temp, feelsLike, tempMin, tempMax: Double
   let pressure, humidity: Int
   
   init(temp: Double, feelsLike: Double, tempMin: Double, tempMax: Double, pressure: Int, humidity: Int) {
      self.temp = temp
      self.feelsLike = feelsLike
      self.tempMin = tempMin
      self.tempMax = tempMax
      self.pressure = pressure
      self.humidity = humidity
   }
}

struct Sys: Equatable {
   let type, id: Int
   let country: String
   let sunrise, sunset: Int
}

struct Weather: Equatable {
   let id: Int
   let main, description, icon: String
}

struct Wind: Equatable {
   let speed, deg: Int
}
