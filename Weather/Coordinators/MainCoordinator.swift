//
//  MainCoordinator.swift
//  Weather
//
//  Created by Ipsi Patro on 13/03/2023.
//

import UIKit
import RxSwift
import RealmSwift

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController
    private let httpCommunicationManager: HttpCommunicationCapable
    private let locationDataManager: DatabaseCapable
    private let disposeBag = DisposeBag()
    

    init(navigationController: UINavigationController, httpCommunicationManager: HttpCommunicationCapable = HttpCommunicationManager()) {
        self.navigationController = navigationController
        self.httpCommunicationManager = httpCommunicationManager
        let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
        self.locationDataManager = LocationDataManager(realm)
    }

    func start() {
        showLocationSearchScreen(showSavedLocationsButtonTapped: false)
    }
    
    // MARK: - Private methods
    // Method to show saved citites screen
    private func showLocationSearchScreen(showSavedLocationsButtonTapped: Bool) {
        let locationSearchViewController = Factory.views.storyboards.main.locationSearchViewController
        let locationSearchViewModel = LocationSearchViewModel(httpService: self.httpCommunicationManager, locationDataManager: locationDataManager, showSavedLocationsButtonTapped: showSavedLocationsButtonTapped)
        navigationController.pushViewController(locationSearchViewController, animated: false)
        locationSearchViewController.bind(viewModel: locationSearchViewModel)
        
        locationSearchViewModel.output.didReciveLocationWeather.drive(onNext: { [weak self] (location, weatherResponse) in
            guard let self = self else { return }
            self.showWeatherReport(location: location, weatherResponse: weatherResponse)
        }).disposed(by: disposeBag)
    }
    
    // Method to show weather report for selected location
    private func showWeatherReport(location: Location, weatherResponse: WeatherResponse) {
        let weatherViewController = Factory.views.storyboards.main.weatherViewController
        let weatherViewModel = WeatherViewModel(locationDataManager: locationDataManager, location: location, weatherResponse: weatherResponse)
        weatherViewController.bind(viewModel: weatherViewModel)
        navigationController.pushViewController(weatherViewController, animated: false)
        
        weatherViewModel.output.showSavedLocationsButtonTappedDriver.drive(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.showLocationSearchScreen(showSavedLocationsButtonTapped: true)
        }).disposed(by: disposeBag)
        
        weatherViewModel.output.cancelDriver.drive(onNext: { [weak self] _ in
            self?.navigationController.popViewController(animated: true)
        }).disposed(by: disposeBag)

    }
}
