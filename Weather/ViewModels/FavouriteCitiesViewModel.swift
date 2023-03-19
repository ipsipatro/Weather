//
//  FavouriteCitiesViewModel.swift
//  Weather
//
//  Created by Ipsi Patro on 16/03/2023.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import MapKit

final class FavouriteCitiesViewModel {
    // MARK: - Input and Output
    struct Input {
        var selectedCityStream: AnyObserver<(String, Double, Double)>
        var searchResultsStream: AnyObserver<[MKLocalSearchCompletion]>
        var searchItemSelected: AnyObserver<IndexPath>
        var favouriteCitySelected: AnyObserver<IndexPath>
        var itemDeleted: AnyObserver<IndexPath>
    }
    
    struct Output {
        var didReciveCityWeather: Driver<(City, WeatherResponse)>
        var searchResultsDataSource: Observable<[SectionModel<String, CityCellModel>]>
        var favouriteCititesDataSource: Observable<[SectionModel<String, FavouriteCitiesCellModel>]>
        var hideSearchResultsViewDriver: Driver<Bool>
        let showPopupDriver: Driver<String>
        let searchForResultDriver: Driver<MKLocalSearchCompletion>
        let loadingStatusDriver: Driver<Bool>
    }
    
    let input: Input
    let output: Output
    
    // MARK: - Private variables
    private let httpService: HttpCommunicationCapable
    private let selectedCitySubject = PublishSubject<(String, Double, Double)>()
    private let didReciveCityWeatherSubject = PublishSubject<(City, WeatherResponse)>()
    private let searchResultsSubject = PublishSubject<[MKLocalSearchCompletion]>()
    private let searchResultsDataSourceRelay = BehaviorRelay<[SectionModel<String, CityCellModel>]>(value: [])
    private let cityDataManager: DatabaseCapable
    private let searchItemSelectedSubject = PublishSubject<IndexPath>()
    private let favouriteCitySelectedSubject = PublishSubject<IndexPath>()
    private let itemDeletedSubject = PublishSubject<IndexPath>()
    private let favouriteResultsDataSourceRelay = BehaviorRelay<[SectionModel<String, FavouriteCitiesCellModel>]>(value: [])
    private let showPopupSubject = PublishSubject<String>()
    private let hideSearchResultsViewSubject = PublishSubject<Bool>()
    private let loadingStatusSubject = PublishSubject<Bool>()
    private let searchForResultSubject = PublishSubject<MKLocalSearchCompletion>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Instantiate
    init(httpService: HttpCommunicationCapable, cityDataManager: DatabaseCapable, showCityListButtonTapped: Bool) {
        self.httpService = httpService
        self.cityDataManager = cityDataManager
        input = Input(selectedCityStream: selectedCitySubject.asObserver(),
                      searchResultsStream: searchResultsSubject.asObserver(),
                      searchItemSelected: searchItemSelectedSubject.asObserver(),
                      favouriteCitySelected: favouriteCitySelectedSubject.asObserver(),
                      itemDeleted: itemDeletedSubject.asObserver())
        output = Output(didReciveCityWeather: didReciveCityWeatherSubject.asDriverLogError(),
                        searchResultsDataSource: searchResultsDataSourceRelay.asObservable(),
                        favouriteCititesDataSource: favouriteResultsDataSourceRelay.asObservable(),
                        hideSearchResultsViewDriver: hideSearchResultsViewSubject.asDriverLogError(),
                        showPopupDriver: showPopupSubject.asDriverLogError(),
                        searchForResultDriver: searchForResultSubject.asDriverLogError(),
                        loadingStatusDriver: loadingStatusSubject.asDriverLogError())
        
        bindObservers()
        buildDataSource()
        
        if(!showCityListButtonTapped) {
            showLastTappedCityWeather()
        }
    }
    
    // MARK: - Private methods
    private func bindObservers() {
        // Bind observers for serch results
        selectedCitySubject.asObservable().subscribe(onNext: { [weak self] (name, lat, lon) in
            guard let self = self else { return }
            self.sendRequestWith(city: self.cityDataManager.makeNewCity(name: name, latitude: lat, longitude: lon))
        }).disposed(by: disposeBag)
        
        self.searchItemSelectedSubject.asObservable()
            .withLatestFrom(self.searchResultsDataSourceRelay.asObservable()) { (indexPath, dataSource) -> MKLocalSearchCompletion in
                let selectedItem = dataSource[indexPath.section].items[indexPath.row]
                return selectedItem.result
            }
            .subscribe(onNext: { [weak self] result in
                self?.searchForResultSubject.onNext(result)
            })
            .disposed(by: disposeBag)
        
        // bind observers for favourite cities
        self.favouriteCitySelectedSubject.asObservable()
            .withLatestFrom(self.favouriteResultsDataSourceRelay.asObservable()) { (indexPath, dataSource) -> City in
                let selectedItem = dataSource[indexPath.section].items[indexPath.row]
                return selectedItem.city
            }
            .subscribe(onNext: { [weak self] city in
                do {
                    try self?.cityDataManager.saveCityData(city)
                } catch {
                    fatalError("Error in saving city: \(error.localizedDescription)")
                }
                self?.sendRequestWith(city: City(value: city))
            })
            .disposed(by: disposeBag)
        
        // bind observers for deleting object
        itemDeletedSubject.asObservable()
            .withLatestFrom(self.favouriteResultsDataSourceRelay.asObservable()) { (indexPath, dataSource) -> City in
                let selectedItem = dataSource[indexPath.section].items[indexPath.row]
                return selectedItem.city
            }
            .subscribe(onNext: { [weak self] city in
                do {
                    try self?.cityDataManager.deleteCityData(city)
                } catch {
                    fatalError("Error in deleting city: \(error.localizedDescription)")
                }
                self?.getFavouriteCititesDataSource()
            })
            .disposed(by: disposeBag)
        
    }
    
    private func buildDataSource() {
        // Building data source for search results table
        searchResultsSubject.asObservable().subscribe(onNext: { [weak self] seachResults in
            self?.hideSearchResultsViewSubject.onNext(seachResults.isEmpty)
            let cityCellItems: [CityCellModel] =  seachResults.map { result in
                return CityCellModel(result: result)
            }
            self?.searchResultsDataSourceRelay.accept([SectionModel(model: "", items: cityCellItems)])
        }).disposed(by: disposeBag)
        
        getFavouriteCititesDataSource()
    }
    
    private func getFavouriteCititesDataSource() {
        do {
            let favouriteCitites = try cityDataManager.getAllSavedCities()
            let favouriteCityCellItems: [FavouriteCitiesCellModel] =  favouriteCitites.map { city in
                return FavouriteCitiesCellModel(city: city)
            }
            self.favouriteResultsDataSourceRelay.accept([SectionModel(model: "", items: favouriteCityCellItems)])
        } catch {
            fatalError("Error in getting cities: \(error.localizedDescription)")
        }
    }
    
    private func showLastTappedCityWeather() {
        do {
            guard let lastTappedCity = try cityDataManager.getLastTappedCity() else { return }
            try self.cityDataManager.saveCityData(lastTappedCity)
            self.sendRequestWith(city: lastTappedCity)
        } catch {
            fatalError("Error in deleting city: \(error.localizedDescription)")
        }
    }
    
    private func sendRequestWith(city: City) {
        loadingStatusSubject.onNext(true)
        httpService.fetchWeatcherReportFor(lat: city.latitude, lon: city.longitude).asObservable()
            .materialize()
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                self.loadingStatusSubject.onNext(false)
                switch event {
                case .next(let weatherResponse):
                    self.didReciveCityWeatherSubject.onNext((city, weatherResponse))
                case .error(let err):
                    self.showPopupSubject.onNext(err.localizedDescription)
                default:
                    break
                }
            }).disposed(by: disposeBag)
    }
}

