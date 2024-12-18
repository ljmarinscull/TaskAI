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
   
   func onEvent(_ event: MainViewEvent) {
      switch event {
      case .showTab(let tab):
         state.currectTab = tab
      default: break
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
