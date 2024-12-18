//
//  ApiService.swift
//  TaskAi
//
//  Created by Lazaro Jesus Marin Scull on 18.12.24.
//

public enum RequestResult {
   case success(RequestResponse)
   case failure(Error)
}

public protocol ApiService {
   func request(completion: @escaping (RequestResult) -> Void)
}
