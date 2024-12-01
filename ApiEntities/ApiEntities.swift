//
//  ApiEntities.swift
//  wheather
//
//  Created by Pavel Playerz0redd on 28.09.24.
//

import Foundation

struct TotalInfo: Decodable{
    var location: Location?
    var current: Weather?
    var forecast: Forecast?
}

struct Location: Decodable {
    var name: String
    var region: String
    var country: String
    var lat: Float
    var lon: Float
    var tzId: String
    var localtime_epoch: Int
    var localtime: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case region
        case country
        case lat
        case lon
        case tzId = "tz_id"
        case localtime_epoch
        case localtime
    }
}

struct Weather: Decodable{
    var last_updated_epoch: Int
    var last_updated: String
    var temp_c: Float
    var temp_f: Float
    var is_day: Int
    var condition: Condition
    var wind_mph: Float
    var wind_kph: Float
    var wind_degree: Int
    var wind_dir: String
    var pressure_mb: Float
    var pressure_in: Float
    var precip_mm: Float
    var precip_in: Float
    var humidity: Int
    var cloud: Int
    var feelslike_c: Float
    var feelslike_f: Float
    var windchill_c: Float
    var windchill_f: Float
    var heatindex_c: Float
    var heatindex_f: Float
    var dewpoint_c: Float
    var dewpoint_f: Float
    var vis_km: Float
    var vis_miles: Float
    var uv: Float
    var gust_mph: Float
    var gust_kph: Float
}

struct Condition: Decodable, Equatable {
    var text: String
    var icon: String
    var code: Int
}

struct Forecast: Decodable {
    var forecastday: [ForecastDay]
}

// MARK forecastday - array <date, day, hour, astro>

struct ForecastDay: Decodable, Equatable {
    var date: String
    var day: DayForecast
    var hour: [HourlyForecast]
    var astro: Astronomy
}

struct DayForecast: Decodable, Equatable {
    var maxtemp_c: Float
    var mintemp_c: Float
    var avgtemp_c: Float
    var maxwind_kph: Float
    var totalprecip_mm: Float
    var avghumidity: Float
    var daily_chance_of_rain: Int
    var daily_chance_of_snow: Int
    var condition: Condition
}

struct HourlyForecast: Decodable, Equatable {
    var time: String
    var temp_c: Float
    var condition: Condition
    var wind_kph: Float
    var feelslike_c: Float
}

struct Astronomy: Decodable, Equatable {
    var sunrise: String
    var sunset: String
}
