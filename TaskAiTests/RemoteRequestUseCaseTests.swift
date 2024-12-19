//
//  RemoteRequestUseCaseTests.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//

import XCTest
@testable import TaskAi

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
      
      expect(sut, toCompleteWith: failure(.connectivity), when: {
         let clientError = NSError(domain: "Test", code: 0)
         client.complete(with: clientError)
      })
   }
   
   func test_register_deliversInvalidDataErrorOnNon200HTTPResponse() {
      let (sut, client) = makeSUT()
      
      let samples = [199, 201, 300, 400, 500]
      
      samples.enumerated().forEach { index, code in
         expect(sut, toCompleteWith: failure(.invalidRequest), when: {
            let json = makeResponseJSONWith([:])
            client.complete(withStatusCode: code, data: json, at: index)
         })
      }
   }
   
   func test_register_deliversInvalidDataErrorOn200HTTPResponseWithInvalidJSON() {
      let (sut, client) = makeSUT()
      
      expect(sut, toCompleteWith: failure(.invalidData), when: {
         let invalidJSON = Data("invalid json".utf8)
         client.complete(withStatusCode: 200, data: invalidJSON)
      })
   }
   
   func test_register_deliversInvalidDataErrorOn200HTTPResponseWithPartiallyValidJSON() {
      let (sut, client) = makeSUT()
      
      expect(sut, toCompleteWith: failure(.invalidData), when: {
         let json = makeResponseJSONWith(["invalid key": 0.0, "lon": 0.0])
         client.complete(withStatusCode: 200, data: json)
      })
   }
   
   func test_register_deliversSuccessResponseOn200HTTPResponseWithJSON() {
      let (sut, client) = makeSUT()
      
      let (model, json) = makeItemsFullJSON(
         coord: ["lat" : 12.3456789, "lon" : 98.7654321],
         weather: [
            makeWeather(id: 1, main: "Windy", description: "windy", icon: "wind")
         ],
         base: "stations",
         main: makeMain(),
         visibility: 1.0,
         wind: [
            "speed": 10,
            "deg": 45
         ],
         clouds: ["all": 100],
         dt: 819128,
         sys: [
            "type": 2,
            "id": 2015175,
            "country": "US",
            "sunrise": 1734526075,
            "sunset": 1734562722
         ],
         timezone: -12829,
         name: "Mexico",
         id: 1
      )

      expect(sut, toCompleteWith: .success(model), when: {
         client.complete(withStatusCode: 200, data: convertResponseJSONToData(json))
      })
   }
   
   func test_register_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
      let url = URL(string: "http://any-url.com")!
      let client = HTTPClientSpy()
      var sut: ApiService? = RemoteApiService(url: url, client: client)
      
      var capturedResults = [RemoteApiService.Result]()
      sut?.request{ capturedResults.append($0) }
      
      sut = nil
      client.complete(withStatusCode: 200, data: makeResponseJSONWith([:]))
      
      XCTAssertTrue(capturedResults.isEmpty)
   }
   
   // MARK: - Helpers
   
   private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteApiService, client: HTTPClientSpy) {
      let client = HTTPClientSpy()
      let sut = RemoteApiService(url: url, client: client)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(client, file: file, line: line)
      return (sut, client)
   }
   
   private func failure(_ error: RemoteApiService.Error) -> RemoteApiService.Result {
      .failure(error)
   }
   
   private func makeMain() -> [String: Any] {
      [
         "temp": 56.77,
         "feels_like": 56.84,
         "temp_min": 55.98,
         "temp_max": 58.95,
         "pressure": 1023,
         "humidity": 100,
         "sea_level": 1023,
         "grnd_level": 1021
      ]
   }
   
   private func makeWeather(id: Int, main: String, description: String, icon: String) -> [String: Any] {
      [
         "id": id,
         "main": main,
         "description": description,
         "icon": icon
      ]
   }
   
   private func makeItemsFullJSON(
      coord: [String: Any],
      weather: [[String: Any]],
      base: String,
      main: [String:Any],
      visibility: Double,
      wind: [String: Any],
      clouds: [String: Any],
      dt: Int,
      sys: [String: Any],
      timezone: Int,
      name: String,
      id: Int
   ) -> (model: LocalWeatherData, json: [String: Any]) {
      
      let weatherStr = weather.map{
         $0["main"] as! String
      }.joined(separator: ", ")
      
      let model = LocalWeatherData(
         name: name,
         latitude: coord["lat"] as! Double,
         longitude: coord["lon"] as! Double,
         weather: weatherStr,
         temp: main["temp"] as! Double,
         humidity: main["humidity"] as! Int
      )
      
      let json: [String: Any] =
      [
         "coord": coord,
         "weather": weather,
         "base": "stations",
         "main": main,
         "visibility": 482,
         "wind": wind,
         "clouds": clouds,
         "dt": dt,
         "sys": sys,
         "timezone": timezone,
         "id": id,
         "name": name,
         "cod": 200
      ]
      return (model: model, json: json)
   }
   
   private func convertResponseJSONToData(_ json: [String: Any]) -> Data {
      return try! JSONSerialization.data(withJSONObject: json)
   }
   
   private func makeResponseJSONWith(_ items: [String: Any]) -> Data {
      let json: [String : Any] = [
         "coord": items,
         "weather": [[
            "id": 701,
            "main": "Mist",
            "description": "mist",
            "icon": "50n"
         ]],
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
