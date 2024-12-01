import Foundation
import Combine

struct WeatherModel {
    let networkManager: NetworkManager
    
    func requestWether(
        cityName: String
    ) -> AnyPublisher<TotalInfo?, WeatherError> {
        networkManager.requestData(
            of: TotalInfo.self,
            from: API_URL(cityName: cityName)
        )
    }
}

// MARK: - Contants

private extension WeatherModel {
    func API_URL(cityName: String) -> String {
        "https://api.weatherapi.com/v1/forecast.json?key=73460c01c32e417d9fd203814242709&q=\(cityName)&days=7&aqi=yes&alerts=no"
    }
}

struct NetworkManager {
    func requestData<Response: Decodable>(
        of type: Response.Type,
        from url: String
    ) -> AnyPublisher<Response?, WeatherError> {
        guard let url = URL(string: url) else {
            return Just(nil)
                .setFailureType(to: WeatherError.self)
                .eraseToAnyPublisher()
        }
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: Response?.self, decoder: JSONDecoder())
            .mapError { _ in WeatherError.invalidResponse }
            .eraseToAnyPublisher()
    }
}
