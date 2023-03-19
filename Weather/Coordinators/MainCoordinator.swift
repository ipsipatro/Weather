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
    private let cityDataManager: DatabaseCapable
    private let disposeBag = DisposeBag()
    

    init(navigationController: UINavigationController, httpCommunicationManager: HttpCommunicationCapable = HttpCommunicationManager()) {
        self.navigationController = navigationController
        self.httpCommunicationManager = httpCommunicationManager
        let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
        self.cityDataManager = CityDataManager(realm)
    }

    func start() {
        showFavouriteCitiesScreen(showCityListButtonTapped: false)
    }
    
    // MARK: - Private methods
    // Method to show saved citites screen
    private func showFavouriteCitiesScreen(showCityListButtonTapped: Bool) {
        let favouriteCitiesViewController = Factory.views.storyboards.main.favouriteCitiesViewController
        let favouriteCitiesViewModel = FavouriteCitiesViewModel(httpService: self.httpCommunicationManager, cityDataManager: cityDataManager, showCityListButtonTapped: showCityListButtonTapped)
        navigationController.pushViewController(favouriteCitiesViewController, animated: false)
        favouriteCitiesViewController.bind(viewModel: favouriteCitiesViewModel)
        
        favouriteCitiesViewModel.output.didReciveCityWeather.drive(onNext: { [weak self] (city, weatherResponse) in
            guard let self = self else { return }
            self.showWeatherReport(city: city, weatherResponse: weatherResponse)
        }).disposed(by: disposeBag)
    }
    
    // Method to show weather report for selected city
    private func showWeatherReport(city: City, weatherResponse: WeatherResponse) {
        let weatherViewController = Factory.views.storyboards.main.weatherViewController
        let weatherViewModel = WeatherViewModel(cityDataManager: cityDataManager, city: city, weatherResponse: weatherResponse)
        weatherViewController.bind(viewModel: weatherViewModel)
        navigationController.pushViewController(weatherViewController, animated: false)
        
        weatherViewModel.output.showCityListButtonTappedDriver.drive(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.showFavouriteCitiesScreen(showCityListButtonTapped: true)
        }).disposed(by: disposeBag)
        
        weatherViewModel.output.cancelDriver.drive(onNext: { [weak self] _ in
            self?.navigationController.popViewController(animated: true)
        }).disposed(by: disposeBag)

    }
}
