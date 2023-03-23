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
    // MARK: - Input and Output
    // This is a Input class for the view model, users of this class can send inputs using these properties
    struct Input {
        let showSavedLocationsButtonTapped: AnyObserver<Void>
        let addButtonTapped: AnyObserver<Void>
        let cancelTapped: AnyObserver<Void>
    }
    
    // This is a Output class for the view model, view model will send outputs using it's properties
    struct Output {
        var titleText: String
        var temperatureValue: String
        var maxTemperatureValue: String
        var minTemperatureValue: String
        var weatherDescription: String
        var iconImageURL: String
        let showSavedLocationsButtonTappedDriver: Driver<Void>
        let cancelDriver: Driver<Void>
    }
    
    let output: Output
    let input: Input
    
    // MARK: - Private variables
    private var location: Location
    private var weatherResponse: WeatherResponse
    private var showSavedLocationsButtonTappedSubject = PublishSubject<Void>()
    private var addTappedSubject = PublishSubject<Void>()
    private let locationDataManager: DatabaseCapable
    private let cancelTappedSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Instantiate
    init(locationDataManager: DatabaseCapable, location: Location, weatherResponse: WeatherResponse) {
        self.weatherResponse = weatherResponse
        self.locationDataManager = locationDataManager
        self.location = location
        output = Output(titleText: weatherResponse.name ?? "",
                        temperatureValue: "\(Int(weatherResponse.main?.temp ?? 0))°C",
                        maxTemperatureValue: "H: \(Int(weatherResponse.main?.temp_max ?? 0))°C",
                        minTemperatureValue: "L: \(Int(weatherResponse.main?.temp_min ?? 0))°C",
                        weatherDescription: "\(weatherResponse.weather?.first?.description ?? "")",
                        iconImageURL: weatherResponse.weather?.first?.iconImageURL ?? "",
                        showSavedLocationsButtonTappedDriver: showSavedLocationsButtonTappedSubject.asDriverLogError(),
                        cancelDriver: cancelTappedSubject.asDriverLogError())
        input = Input(showSavedLocationsButtonTapped: showSavedLocationsButtonTappedSubject.asObserver(),
                      addButtonTapped: addTappedSubject.asObserver(),
                      cancelTapped: cancelTappedSubject.asObserver())
        self.setupBinding()
    }
    
    // This method is going to be used to handle the inputs
    private func setupBinding() {
        addTappedSubject.asObservable().subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            do {
                try self.locationDataManager.saveLocationData(self.location)
            } catch {
                fatalError("Error in saving location: \(error.localizedDescription)")
            }
            
            self.showSavedLocationsButtonTappedSubject.onNext(())
        }).disposed(by: disposeBag)
    }
}
