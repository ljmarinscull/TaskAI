//
//  MainViewModelTests.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//

import XCTest
@testable import TaskAi

class MainViewModelTests: XCTestCase {
   
   @MainActor func test_init_verifyInitialState() {
      let (sut, _, _) = makeSUT()
      
      XCTAssertEqual(sut.state.currentMarker, makeInitialCoordinateMarkerData())
      XCTAssertEqual(sut.state.currentTab, Tab.map)
      XCTAssertEqual(sut.state.isLoading, false)
      XCTAssertEqual(sut.state.isRequesting, false)
      XCTAssertEqual(sut.state.requestRecordError, nil)
      XCTAssertEqual(sut.state.loadRecordError, nil)
      XCTAssertEqual(sut.state.weatherDataListState, .loading)
   }
   
   @MainActor func test_event_showTabEventUpdatesStateWithCurrentTab() {
      let (sut, _, _) = makeSUT()
      
      sut.onEvent(.showTab(Tab.map))
      XCTAssertEqual(sut.state.currentTab, Tab.map)
   }
   
   @MainActor func test_event_requestUpdatesStateWithResquestOn200HttpResponse() {
      let (sut, api, _) = makeSUT()
      let response = LocalWeatherData(
         name: "London",
         latitude: 20.000000,
         longitude: 21.000000,
         weather: "Windy",
         temp: 50,
         humidity: 30
      )
      
      sut.onEvent(.request)
      XCTAssertEqual(sut.state.isLoading, false)
      XCTAssertEqual(sut.state.isRequesting, true)
      XCTAssertEqual(sut.state.requestRecordError, nil)
      api.complete(with: response, at: 0)
      XCTAssertEqual(sut.state.isLoading, false)
      XCTAssertEqual(sut.state.isRequesting, false)
      XCTAssertEqual(sut.state.requestRecordError, nil)
   }
   
   @MainActor func test_event_requestDoesNotUpdatesStateWithResquestOnFailureHttpResponse() {
      let (sut, api, _) = makeSUT()
      
      sut.onEvent(.request)
      XCTAssertEqual(sut.state.requestRecordError, nil)
      api.complete(with: RemoteApiService.Error.connectivity)
      XCTAssertNotNil(sut.state.requestRecordError)
      XCTAssertEqual(sut.state.currentMarker, makeInitialCoordinateMarkerData())
   }
   
   @MainActor func test_event_requestTwiceOnlyMakesAApiResquestAtTime() {
      let (sut, api, _) = makeSUT()
      
      sut.onEvent(.request)
      sut.onEvent(.request)
      XCTAssertEqual(api.requestedURLs.count, 1)
   }
   
   @MainActor func test_event_requestOnSuccessApiResponseMakesAInsertionCall() {
      let (sut, api, dao) = makeSUT()
      
      let response = LocalWeatherData(
         name: "London",
         latitude: 20.000000,
         longitude: 21.000000,
         weather: "Windy",
         temp: 50,
         humidity: 30
      )
      
      sut.onEvent(.request)
      api.complete(with: response, at: 0)

      XCTAssertEqual(dao.insertCallCount, 1)
   }
   
   @MainActor func test_event_requestOnErrorApiResponseDoesNotMakesAInsertionCall() {
      let (sut, api, dao) = makeSUT()
      
      sut.onEvent(.request)
      api.complete(with: RemoteApiService.Error.connectivity)
      XCTAssertEqual(dao.insertCallCount, 0)
   }
   
   @MainActor func test_event_loadRecordsMakesACallToRetrieveRecords() {
      let (sut, _, dao) = makeSUT()
      
      sut.onEvent(.loadRecords)
      XCTAssertEqual(dao.loadCallCount, 1)
   }
   
   // MARK: - Helpers
   
   @MainActor private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: MainViewModel, apiServiceStub: ApiServiceStub, weatherDataDao: WeatherDataDaoStub) {
      let weatherDataDao = WeatherDataDaoStub()
      let apiServiceStub = ApiServiceStub()
      let sut = MainViewModel(apiService: apiServiceStub, weatherDataDao: weatherDataDao)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(weatherDataDao, file: file, line: line)
      trackForMemoryLeaks(apiServiceStub, file: file, line: line)
      return (sut, apiServiceStub, weatherDataDao)
   }
   
   private func makeInitialCoordinateMarkerData() -> CoordinateMarkerData {
      CoordinateMarkerData(name: "Mexico City", coordinate: .init(latitude: 19.451054, longitude: -99.125519))
   }
   
}
