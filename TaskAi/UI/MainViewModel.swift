//
//  MainViewModel.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//

import Foundation
import Observation

public enum Tab: Equatable {
   case map, list
}

enum WeatherDataListState: Equatable {
   case loading, loaded([WeatherData]), error
}

public enum MainViewEvent {
   case showTab(Tab), request, loadRecords
}

struct CoordinateMarkerData: Equatable {
   let name: String
   let coordinate: Coordinate
}

public struct MainState {
   var weatherDataListState: WeatherDataListState = .loading
   var currentMarker: CoordinateMarkerData = .init(name: "Mexico City", coordinate: .init(latitude: 19.451054, longitude: -99.125519))// Mexico City Coordinates
   var currectTab: Tab = .list
   var isLoading: Bool = false
   var isRequesting: Bool = false
   var requestRecordError: String? = nil
   var loadRecordError: String? = nil
}

extension MainState {
   func copy(
      listState: WeatherDataListState? = nil,
      currentMarker: CoordinateMarkerData? = nil,
      currectTab: Tab? = nil,
      isLoading: Bool? = nil,
      isRequesting: Bool? = nil,
      requestRecordError: String? = nil,
      loadRecordError: String? = nil
   ) -> Self {
      .init(
         weatherDataListState: listState ?? self.weatherDataListState,
         currentMarker: currentMarker ?? self.currentMarker,
         currectTab: currectTab ?? self.currectTab,
         isLoading: isLoading ?? self.isLoading,
         isRequesting: isRequesting ?? self.isRequesting,
         requestRecordError: requestRecordError ?? self.requestRecordError,
         loadRecordError: loadRecordError ?? self.loadRecordError
      )
   }
}

@Observable
final class MainViewModel {
   private(set) var state: MainState = .init()

   private let apiService: ApiService
   private let weatherDataDao: DataStoreService

   init(apiService: ApiService, weatherDataDao: DataStoreService) {
      self.apiService = apiService
      self.weatherDataDao = weatherDataDao
   }

   @MainActor
   func onEvent(_ event: MainViewEvent) {
      switch event {
      case  let .showTab(tab):
         state.currectTab = tab
      case .request:
         makeRequest()
      case .loadRecords:
         loadWeatherDataRecords()
      }
   }

   @MainActor
   private func makeRequest() {
      guard !state.isRequesting else { return }
      
      state = state.copy(
         isRequesting: true,
         requestRecordError: nil
      )
      
      apiService.request{[weak self] result in
         guard let self else { return }
         state.isRequesting = false
         switch result {
         case .success(let response):
            state = state.copy(
               currentMarker: CoordinateMarkerData(
                  name: response.name,
                  coordinate: Coordinate(latitude: response.latitude, longitude: response.longitude)
               ),
               isRequesting: false
            )
            saveRequest(response)
         case .failure(let error):
            state = state.copy(
               isRequesting: false,
               requestRecordError: error.localizedDescription
            )
         }
      }
   }
   
   private func saveRequest(_ request: LocalWeatherData){
      weatherDataDao.insert(data: request, date: Date()){[weak self] result in
         guard let self else { return }
         
         if let error = result {
            state = state.copy(
               loadRecordError: error.localizedDescription
            )
         }
      }
   }

   @MainActor
   private func loadWeatherDataRecords() {
      weatherDataDao.load{[weak self] result in
         guard let self else { return }
         switch result {
         case .empty:
            state = state.copy(
               listState: .loaded([])
            )
         case .found(let records):
            state = state.copy(
               listState: .loaded(records)
            )
         case .failure(let error):
            state = state.copy(
               loadRecordError: error.localizedDescription
            )
         }
      }
   }
}
