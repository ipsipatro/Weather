//
//  HttpCommunicationManager.swift
//  Weather
//
//  Created by Ipsi Patro on 13/03/2023.
//

import Foundation
import RxSwift


// MARK: - Errors
enum APIError: Error, Equatable {
    case emptyResponse
    case failedToDecode
    case unknown
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return NSLocalizedString("Response received is empty", comment: "API Error")
        case .failedToDecode:
            return NSLocalizedString("Failed to decode response", comment: "API Error")
        case .unknown:
            return NSLocalizedString("An error occured", comment: "API Error")
        }
    }
}

protocol HttpCommunicationCapable {
    func fetchWeatherReportFor(_ lat: Double, lon: Double) -> Single<WeatherResponse>
}

final class HttpCommunicationManager: HttpCommunicationCapable {
    private let urlProvider: URLProvideable
    private let communicationService: HttpCommunicationServiceable
    
    // MARK: - Instantiate
    init(communicationService: HttpCommunicationServiceable = HttpCommunicationService(), urlProvider: URLProvideable = Factory.urls) {
        self.communicationService = communicationService
        self.urlProvider = urlProvider
    }
    
    func fetchWeatherReportFor(_ lat: Double, lon: Double) -> Single<WeatherResponse> {
        let weatherReportURL = urlProvider.weatherReportURL(lat, lon: lon)
        return communicationService.get(url: weatherReportURL)
            .map { data in
                guard let data = data else {
                    throw APIError.emptyResponse
                }
                let weatherResponse: WeatherResponse
                do {
                    let decoder = JSONDecoder()
                    weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                } catch {
                    throw APIError.failedToDecode
                }
                return weatherResponse
            }
    }
}
