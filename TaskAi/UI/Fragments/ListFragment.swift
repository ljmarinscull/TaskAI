//
//  ListFragment.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//

import SwiftUI

struct ListFragment: View {
   @State private var isShowingErrorAlert: Bool = false
   
   let state: WeatherDataListState

   var body: some View {
      VStack{
         switch state {
         case .loading:
            ProgressView()
               .progressViewStyle(.circular)
         case .loaded(let items):
            ListView(items: items)
         case .error:
            Text("Nothing to show")
               .onAppear{
                  isShowingErrorAlert = true
               }
         }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .alert(isPresented: $isShowingErrorAlert) {
         Alert(title: Text("Error"), message: Text("Something went wrong when loading the weather data"))
      }
   }

   private struct ListView: View {
      let items: [WeatherData]
      
      var body: some View {
         Text("Weather records")
            .font(.title)
         VStack{
            if items.isEmpty {
               Text("Nothing to show")
            } else {
               List(items){
                  ListItem(model: $0)
                     .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                     .listRowSeparator(.hidden)
               }
               .listStyle(.plain)
            }
         }.frame(maxWidth: .infinity, maxHeight: .infinity)
      }
   }
}

struct ListItem: View {
   let model: WeatherData
   
   var body: some View {
      VStack(spacing: 16){
         HStack{
            HStack{
               Image(systemName: "mappin.and.ellipse")
                  .foregroundStyle(.red)
               Text(model.name)
            }
            Spacer()
            HStack{
               Text("Time: \(model.date)")
            }
         }
         HStack{
            Image(systemName: "humidity.fill")
            Text("Humidity")
            Text("\(model.humidity)")
            Divider()
            Image(systemName: "thermometer.high")
               .foregroundStyle(.red)
            Text("Temp")
            Text("\(String(format:"%.01f", model.temp))")
         }
         .fixedSize(horizontal: false, vertical: true)
         HStack{
            Text("Weather:")
            Text(model.weather)
         }
      }
      .padding(.vertical, 24)
      .padding(.horizontal, 16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.gray.opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 16))
   }
}

#Preview("Loading"){
   ListFragment(state: .loading)
}

#Preview("Loaded") {
   ListFragment(
      state: .loaded([
         WeatherData(
            id: 1,
            name: "Mexico DF",
            weather: "Sunny",
            temp: 60,
            humidity: 80,
            date: "01/01/2025 9:50:00 AM"
         ),
         WeatherData(
            id: 2,
            name: "Mexico DF",
            weather: "Sunny",
            temp: 60,
            humidity: 80,
            date: "01/01/2025 9:50:10 AM"
         )
      ])
   )
}
  
#Preview("Error") {
   ListFragment(state: .error)
}
