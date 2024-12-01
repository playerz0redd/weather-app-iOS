import Foundation
import Combine
import SwiftUI

final class ViewModel: ObservableObject {
    
    
    
    var id = UUID()
    // MARK: - Published Properties
    
    @Published var viewState: WeatherViewState
    @Published var currentCity: String = getCity(forKey: SettingKeys.previousCity.rawValue) ?? ""
    
    // MARK: - Rx Properties
    
    private var requestSubscription: AnyCancellable?
    
    // MARK: - Module Properties
    
    private let model: WeatherModel
    
    // MARK: - Init
    
    init(model: WeatherModel) {
        self.model = model
        self.viewState = .notStarted
    }
    
    // MARK: - Utils
    
    func getWeather() {
        viewState = .loading
        requestSubscription = model
            .requestWether(cityName: currentCity)
            .delay(for: 0.6, scheduler: DispatchQueue.main)
            .map { [weak self] response -> PresetationEntity in
                let title = response?.location?.name ?? "Unknown"
                let temperature = "\(response?.current?.temp_c ?? 0)"
                let status = response?.current?.condition.text ?? "Unknown"
                //let weatherCollection = self?.parseCollection() ?? []
                let feelsLike = response?.current?.feelslike_c ?? 0
                let uvIndex = response?.current?.uv ?? 0
                let windSpeed = response?.current?.wind_kph ?? 0
                let windDegree = response?.current?.wind_degree ?? 0
                let windDirection = response?.current?.wind_dir ?? "Unknown"
                let pricipitation = response?.current?.precip_mm ?? 0
                let astro = response?.forecast?.forecastday[0].astro ?? .init(sunrise: "", sunset: "")
                let visibility = response?.current?.vis_km ?? 0
                let humidity = response?.current?.humidity ?? 0
                let dewPoint = response?.current?.dewpoint_c ?? 0
                let day = response?.forecast?.forecastday[0].day ?? .init(maxtemp_c: 0, mintemp_c: 0, avgtemp_c: 0, maxwind_kph: 0, totalprecip_mm: 0, avghumidity: 0, daily_chance_of_rain: 0, daily_chance_of_snow: 0, condition: .init(text: "", icon: "", code: 0))
                let hourForecast = response?.forecast?.forecastday[0].hour ?? []
                let forecastAnyDays = response?.forecast?.forecastday ?? []
                return .init(
                    title: title,
                    temperature: temperature,
                    status: status,
                    feelsLike: feelsLike,
                    uvIndex: uvIndex,
                    windSpeed: windSpeed,
                    windDegree: windDegree,
                    windDirection: windDirection,
                    pricipitation: pricipitation,
                    astro: astro,
                    visibility: visibility,
                    humidity: humidity,
                    dewPoint: dewPoint,
                    day: day,
                    hourForecast: hourForecast,
                    forecastAnyDays: forecastAnyDays
                    )
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard case .failure(let weatherError) = completion else {
                        return
                    }
                    self?.viewState = .failed(weatherError)
                },
                receiveValue: { [weak self] in
                    self?.viewState = .loaded($0)
                }
            )
    }
}

let setOfConditions: [String: String] = [
    "Sunny":"sun.max.fill", "Cloudy":"cloud.fill", "rain":"cloud.rain.fill", "Clear":"cloud.sun", "Overcast": "cloud.fill", "drizzle": "cloud.drizzle.fill", "Mist":"sun.haze.fill"]

func getWeatherCollection(entity: PresetationEntity) -> [PresetationEntity.WeatherCollection] {
    var collection: [PresetationEntity.WeatherCollection] = []
    for i in 0..<24 {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        var icon: Image = Image(systemName: "sun.max.fill")
        guard entity.hourForecast != [] else { return [] }
        for j in setOfConditions.keys {
            if entity.hourForecast[i].condition.text.contains(j) {
                icon = Image(systemName: setOfConditions[j]!)
            }
        }
//        if entity.hourForecast[i].condition.text.contains("cloudy") {
//            icon = Image(systemName: "cloud.fill")
//        } else if entity.hourForecast[i].condition.text.contains("rain") {
//            icon = Image(systemName: "cloud.rain.fill")
//        }
        var time: String
        if i < 10 {
            time = "0\(i)"
        }
        else {
            time = "\(i)"
        }
        if i == hour {
            time = "Now"
        }
        if i < 10 {
            collection.append(.init(time: time, icon: icon, temperature: "\(entity.hourForecast[i].temp_c)°"))
        } else {
            collection.append(.init(time: time, icon: icon, temperature: "\(entity.hourForecast[i].temp_c)°"))
        }
    }
    return collection
}

func getForecastForDaysArray(entity: PresetationEntity) -> [WeatherForecastRowInfo] {
    var forecast: [WeatherForecastRowInfo] = []
    let date = Date.now
    for i in 0..<7 {
        let nextDay = date.addingTimeInterval(TimeInterval(86400 * i))
        var icon: Image = Image(systemName: "sun.max.fill")
        guard entity.forecastAnyDays != [] else { return [] }
        for j in setOfConditions.keys {
            if entity.forecastAnyDays[i].day.condition.text.contains(j) {
                icon = Image(systemName: setOfConditions[j]!)
            }
        }
        forecast.append(.init(
            day: nextDay.formatted(Date.FormatStyle().weekday(.abbreviated)),
            imageName: icon,
            maxTemperature: entity.forecastAnyDays[i].day.maxtemp_c,
            minTemperature: entity.forecastAnyDays[i].day.mintemp_c))
    }
    return forecast
}

func getVisibilityString(entity: PresetationEntity) -> String {
    switch entity.visibility {
    case 0...10: return  "Poor visibility"
    case 11...20: return "Good visibility"
    case 21...50: return "Ideal visibility"
    default : return  ""
    }
}

// MARK: - UI Properties

extension ViewModel {
    var refreshVisible: Bool { !currentCity.isEmpty }
}

// MARK: - Parsing

//private extension ViewModel {
//    func parseCollection(entity: PresetationEntity) -> [PresetationEntity.WeatherCollection] {
//        var collection = [PresetationEntity.WeatherCollection]()
//        for i in 0..<24 {
//            collection.append(.init(time: "\(i)", icon: Image("cloudy"), temperature: "\()°"))
//        }
//        return [
//            .init(time: "Now", icon: Image("cloudy"), temperature: "10°"),
//            .init(time: "2", icon: Image("cloudy"), temperature: "21°"),
//            .init(time: "3", icon: Image("cloudy"), temperature: "12°"),
//            .init(time: "4", icon: Image("cloudy"), temperature: "12°"),
//            .init(time: "5", icon: Image("cloudy"), temperature: "21°"),
//            .init(time: "6", icon: Image("cloudy"), temperature: "14°"),
//            .init(time: "7", icon: Image("cloudy"), temperature: "11°")
//        ]
//    }
//}



//func getWeather() {
//    viewState = .loading
//    requestSubscription = model
//        .requestWether(cityName: currentCity)
//        .delay(for: 1, scheduler: DispatchQueue.main)
//        .map { [weak self] response -> PresetationEntity in
//            .init(
//                title: response?.location?.name ?? "Unknown",
//                temperature: "\(response?.current?.temp_c ?? 0)",
//                status: response?.current?.condition.text ?? "Unknown",
//                weatherCollection: self?.parseCollection() ?? [],
//                feelsLike: response?.current?.feelslike_c ?? 0,
//                uvIndex: response?.current?.uv ?? 0,
//                windSpeed: response?.current?.wind_kph ?? 0,
//                windDirection: response?.current?.wind_dir ?? "Unknown"
//            )
//        }
