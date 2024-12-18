//
//  TaskAiTests.swift
//  TaskAiTests
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//

import XCTest
@testable import TaskAi

public enum HTTPClientResult {
   case success(Data, HTTPURLResponse)
   case failure(Error)
}

public protocol HTTPClient {
   func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}


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

public enum RequestResult {
   case success(RequestResponse)
   case failure(Error)
}

protocol ApiService {
   func request(completion: @escaping (RequestResult) -> Void)
}

class RemoteApiService: ApiService {
   let url: URL
   let client: HTTPClient
   
   public enum Error: Swift.Error {
      case connectivity
      case invalidData
   }
   
   public typealias Result = RequestResult
   
   init (url: URL, client: HTTPClient) {
      self.url = url
      self.client = client
   }

   func request(completion: @escaping (Result) -> Void){
         client.get(from: url){ result in
            switch result {
            case let .success(data, response):
               completion(RequestMapper.map(data, and: response))
            case .failure:
               completion(.failure(Error.connectivity))
            }
         }
   }
}

fileprivate class RequestMapper {
   private static let OK_STATUS_CODE = 200

   private init() {}

   struct Root: Codable {
       let coord: CoordKeys
       let weather: [WeatherKeys]
       let base: String
       let main: MainKeys
       let visibility: Int
       let wind: WindKeys
       let clouds: Clouds
       let dt: Int
       let sys: SysKeys
       let timezone, id: Int
       let name: String
       let cod: Int
      
      var requestResponse: RequestResponse{
         RequestResponse(
            id: id,
            coordinate: .init(lat: coord.lat, lon: coord.lon),
            weather: weather.map{ $0.main }.joined(separator: ", "),
            main: .init(temp: main.temp, feelsLike: main.feelsLike, tempMin: main.tempMin, tempMax: main.tempMax, pressure: main.pressure, humidity: main.humidity),
            wind: .init(speed: wind.speed, deg: wind.deg),
            clouds: .init(all: clouds.all),
            dt: dt,
            name: name
         )
      }
   }

   struct Clouds: Codable {
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
      guard response.statusCode == OK_STATUS_CODE,
         let root = try? JSONDecoder().decode(Root.self, from: data) else {
         return .failure(RemoteApiService.Error.invalidData)
      }

      return .success(root.requestResponse)
   }
}

class RemoteRequestUseCaseTests: XCTestCase {

   func test_init_doesNotRequestDataFromURL() {
      let (_, client) = makeSUT()

      XCTAssertTrue(client.requestedURLs.isEmpty)
   }
   
   func test_requestTwice_requestsDataFromURLTwice() {
      let url = URL(string: "https://a-given-url.com")!
      let (sut, client) = makeSUT(url: url)
   
      sut.request { _ in }
      sut.request { _ in }
   
      XCTAssertEqual(client.requestedURLs, [url, url])
   }
   
   func test_request_deliversConnectivityErrorOnClientError() {
      let (sut, client) = makeSUT()

      expect(sut, toCompleteWith: .failure(.connectivity), when: {
         let clientError = NSError(domain: "Test", code: 0)
         client.complete(with: clientError)
      })
   }
   
   func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
      let (sut, client) = makeSUT()

      let samples = [199, 201, 300, 400, 500]

      samples.enumerated().forEach { index, code in
         expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let json = makeItemsJSON(["latitide": "", "longitude": ""])
            client.complete(withStatusCode: code, data: json, at: index)
         })
      }
   }
   
   // MARK: - Helpers

   private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteApiService, client: HTTPClientSpy) {
      let client = HTTPClientSpy()
      let sut = RemoteApiService(url: url, client: client)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(client, file: file, line: line)
      return (sut, client)
   }
   
   private func makeItemsJSON(_ items: [String: Any]) -> Data {
      let json: [String : Any] = [
         "coord": items,
         "weather": [
                "id": 701,
                "main": "Mist",
                "description": "mist",
                "icon": "50n"
            ],
            "base": "stations",
            "main":[
                "temp": 56.77,
                "feels_like": 56.84,
                "temp_min": 55.98,
                "temp_max": 58.95,
                "pressure": 1023,
                "humidity": 100,
                "sea_level": 1023,
                "grnd_level": 1021
            ],
            "visibility": 4828,
            "wind": [
                "speed": 0,
                "deg": 0
            ],
            "clouds": [
                "all": 100
            ],
            "dt": 1734525847,
            "sys": [
                "type": 2,
                "id": 2015175,
                "country": "US",
                "sunrise": 1734526075,
                "sunset": 1734562722
            ],
            "timezone": -21600,
            "id": 4429197,
            "name": "Landon",
            "cod": 200
      ]
      return try! JSONSerialization.data(withJSONObject: json)
   }
}
