//
//  LocationWeather.swift
//  Weather
//
//  Created by Ipsi Patro on 14/03/2023.
//

import Foundation

struct WeatherResponse: Codable {
    let weather: [LocationWeather]?
    let name: String?
    let main: MainWeather?
}

struct LocationWeather: Codable {
    let description: String?
    let icon: String?
    
    var iconImageURL: String? {
        guard let icon = icon else { return nil}
        return Factory.urls.weatcherIconURLWith(icon)
    }
}

struct MainWeather: Codable {
    let temp: Double?
    let temp_min: Double?
    let temp_max: Double?
}
