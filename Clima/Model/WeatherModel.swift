//
//  WeatherModel.swift
//  Clima
//
//  Created by Volodymyr Kryvytskyi on 17.08.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit

struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature: Double
    
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701:
            return "cloud.fog"
        case 711:
            return "smoke"
        case 721:
            return "sun.haze"
        case 731 & 761:
            return "sun.dust"
        case 741:
            return "cloud.fog"
        case 751:
            return "sun.dust"
        case 762:
            return "sun.haze"
        case 771:
            return "wind"
        case 781:
            return "tornado"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud"
        default:
            return "sun.max"
        }
    }
}
