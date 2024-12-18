//
//  RemoteApiService.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//
import Foundation

public final class RemoteApiService: ApiService {
   private let url: URL
   private let client: HTTPClient
   
   public enum Error: Swift.Error {
      case connectivity
      case invalidRequest
      case invalidData
   }
   
   public typealias Result = RequestResult
   
   init (url: URL, client: HTTPClient) {
      self.url = url
      self.client = client
   }
   
   public func request(completion: @escaping (Result) -> Void){
      client.get(from: url){[weak self] result in
         guard self != nil else {
            return
         }
         
         switch result {
         case let .success(data, response):
            completion(RequestMapper.map(data, and: response))
         case .failure:
            completion(.failure(Error.connectivity))
         }
      }
   }
}

private class RequestMapper {
   private static let OK_STATUS_CODE = 200
   
   private init() {}
   
   struct Root: Codable {
      let coord: CoordKeys
      let weather: [WeatherKeys]
      let base: String
      let main: MainKeys
      let visibility: Int
      let wind: WindKeys
      let clouds: CloudsKeys
      let dt: Int
      let sys: SysKeys
      let timezone, id: Int
      let name: String
      let cod: Int
      
      var requestResponse: RequestResponse{
         RequestResponse(
            id: id,
            coordinate: Coordinate(lat: coord.lat, lon: coord.lon),
            weather: weather.map{ $0.main }.joined(separator: ", "),
            main: Main(temp: main.temp, feelsLike: main.feelsLike, tempMin: main.tempMin, tempMax: main.tempMax, pressure: main.pressure, humidity: main.humidity),
            wind: Wind(speed: wind.speed, deg: wind.deg),
            clouds: Clouds(all: clouds.all),
            dt: dt,
            name: name
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
      let speed, deg: Int
   }
   
   static func map(_ data: Data, and response: HTTPURLResponse) -> RequestResult {
      guard response.statusCode == OK_STATUS_CODE else {
         return .failure(RemoteApiService.Error.invalidRequest)
      }
      
      guard let root = try? JSONDecoder().decode(Root.self, from: data) else {
         return .failure(RemoteApiService.Error.invalidData)
      }
      
      return .success(root.requestResponse)
   }
}
