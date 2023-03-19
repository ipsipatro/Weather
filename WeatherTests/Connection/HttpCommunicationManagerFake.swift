//
//  HttpCommunicationManagerFake.swift
//  WeatherTests
//
//  Created by Ipsi Patro on 18/03/2023.
//
import RxSwift
@testable import Weather

class HttpCommunicationManagerFake: HttpCommunicationCapable {
    func fetchWeatcherReportFor(lat: Double, lon: Double) -> Single<Weather.WeatherResponse> {
        return Single.just(WeatherResponse(weather: [LocationWeather(description: "Sunny", icon: "04")], name: "Test Location", main: MainWeather(temp: 4.0, temp_min: 2.3, temp_max: 5.4)))
    }
}
