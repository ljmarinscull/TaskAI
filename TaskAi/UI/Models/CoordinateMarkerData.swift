//
//  CoordinateMarkerData.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 19.12.24.
//

struct CoordinateMarkerData: Equatable {
   let name: String
   let coordinate: Coordinate
   
   static var defaultValue: CoordinateMarkerData {
      .init(name: "Mexico City", coordinate: .init(latitude: 19.451054, longitude: -99.125519))// Mexico City Coordinates
   }
}
