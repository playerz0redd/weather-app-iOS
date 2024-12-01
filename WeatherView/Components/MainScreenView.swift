//
//  MainScreenView.swift
//  wheather
//
//  Created by Pavel Playerz0redd on 2.10.24.
//

import SwiftUI

struct MainScreenView: View {
    var screenAmount: Int
    var increaseScreenAmount: () -> Void
    var decreaseScreenAmount: () -> Void
    
    @StateObject var viewModel: ViewModel = .init(model: .init(networkManager: .init()))
    @FocusState var inputActive: Bool
    @State var isUpdated: Bool = false
    var body: some View {
        VStack (alignment: .leading) {
            ScrollView(.vertical) {
                inputField
                    .onAppear() {
                        if !viewModel.currentCity.isEmpty && !isUpdated {
                            viewModel.getWeather()
                        }
                    }
                switch viewModel.viewState {
                case .notStarted:
                    Spacer()
                case .loading:
                    loadingPlaceholder
                case .loaded(let presetationEntity):
                    upperText(entity: presetationEntity)
                    curWeatherView(entity: presetationEntity)
                        .padding(.horizontal, 5)
                    WeatherWeekForecast(entity: presetationEntity)
                        .padding(.horizontal, 5)
                    let formatedDifference = String(format: "%.1f", presetationEntity.feelsLike - Float(presetationEntity.temperature)!)
                    TwoRectangularViews(
                        upInfoFirst: "Feels Like",
                        downInfoFirst: "\(presetationEntity.feelsLike)°\nActually: \(presetationEntity.temperature)°",
                        commentFirst: "Difference: \(formatedDifference)°",
                        height: 140,
                        width: 182,
                        upInfoSecond: "UV - Index",
                        downInfoSecond: "\(presetationEntity.uvIndex)",
                        commentSecond: presetationEntity.uvIndex < 5 ? "Now it's safe" : "Now it's not safe"
                    )
                    RectangularView(
                        upInfo: "Wind",
                        downInfo: "Speed \(presetationEntity.windSpeed) kph\nDegree: \(presetationEntity.windDegree)°",
                        comment: "Direction: \(presetationEntity.windDirection)",
                        height: 140,
                        width: .infinity
                    )
                    .padding(.horizontal, 15)
                    TwoRectangularViews(
                        upInfoFirst: "Sunrise",
                        downInfoFirst: presetationEntity.astro.sunrise,
                        commentFirst: "Sunset at \(presetationEntity.astro.sunset)",
                        height: 140,
                        width: 182,
                        upInfoSecond: "Precipitation",
                        downInfoSecond: "\(presetationEntity.pricipitation)\nToday",
                        commentSecond: presetationEntity.pricipitation < 5 ? "Its clear today" : "Its rainy today"
                    )
                    TwoRectangularViews(
                        upInfoFirst: "Visibility",
                        downInfoFirst: "\(presetationEntity.visibility) km",
                        commentFirst: getVisibilityString(entity: presetationEntity),
                        height: 140,
                        width: 182,
                        upInfoSecond: "Humidity",
                        downInfoSecond: "\(presetationEntity.humidity) %",
                        commentSecond: "Dew point now is: \(presetationEntity.dewPoint)°"
                    )
                    TwoRectangularViews(
                        upInfoFirst: "In general",
                        downInfoFirst: "\(presetationEntity.temperature)",
                        commentFirst: "\(presetationEntity.status)",
                        height: 140,
                        width: 182,
                        upInfoSecond: "Pressure",
                        downInfoSecond: "\(presetationEntity.temperature)°\nToday",
                        commentSecond: "\(presetationEntity.status)"
                    )
                case .failed(let error):
                    failurePlaceholder(error: error)
                }
            }.scrollIndicators(.hidden)
        }
        .background(Color("backgroundColor").ignoresSafeArea(.all))
        .animation(.default, value: viewModel.viewState)
    }
    
    private var inputField: some View {
         VStack {
            HStack {
                TextField("City", text: $viewModel.currentCity)
                    .textFieldStyle(.roundedBorder)
                    .focused($inputActive)
                if viewModel.refreshVisible {
                    Button(action:  {
                        viewModel.getWeather()
                        inputActive = false
                        isUpdated = true
                        store(viewModel.currentCity, key: SettingKeys.previousCity.rawValue)
                    },
                           label: {
                        Image(systemName: "arrow.trianglehead.counterclockwise.icloud")
                            .resizable()
                            .frame(width: 33, height: 25)
                            .padding(5)
                            .background(Color.white.cornerRadius(10))
                    })
                }
            }
            HStack (spacing: 8){
                CityButtonView(viewModel: viewModel, cityName: "Minsk")
                CityButtonView(viewModel: viewModel, cityName: "Moscow")
                CityButtonView(viewModel: viewModel, cityName: "Gomel")
                CityButtonView(viewModel: viewModel, cityName: "Riga")
                Button(action:  {
                    isUpdated = true
                    increaseScreenAmount()
                    print(amount)
                },
                       label: {
                    Image(systemName: "plus")
                        .resizable()
                        .foregroundStyle(.white)
                        .font(.system(size: 10))
                        .frame(width: 25, height: 22)
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(screenAmount < 7 ? .indigo : .gray))
                }).disabled(screenAmount < 7 ? false : true)
                
                Button(action:  {
                    isUpdated = true
                    decreaseScreenAmount()
                    print(amount)
                },
                       label: {
                    Image(systemName: "minus")
                        .resizable()
                        .foregroundStyle(.white)
                        .font(.system(size: 5))
                        .frame(width: 25, height: 4)
                        .padding(5)
                        .padding(.vertical, 9)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(screenAmount > 1 ? .indigo : .gray))
                }).disabled(screenAmount > 1 ? false : true)
                
            }.padding(.top, 2)
        }
        .padding()
        .animation(.default, value: viewModel.currentCity.isEmpty)
    }
    
    private func failurePlaceholder(error: WeatherError) -> some View {
        Text("Failed to load data : \(error.title)")
            .font(.system(size: 20))
            .foregroundStyle(.white)
            .bold()
    }
    
    private var loadingPlaceholder: some View {
        VStack {
            Spacer()
            ProgressView()
                .padding()
            Text("Loading...")
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .bold()
        }
        .padding(.top, 100)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct CityButtonView: View {
    @StateObject var viewModel: ViewModel
    let cityName: String
    var body: some View {
        Button(
            action:  {
                viewModel.currentCity = cityName
                viewModel.getWeather()
                store(viewModel.currentCity, key: SettingKeys.previousCity.rawValue)
            },
            label: {
                Text(cityName)
                    .padding(6)
                    .foregroundStyle(.white)
                    .background(Color .indigo)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .bold()
            })
    }
}

struct TwoRectangularViews: View {
    let upInfoFirst: String
    let downInfoFirst: String
    let commentFirst: String
    let height: Float
    let width: Float
    
    let upInfoSecond: String
    let downInfoSecond: String
    let commentSecond: String
    
    var body: some View {
        HStack {
            RectangularView(upInfo: upInfoFirst,
                            downInfo: downInfoFirst,
                            comment: commentFirst,
                            height: height,
                            width: width)
            .padding(.trailing, 5)
            RectangularView(upInfo: upInfoSecond,
                            downInfo: downInfoSecond,
                            comment: commentSecond,
                            height: height,
                            width: width)
        }.padding(.horizontal, 15)
    }
}

struct upperText: View {
    
    let entity: PresetationEntity
    
    var body: some View {
        Text(entity.title)
            .padding(.horizontal, 40)
            .padding(.top, 35)
            .foregroundStyle(.white)
            .font(.system(size: 40))
            .font(.footnote)
        Text("\(entity.temperature)°C")
            .font(.system(size: 70))
            .foregroundStyle(.white)
            .font(.footnote)
        Text(entity.status)
            .font(.system(size: 20))
            .foregroundStyle(.white)
            .bold()
            .opacity(0.6)
            .font(.footnote)
        Text("Max: \(String(entity.day.maxtemp_c))°C, Min: \(String(entity.day.mintemp_c))°C")
            .font(.system(size: 20))
            .foregroundStyle(.white)
            .bold()
            .font(.footnote)
    }
}

struct curWeatherView: View {
    
    let entity: PresetationEntity
    
    var body: some View {
        let myColor = Color("rectColor")
        RoundedRectangle(cornerRadius: 15)
            .foregroundStyle(myColor)
            .frame(height: 150)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading) {
                    Text("Its \(entity.status.lowercased()), \(entity.temperature)°")
                        .padding(.horizontal, 10)
                        .padding(.top, 6)
                        .foregroundStyle(.white)
                    Divider()
                        .padding(.leading, 10)
                    WeatherCollectionView(collection: getWeatherCollection(entity: entity))
                }
            }.padding(.horizontal, 10)
            .padding(.top, 50)
    }
}

struct WeatherCollectionView: View {
    let collection: [PresetationEntity.WeatherCollection]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(collection) { item in
                    WeatherColView(weatherCollection: item)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
}

struct WeatherWeekForecast: View {
    let entity: PresetationEntity
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .padding(.horizontal, 10)
            .foregroundStyle(Color("rectColor"))
            .frame(height: 435)
            .overlay(alignment: .topLeading) {
                VStack (alignment: .leading){
                    Text("7 day forecast")
                        .padding(.top, 10)
                        .font(.system(size: 20))
                        .foregroundStyle(Color .white)
                        .opacity(0.6)

                    let weekCollection = getForecastForDaysArray(entity: entity)
                    ForEach(weekCollection.indices, id: \.self) {
                        index in weekCollection[index]
                    }
                    
                }.padding(.horizontal, 20)
            }
    }
}

struct WeatherForecastRowInfo: View {
    let day: String
    let imageName: Image
    let maxTemperature: Float
    let minTemperature: Float
    
    var body: some View {
        Divider()
            .padding(.horizontal, 5)
            .padding(.bottom, 2)
        HStack (spacing: 60){
            Text(day)
                .font(.system(size: 20))
                .foregroundStyle(Color .white)
                .frame(width: 60, alignment: .leading)
            imageName
                .font(.system(size: 25))
                .symbolRenderingMode(.multicolor)
            Text("\(String(minTemperature))°   -   \(String(maxTemperature))°")
                .frame(maxWidth: .infinity, alignment: .trailing)
                .font(.system(size: 20))
                .foregroundStyle(Color .white)
                .opacity(0.6)
        }.padding(.top, 3)
    }
}

struct WeatherColView: View {
    
    let weatherCollection: PresetationEntity.WeatherCollection
    
    var body: some View {
        VStack {
            Text(weatherCollection.time)
                .foregroundStyle(.white)
                .bold()
                .padding(.bottom, 5)
            weatherCollection.icon
                .font(.system(size: 25))
                .frame(maxHeight: .infinity, alignment: .center)
                .symbolRenderingMode(.multicolor)
            Text("\(weatherCollection.temperature)")
                .frame(maxHeight: .infinity, alignment: .bottom)
                .foregroundStyle(.white)
                .bold()
                .font(.system(size: 20))
                .padding(.bottom, 20)
        }
        .padding(.leading, 10)
        .padding(.trailing, 20)
    }
}

