//
//  RemoteApiService.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//
import Foundation

public final class RemoteApiService: ApiService {
   private let API_KEY = "ebc04bcc90msh3843ce42ca972a9p14020djsn250387630867"
   private let HOST = "open-weather13.p.rapidapi.com"
   
   private let url: URL
   private let client: HTTPClient
   
   public enum Error: Swift.Error {
      case connectivity
      case invalidRequest
      case invalidData
   }
   
   public typealias Result = RequestResult
   
   init(url: URL, client: HTTPClient) {
      self.url = url
      self.client = client
   }
   
   public func request(completion: @escaping (Result) -> Void){
      var request = URLRequest(url: url)
      request.httpMethod = "GET"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
      request.setValue(API_KEY, forHTTPHeaderField: "x-rapidapi-key")
      request.setValue(HOST, forHTTPHeaderField: "x-rapidapi-host")
      
      client.get(from: request){[weak self] result in
         guard self != nil else {
            return
         }
         
         switch result {
         case let .success(data, response):
            completion(RemoteApiService.map(data, and: response))
         case .failure:
            completion(.failure(Error.connectivity))
         }
      }
   }
   
   private static func map(_ data: Data, and response: HTTPURLResponse) -> Result {
      do {
         let data = try WeatherDataMapper.map(data, and: response)
         return .success(data.toLocal)
      } catch {
         return .failure(error)
      }
   }
}

private class WeatherDataMapper {
   private static let OK_STATUS_CODE = 200
   
   private init() {}
   
   static func map(_ data: Data, and response: HTTPURLResponse) throws -> RemoteWeatherData {
      guard response.statusCode == OK_STATUS_CODE else {
         throw RemoteApiService.Error.invalidRequest
      }
      
      guard let root = try? JSONDecoder().decode(RemoteWeatherData.self, from: data) else {
         throw RemoteApiService.Error.invalidData
      }
      
      return root
   }
}
