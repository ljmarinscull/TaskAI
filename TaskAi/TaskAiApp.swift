//
//  TaskAiApp.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//

import SwiftUI

@main
struct TaskAiApp: App {
   
   private let viewModel = MainViewModel(
      apiService: RemoteApiService(
         url: URL(string: "https://open-weather13.p.rapidapi.com/city/landon/EN")!,
         client: URLSessionHTTPClient()
      ),
      weatherDataDao: WeatherDataDao(connection: DBConnectionManager().connection)
   )
   
    var body: some Scene {
        WindowGroup {
           MainScreen(
              state: viewModel.state,
              onEvent: viewModel.onEvent
           )
        }
    }
}
