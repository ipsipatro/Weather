//
//  URLFactory.swift
//  Weather
//
//  Created by Ipsi Patro on 14/03/2023.
//

import Foundation

protocol URLProvideable {
    func weatherReportURL(_ lat: Double, lon: Double) -> String
    func weatherIconURLWith(_ id: String) -> String
}

final class URLFactory: URLProvideable {    
    private func apiToken() -> String {
        //Getting the saved api key for Open Weather api call
        guard let openWeatherAPIToken : String = Bundle.main.object(forInfoDictionaryKey: "OW_App_ID") as? String else {
            assertionFailure("Missing weather token")
            return ""
        }
        return openWeatherAPIToken
    }
    
    func weatherReportURL(_ lat: Double, lon: Double) -> String {
        return "https://api.openweathermap.org/data/2.5/weather?lat=\(Double(lat ))&lon=\(Double(lon))&appid=\(apiToken())&units=metric"
    }
    
    func weatherIconURLWith(_ id: String) -> String {
        return "https://openweathermap.org/img/wn/\(id)@2x.png"
    }
}
