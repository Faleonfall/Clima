//
//  WeatherData.swift
//  Clima
//
//  Created by Volodymyr Kryvytskyi on 17.08.2023.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let id: Int
}
