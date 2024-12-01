//
//  Contact.swift
//  wheather
//
//  Created by Pavel Playerz0redd on 28.09.24.
//

import Foundation
import SwiftUI

enum WeatherError: String, Error {
    case invalidResponse
    case invalidData
    
    var title: String {
        rawValue
    }
}

enum WeatherViewState: Equatable {
    case notStarted
    case loading
    case loaded(PresetationEntity)
    case failed(WeatherError)
}

struct PresetationEntity: Equatable {
    struct WeatherCollection: Identifiable, Equatable {
        let id = UUID().uuidString
        let time: String
        let icon: Image
        let temperature: String
    }
    let title: String
    let temperature: String
    let status: String
    let feelsLike: Float
    let uvIndex: Float
    let windSpeed: Float
    let windDegree: Int
    let windDirection: String
    let pricipitation: Float
    let astro: Astronomy
    let visibility: Float
    let humidity: Int
    let dewPoint: Float
    let day: DayForecast
    let hourForecast: [HourlyForecast]
    let forecastAnyDays: [ForecastDay]
}

