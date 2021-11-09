//
//  RequestManager.swift
//  WINFOX
//
//  Created by  Svetlana Frolova on 05.11.2021.
//

import Foundation
import UIKit

enum ApiError: Error {
    case noData
}

class RequestManager {
    static let shared = RequestManager()
    
    public func getMenu(id: String, completion: @escaping (Result<[MenuStruct], Error>) -> Void) {
        guard let url = URL(string: "http://94.127.67.113:8099/getMenu") else {
            completion(.failure(ApiError.noData))
            return
        }
        let config = ["place_id": id]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("text/html", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: config, options: []) else { return }
        request.httpBody = httpBody
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            if let response = response {
                print("response places:\(response)")
            }
            if (response as? HTTPURLResponse)?.statusCode != 200 {
                completion(.failure(ApiError.noData))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiError.noData))
                return
            }
            do {
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                var menu: [MenuStruct] = []
                guard let json = jsonObject as? [NSDictionary] else {
                    completion(.failure(ApiError.noData))
                    return
                }
                for item in json {
                    guard
                    let name = item.value(forKey: "name") as? String,
                    let descOptional
                        = item.value(forKey: "desc").debugDescription.attributedHtmlString,
                    let image = item.value(forKey: "image") as? String,
                    let price = item.value(forKey: "price") as? Double,
                    let weight = item.value(forKey: "weight") as? Double else {
                        completion(.failure(ApiError.noData))
                        return
                    }
                    let descPath = descOptional.string
                    var descArray = descPath.components(separatedBy: "\n")
                    descArray.removeFirst()
                    descArray.removeLast()
                    descArray.removeLast()
                    var desc = ""
                    for item in descArray {
                        if desc == "" {
                            desc = item
                        } else {
                            desc = desc + "\n" + item
                        }
                    }
                    menu.append(MenuStruct(image: image, price: price, name: name, weight: weight, desc: desc))
                }
                completion(.success(menu))
                
            }
        })
        dataTask.resume()
    }
    

    
    public func checkUser(phoneNumber: String, uid: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://94.127.67.113:8099/checkUser") else { return }
        let config = [
            "phone": phoneNumber,
            "id": uid
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("text/html", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: config, options: []) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(true)
                }
            }
            
            guard let data = data else {
                completion(false)
                return
            }
            
            do {
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                print(jsonObject ?? "json of check user fail")
            }
        }
        dataTask.resume()
    }

    public func getPlace(completion: @escaping (Result<[PlacesStruct], Error>) -> Void) {
        guard let url = URL(string: "http://94.127.67.113:8099/getPlaces") else {
            completion(.failure(ApiError.noData))
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            if let response = response {
                print("response places:\(response)")
            }
            if (response as? HTTPURLResponse)?.statusCode != 200 {
                completion(.failure(ApiError.noData))
                return
            }
            
            guard let data = data else {
                completion(.failure(ApiError.noData))
                return
            }
            do {
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                var places: [PlacesStruct] = []
                guard let json = jsonObject as? [NSDictionary] else {
                    completion(.failure(ApiError.noData))
                    return
                }
                for item in json {
                    guard
                    let name = item.value(forKey: "name") as? String,
                        let desc = item.value(forKey: "desc") as? String,
                    let image = item.value(forKey: "image") as? String,
                    let latitide = item.value(forKey: "latitide") as? Double,
                    let longitude = item.value(forKey: "longitude") as? Double,
                    let id = item.value(forKey: "id") as? String else {
                        completion(.failure(ApiError.noData))
                        return
                    }
                    places.append(PlacesStruct(image: image, name: name, id: id, latitide: latitide, longitude: longitude, desc: desc))
                }
                completion(.success(places))
                
            }
        })
        dataTask.resume()
    }

    public func getImage(image: String, completion: @escaping (UIImage?) -> Void) {
        guard let urlImage = URL(string: image) else {
            completion(UIImage(named: "NoImageFound"))
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: urlImage) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    print("Warning: Image not found")
                    completion(UIImage(named: "NoImageFound"))
                    return
            }
            let image = UIImage(data: data)
            completion(image)
        }
        dataTask.resume()
    }
    
    public func sendCoords(latitude: Double?, longitude: Double?, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://94.127.67.113:8099/sendCoords") else { return }
        let config = [
            "latitude": latitude,
            "longitude": longitude
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("text/html", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: config, options: []) else { return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(true)
                }
            }
            
            guard let data = data else {
                completion(false)
                return
            }
            do {
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
                print(jsonObject ?? "json of send coordinate fail")
            }
        }
        dataTask.resume()
    }
}

extension String {
    
    var utfData: Data {
        return Data(utf8)
    }
    
    var attributedHtmlString: NSAttributedString? {
        
        do {
            return try NSAttributedString(data: utfData, options: [
              .documentType: NSAttributedString.DocumentType.html,
              .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil)
        } catch {
            print("Error:", error)
            return nil
        }
    }
}
