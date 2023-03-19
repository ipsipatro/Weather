//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Ipsi Patro on 15/03/2023.
//

import Foundation
import RxSwift
import RxCocoa

final class WeatherViewModel {
    struct Input {
        let showCityListButtonTapped: AnyObserver<Void>
        let addButtonTapped: AnyObserver<Void>
        let cancelTapped: AnyObserver<Void>
    }
    
    struct Output {
        var titleText: String
        var temperatureValue: String
        var maxTemperatureValue: String
        var minTemperatureValue: String
        var weatherDescription: String
        var iconImageURL: String
        let showCityListButtonTappedDriver: Driver<Void>
        let cancelDriver: Driver<Void>
    }
    
    let output: Output
    let input: Input
    
    // MARK: - Private variables
    private var city: City
    private var weatherResponse: WeatherResponse
    private var showCityListButtonTappedSubject = PublishSubject<Void>()
    private var addTappedSubject = PublishSubject<Void>()
    private let cityDataManager: DatabaseCapable
    private let cancelTappedSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    

    init(cityDataManager: DatabaseCapable, city: City, weatherResponse: WeatherResponse) {
        self.weatherResponse = weatherResponse
        self.cityDataManager = cityDataManager
        self.city = city
        output = Output(titleText: weatherResponse.name ?? "",
                        temperatureValue: "\(weatherResponse.main?.temp ?? 0)°C",
                        maxTemperatureValue: "H: \(weatherResponse.main?.temp_max ?? 0)°C",
                        minTemperatureValue: "L: \(weatherResponse.main?.temp_min ?? 0)°C",
                        weatherDescription: "\(weatherResponse.weather?.first?.description ?? "")",
                        iconImageURL: weatherResponse.weather?.first?.iconImageURL ?? "",
                        showCityListButtonTappedDriver: showCityListButtonTappedSubject.asDriverLogError(),
                        cancelDriver: cancelTappedSubject.asDriverLogError())
        input = Input(showCityListButtonTapped: showCityListButtonTappedSubject.asObserver(),
                      addButtonTapped: addTappedSubject.asObserver(),
                      cancelTapped: cancelTappedSubject.asObserver())
        self.bindObservers()
    }
    
    private func bindObservers() {
        addTappedSubject.asObservable().subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.cityDataManager.saveCityData(self.city)
            self.showCityListButtonTappedSubject.onNext(())
        }).disposed(by: disposeBag)
    }
}
