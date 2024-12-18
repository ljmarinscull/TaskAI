//
//  MainViewModelTests.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//

import XCTest
@testable import TaskAi

enum Tab: Equatable {
   case map, list
}

enum MainViewEvent {
   case showTab(Tab), request, loadRecords
}

struct MainState {
   var requests: [RequestResponse] = []
   var currentRequest: RequestResponse? = nil
   var currentCoordinate: Coordinate = .init(latitude: 19.451054, longitude: -99.125519)// Mexico City Coordinates
   var currectTab: Tab = .map
   var isLoading: Bool = false
   var requestRecordError: String? = nil
   var loadRecordError: String? = nil
}

enum LoadResquestResult{
   case success([RequestResponse])
   case failure(Error)
}

protocol DataStoreService{
   func save(record: RequestResponse)
   func loadAllRequestResponse(completion: @escaping (LoadResquestResult) -> Void)
}

@Observable
final class MainViewModel {
      var state: MainState = .init()
   
      private let apiService: ApiService
      private let localDataStore: DataStoreService
   
      init(apiService: ApiService, localDataStore: DataStoreService) {
         self.apiService = apiService
         self.localDataStore = localDataStore
      }
   
   @MainActor
   func onEvent(_ event: MainViewEvent) {
      switch event {
      case .showTab(let tab):
         state.currectTab = tab
      case .request:
         makeRequest()
      default: break
      }
   }
   
      @MainActor
      private func makeRequest() {
         state.isLoading = true
         state.requestRecordError = nil
         apiService.request{[weak self] result in
            guard let self else { return }
            state.isLoading = false
            switch result {
            case  .success(let response):
               state.currentRequest = response
            case .failure(let error):
               state.requestRecordError = error.localizedDescription
            }
         }
      }
}

class MainViewModelTests: XCTestCase {
   
   @MainActor func test_init_verifyInitialState() {
      let (sut, _, _) = makeSUT()
   
      XCTAssertEqual(sut.state.requests, [])
      XCTAssertEqual(sut.state.currentRequest, nil)
      XCTAssertEqual(sut.state.currentCoordinate, .init(latitude: 19.451054, longitude: -99.125519))
      XCTAssertEqual(sut.state.currectTab, Tab.map)
      XCTAssertEqual(sut.state.isLoading, false)
      XCTAssertEqual(sut.state.requestRecordError, nil)
      XCTAssertEqual(sut.state.loadRecordError, nil)
   }
   
   
   @MainActor func test_event_showTabEventUpdatesStateWithCurrentTab() {
      let (sut, _, _) = makeSUT()
      
      sut.onEvent(.showTab(Tab.map))
      XCTAssertEqual(sut.state.currectTab, Tab.map)
   }
   
   @MainActor func test_event_requestUpdatesStateWithResquestOn200HttpResponse() {
      let (sut, api, _) = makeSUT()
      let response = RequestResponse(
         id: 1,
         coordinate: Coordinate(latitude: 51.509, longitude: -0.12),
         weather: "Windy",
         main: Main(temp: 10.0, feelsLike: 9.0, tempMin: 5.0, tempMax: 12.0, pressure: 30, humidity: 50),
         wind: Wind(speed: 10, deg: 10),
         clouds: Clouds(all: 100),
         dt: 121221,
         name: "London"
      )
      
      sut.onEvent(.request)
      api.complete(with: response, at: 0)
      XCTAssertEqual(sut.state.currentRequest, response)
   }

   
   // MARK: - Helpers

   @MainActor private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: MainViewModel, apiServiceStub: ApiServiceStub, localDataStoreStub: DataStoreServiceStub) {
      let localDataStoreStub = DataStoreServiceStub()
      let apiServiceStub = ApiServiceStub()
      let sut = MainViewModel(apiService: apiServiceStub, localDataStore: localDataStoreStub)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(localDataStoreStub, file: file, line: line)
      trackForMemoryLeaks(apiServiceStub, file: file, line: line)
      return (sut, apiServiceStub, localDataStoreStub)
   }
}
