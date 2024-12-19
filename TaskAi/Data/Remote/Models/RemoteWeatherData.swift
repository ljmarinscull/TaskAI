//
//  RemoteWeatherData.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//
import Foundation

public struct RemoteWeatherData: Codable {
   let id: Int
   let coord: CoordKeys
   let weather: [WeatherKeys]
   let base: String
   let main: MainKeys
   let visibility: Int
   let wind: WindKeys
   let clouds: CloudsKeys
   let dt: Int
   let sys: SysKeys
   let timezone: Int
   let name: String
   let cod: Int
}

extension RemoteWeatherData {
   var toLocal: LocalWeatherData{
      LocalWeatherData(
         name: name,
         latitude: coord.lat,
         longitude: coord.lon,
         weather: weather.map{ $0.main }.joined(separator: ", "),
         temp: main.temp,
         humidity: main.humidity
      )
   }
}

struct CloudsKeys: Codable {
   let all: Int
}

struct CoordKeys: Codable {
   let lon, lat: Double
}

struct MainKeys: Codable {
   let temp, feelsLike, tempMin, tempMax: Double
   let pressure, humidity, seaLevel, grndLevel: Int
   
   enum CodingKeys: String, CodingKey {
      case temp
      case feelsLike = "feels_like"
      case tempMin = "temp_min"
      case tempMax = "temp_max"
      case pressure, humidity
      case seaLevel = "sea_level"
      case grndLevel = "grnd_level"
   }
}

struct SysKeys: Codable {
   let type, id: Int
   let country: String
   let sunrise, sunset: Int
}

struct WeatherKeys: Codable {
   let id: Int
   let main, description, icon: String
}

struct WindKeys: Codable {
   let deg: Int
   let speed: Double
}
