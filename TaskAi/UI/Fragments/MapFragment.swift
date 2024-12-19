//
//  MapFragment.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//

import SwiftUI
import MapKit

struct MapFragment: View {
   @State private var locationCoordinate: CLLocationCoordinate2D
   @State private var cameraPosition: MapCameraPosition = .automatic

   private var data: CoordinateMarkerData

   init(data: CoordinateMarkerData) {
      self.data = data
      self._locationCoordinate = State(initialValue: CLLocationCoordinate2D(
         latitude: data.coordinate.latitude,
         longitude: data.coordinate.longitude
      ))
   }

   var body: some View {
      Map(position: $cameraPosition){
         Marker(
            data.name,
            systemImage: "pin.fill",
            coordinate: locationCoordinate
         )
      }
      .mapStyle(.standard)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .onChange(of: data){
         locationCoordinate = CLLocationCoordinate2D(
            latitude: data.coordinate.latitude,
            longitude: data.coordinate.longitude
         )
         
         cameraPosition = .camera(MapCamera(
            centerCoordinate: locationCoordinate,
            distance: cameraPosition.camera?.distance ?? 1000
        ))
      }
   }
}

#Preview {
   MapFragment(
      data: CoordinateMarkerData.defaultValue
   )
}
