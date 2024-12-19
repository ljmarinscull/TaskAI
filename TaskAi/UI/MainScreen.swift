//
//  MainScreen.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//
import SwiftUI
import MapKit

struct MainScreen: View {
   let state: MainState
   let onEvent: (MainViewEvent)-> Void
   
   var body: some View {
      MainContainer()
         .safeAreaInset(edge: .bottom){
            ButtonsContaniner()
         }
   }
   
   private func action(withEvent event: MainViewEvent) {
      onEvent(event)
   }
   
   @ViewBuilder
   private func ButtonsContaniner() -> some View {
      VStack{
         HStack{
            ActionButton("Show Map", action: {
               action(withEvent: .showTab(.map))
            })
            ActionButton("Show List", action: {
               action(withEvent: .showTab(.list))
            })
         }
         LoadingButton("Request", isLoading: state.isRequesting){
            action(withEvent: .request)
         }
      }
      .padding(.horizontal)
   }
   
   @ViewBuilder
   private func MainContainer() -> some View {
      switch state.currectTab {
      case .map:
         MapFragment(data: state.currentMarker)
      case .list:
         ListFragment(state: state.weatherDataListState)
            .onAppear{
               onEvent(.loadRecords)
            }
      }
   }
   
   @ViewBuilder
   private func ButtonLabel(_ text: String) -> some View {
      Text(text)
         .foregroundStyle(.white)
         .frame(maxWidth: .infinity)
         .padding(.vertical)
         .background(Color.blue)
         .clipShape(RoundedRectangle(cornerRadius: 16))
   }
   
   @ViewBuilder
   private func LoadingButton(_ title: String, isLoading: Bool, action: @escaping ()-> Void) -> some View {
      Button(action: action) {
         HStack{
            if isLoading {
               ProgressView()
                  .progressViewStyle(.circular)
            }
            Text(title)
               .foregroundStyle(.white)
         }
         .frame(maxWidth: .infinity)
         .padding(.vertical)
         .background(Color.blue)
         .clipShape(RoundedRectangle(cornerRadius: 16))
      }
      .disabled(isLoading)
   }
   
   @ViewBuilder
   private func ActionButton(_ title: String, action: @escaping ()-> Void) -> some View {
      Button(action: action) {
         ButtonLabel(title)
      }
   }
}

#Preview {
   MainScreen(
      state: .init(),
      onEvent: {_ in }
   )
}
