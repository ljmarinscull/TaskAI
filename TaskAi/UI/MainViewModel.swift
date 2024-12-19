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

public struct MainState {
   var weatherDataListState: WeatherDataListState = .loading
   var currentMarker: CoordinateMarkerData = CoordinateMarkerData.defaultValue
   var currentTab: Tab = .map
   var isLoading: Bool = false
   var isRequesting: Bool = false
   var requestRecordError: String? = nil
   var loadRecordError: String? = nil
}

extension MainState {
   func copy(
      listState: WeatherDataListState? = nil,
      currentMarker: CoordinateMarkerData? = nil,
      currentTab: Tab? = nil,
      isLoading: Bool? = nil,
      isRequesting: Bool? = nil,
      requestRecordError: String?? = nil,
      loadRecordError: String?? = nil
   ) -> Self {
      .init(
         weatherDataListState: listState ?? self.weatherDataListState,
         currentMarker: currentMarker ?? self.currentMarker,
         currentTab: currentTab ?? self.currentTab,
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
      case let .showTab(tab):
         state.currentTab = tab
      case .request:
         makeRequest()
      case .loadRecords:
         loadWeatherDataRecords()
      }
   }

   @MainActor
   private func makeRequest() {
      guard !state.isRequesting else { return }
      
      state.requestRecordError = nil
      state.isRequesting = true
      
      apiService.request{[weak self] result in
         guard let self else { return }
         
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
            let remoteError = error as? RemoteApiService.Error
            guard let remoteError else { return }
            state = state.copy(
               isRequesting: false,
               requestRecordError: map(error: remoteError)
            )
         }
      }
   }
   
   private func saveRequest(_ request: LocalWeatherData){
      weatherDataDao.insert(data: request, date: Date()){[weak self] result in
         guard let self else { return }
         
         if let error = result {
            state.loadRecordError = error.localizedDescription
         }
      }
   }

   @MainActor
   private func loadWeatherDataRecords() {
      weatherDataDao.load{[weak self] result in
         guard let self else { return }
         switch result {
         case .empty:
            state.weatherDataListState = .loaded([])
         case .found(let records):
            state.weatherDataListState = .loaded(records)
         case .failure(let error):
            state.loadRecordError = error.localizedDescription
         }
      }
   }
   
   private func map(error: RemoteApiService.Error) -> String {
      return switch error {
      case .invalidData:
         "Ups! something change on the Weather service. Please try again later."
      case .invalidRequest:
         "APIKey expired."
      case .connectivity:
         "Check your connection to internet."
      }
   }
}
