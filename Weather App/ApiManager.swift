//
//  ApiManager.swift
//  Weather App
//
//  Created by Declan Ayres on 9/21/23.
//

import UIKit

let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
let apiKey = "a20db6d5849a01c630f237baed6f0e47"

enum WeatherError: Error {
    case known(Error)
    case unknownError
    case notFound
    case invalidResponse
    case decodingError
 }

class ApiManager: NSObject {
    
    var imageCache = NSCache<NSString, UIImage>()

    func getWeatherForCity(city: String, completion: @escaping (Result<WeatherData, WeatherError>) -> ()) {
        let session = URLSession.shared
        var url = URL(string: baseUrl)!
        url.append(queryItems: [URLQueryItem(name: "q", value: city), URLQueryItem(name: "appid", value: apiKey), URLQueryItem(name: "units", value: "imperial")])
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            switch self.handleResult(data: data, response: response, error: error) {
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            case .success(let data):
                guard let result = try? JSONDecoder().decode(WeatherData.self, from: data) else {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            }
        }
        task.resume()
    }
    
    func getCityFromCoords(lat:Double, lon:Double, completion: @escaping (Result<String, WeatherError>) -> ()) {
        let session = URLSession.shared
        var url = URL(string: "https://api.openweathermap.org/geo/1.0/reverse")!
        url.append(queryItems: [URLQueryItem(name: "lat", value: String(lat)), URLQueryItem(name: "lon", value: String(lon)), URLQueryItem(name: "limit", value: "1"), URLQueryItem(name: "appid", value: apiKey)])
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            switch self.handleResult(data: data, response: response, error: error) {
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            case .success(let data):
                guard let result = try? JSONDecoder().decode([LocationData].self, from: data) else {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(result[0].name))
                }
            }
        }
        task.resume()
    }
    
    func getWeatherIcon(icon: String, completion: @escaping (Result<UIImage, WeatherError>) -> ()) {
        let key: NSString = icon + "@2x.png" as NSString
        if let image = imageCache.object(forKey: key) {
            completion(.success(image))
            return
        }
        let session = URLSession.shared
        let url = URL(string: "https://openweathermap.org/img/wn/" + icon + "@2x.png")!
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { data, response, error in
            switch self.handleResult(data: data, response: response, error: error) {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    completion(.failure(.notFound))
                    return
                }
                self.imageCache.setObject(image, forKey: key)
                DispatchQueue.main.async {
                    completion(.success(image))
                }
            }
        }
        task.resume()
    }
    
    func handleResult(data: Data?, response: URLResponse?, error:Error?) -> Result<Data, WeatherError> {
        if let error = error {
            return .failure(.known(error))
        }
        if let response = response as? HTTPURLResponse, response.statusCode != 200 {
            return .failure(.invalidResponse)
        }
        guard let data = data else {
            return .failure(.notFound)
        }
        return .success(data)
    }
}
