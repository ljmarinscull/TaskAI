//
//  ContentView.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//
//

import SwiftUI
import MapKit
import Observation

struct ContentView: View {
   
   let viewModel = MainViewModel(
      apiService: RemoteApiService(
         url: URL(string: "https://open-weather13.p.rapidapi.com/city/landon/EN")!,
         client: URLSessionHTTPClient()
      ),
      weatherDataDao: WeatherDataDao(connection: DBConnectionManager().connection)
   )
   
   var body: some View {
      MainScreen(
         state: viewModel.state,
         onEvent: viewModel.onEvent
      )
   }
}

#Preview {
   ContentView()
}
