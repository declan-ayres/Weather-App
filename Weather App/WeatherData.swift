//
//  WeatherData.swift
//  Weather App
//
//  Created by Declan Ayres on 9/21/23.
//

import UIKit

struct WindData: Decodable {
    var speed: Double
    var deg: Int
    var gust: Double?
}

struct MainData: Decodable {
    var temp: Double
    var feels_like: Double
    var temp_min: Double
    var temp_max: Double
    var pressure: Int
    var humidity: Int
    var sea_level: Int?
    var grnd_level: Int?
}

struct WeatherDetails: Decodable {
    var id:Int
    var main: String
    var description: String
    var icon: String
}

struct WeatherData: Decodable {
    var base: String
    var cod: Int
    var name: String
    var visibility: Int
    var windData: WindData
    var mainData: MainData
    var details: [WeatherDetails]
    var timezone: Int
    var id: Int
    
    enum CodingKeys: String, CodingKey {
        case windData = "wind"
        case mainData = "main"
        case details = "weather"
        case base
        case cod
        case name
        case visibility
        case timezone
        case id
    }
}
