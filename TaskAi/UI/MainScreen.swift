//
//  MainScreen.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//
import SwiftUI
import MapKit

struct MainScreen: View {
   @State private var isAlertPresented: Bool = false
   
   let state: MainState
   let onEvent: (MainViewEvent)-> Void
   
   var body: some View {
      MainContainer()
         .safeAreaInset(edge: .bottom){
            ButtonsContaniner()
         }
         .onChange(of: state.requestRecordError){
            guard let _ = state.requestRecordError else {
               return
            }
            isAlertPresented = true
         }
         .alert(isPresented: $isAlertPresented){
            Alert(
               title: Text("Error"),
               message: Text("\(state.requestRecordError ?? "")"),
               dismissButton: .default(Text("Got It"))
            )
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
      switch state.currentTab {
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
   private func LoadingButton(
      _ title: String,
      isLoading: Bool,
      action: @escaping ()-> Void
   ) -> some View {
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
      onEvent: {_ in}
   )
}
