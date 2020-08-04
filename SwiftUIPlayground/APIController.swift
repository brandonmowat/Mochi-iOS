//
//  APIController.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-07-06.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import Foundation

class APIController {
    private var urlString = "https://brandon-server.herokuapp.com/api/v1/"
    
    func GET(path: String, callback: @escaping (_: Any) -> Void) {
        let url = URL(string: self.urlString + path)!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                callback(data)
            } catch {
                print(error)
            }
        }

        task.resume()
    }
    
    func getArticles(callback: @escaping (_: Any) -> Void) {
        GET(path: "articles/", callback: {(response: Any) -> Void in do {
            let decoder = JSONDecoder()
            let articles: [Article] = try! decoder.decode([Article].self, from: response as! Data)

            callback(articles)
            print(articles)
                            
            return
        }})
    }
    
    func POST(path: String, bodyDict: Dictionary<String, Any>, callback: @escaping (_: Any) -> Void) {
        
        let url = URL(string: self.urlString + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            return
        }
        
        print(bodyDict)
        print(httpBody)
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
                callback(data)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            }.resume()
        
    }
    
    func PATCH(path: String, bodyDict: Dictionary<String, Any>, callback: @escaping (_: Any) -> Void) {
        
        let url = URL(string: self.urlString + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            return
        }
        
        print(bodyDict)
        print(httpBody)
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
                callback(data)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            }.resume()
        
    }
    
    func DELETE(path: String, bodyDict: Dictionary<String, Any>, callback: @escaping (_: Any) -> Void) {
        
        let url = URL(string: self.urlString + path)!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            return
        }
        
        print(bodyDict)
        print(httpBody)
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
                callback(data)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
            }.resume()
        
    }
}
