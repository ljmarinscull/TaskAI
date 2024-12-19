//
//  HTTPClient.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//
import Foundation

public enum HTTPClientResult {
   case success(Data, HTTPURLResponse)
   case failure(Error)
}

public protocol HTTPClient {
   func get(from url: URLRequest, completion: @escaping (HTTPClientResult) -> Void)
}

struct UnExpectedValuesRepresentation: Error{}
final class URLSessionHTTPClient: HTTPClient {
   private let session: URLSession
   
   init(session: URLSession = .shared) {
      self.session = session
   }
   
   func get(from url: URLRequest, completion: @escaping (HTTPClientResult) -> Void){
      session.dataTask(with: url) { data, response, error in
         if let error {
            completion(.failure(error))
         } else if let data, let response = response as? HTTPURLResponse {
            completion(.success(data, response))
         } else {
            completion(.failure(UnExpectedValuesRepresentation()))
         }
      }
      .resume()
   }
}
