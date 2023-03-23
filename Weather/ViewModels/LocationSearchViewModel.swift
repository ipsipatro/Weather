//
//  LocationSearchViewModel.swift
//  Weather
//
//  Created by Ipsi Patro on 16/03/2023.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import MapKit

final class LocationSearchViewModel {
    // MARK: - Input and Output
    // This is a Input class for the view model, users of this class can send inputs using these properties
    struct Input {
        var selectedLocationStream: AnyObserver<(String, Double, Double)>
        var searchResultsStream: AnyObserver<[MKLocalSearchCompletion]>
        var searchItemSelected: AnyObserver<IndexPath>
        var savedLocationSelected: AnyObserver<IndexPath>
        var itemDeleted: AnyObserver<IndexPath>
    }
    
    // This is a Output class for the view model, view model will send outputs using it's properties
    struct Output {
        var didReciveLocationWeather: Driver<(Location, WeatherResponse)>
        var searchResultsDataSource: Observable<[SectionModel<String, LocationCellModel>]>
        var savedLocationsDataSource: Observable<[SectionModel<String, SavedLocationCellModel>]>
        var hideSearchResultsViewDriver: Driver<Bool>
        let showPopupDriver: Driver<String>
        let searchForResultDriver: Driver<MKLocalSearchCompletion>
        let loadingStatusDriver: Driver<Bool>
    }
    
    let input: Input
    let output: Output
    
    // MARK: - Private variables
    private let httpService: HttpCommunicationCapable
    private let selectedLocationSubject = PublishSubject<(String, Double, Double)>()
    private let didReciveLocationWeatherSubject = PublishSubject<(Location, WeatherResponse)>()
    private let searchResultsSubject = PublishSubject<[MKLocalSearchCompletion]>()
    private let searchResultsDataSourceRelay = BehaviorRelay<[SectionModel<String, LocationCellModel>]>(value: [])
    private let locationDataManager: DatabaseCapable
    private let searchItemSelectedSubject = PublishSubject<IndexPath>()
    private let savedLocationSelectedSubject = PublishSubject<IndexPath>()
    private let itemDeletedSubject = PublishSubject<IndexPath>()
    private let savedLocationsDataSourceRelay = BehaviorRelay<[SectionModel<String, SavedLocationCellModel>]>(value: [])
    private let showPopupSubject = PublishSubject<String>()
    private let hideSearchResultsViewSubject = PublishSubject<Bool>()
    private let loadingStatusSubject = PublishSubject<Bool>()
    private let searchForResultSubject = PublishSubject<MKLocalSearchCompletion>()
    private let disposeBag = DisposeBag()
    
    // MARK: - Instantiate
    init(httpService: HttpCommunicationCapable, locationDataManager: DatabaseCapable, showSavedLocationsButtonTapped: Bool) {
        self.httpService = httpService
        self.locationDataManager = locationDataManager
        input = Input(selectedLocationStream: selectedLocationSubject.asObserver(),
                      searchResultsStream: searchResultsSubject.asObserver(),
                      searchItemSelected: searchItemSelectedSubject.asObserver(),
                      savedLocationSelected: savedLocationSelectedSubject.asObserver(),
                      itemDeleted: itemDeletedSubject.asObserver())
        output = Output(didReciveLocationWeather: didReciveLocationWeatherSubject.asDriverLogError(),
                        searchResultsDataSource: searchResultsDataSourceRelay.asObservable(),
                        savedLocationsDataSource: savedLocationsDataSourceRelay.asObservable(),
                        hideSearchResultsViewDriver: hideSearchResultsViewSubject.asDriverLogError(),
                        showPopupDriver: showPopupSubject.asDriverLogError(),
                        searchForResultDriver: searchForResultSubject.asDriverLogError(),
                        loadingStatusDriver: loadingStatusSubject.asDriverLogError())
        
        setupBinding()
        buildDataSource()
        
        if(!showSavedLocationsButtonTapped) {
            showLastTappedLocationWeather()
        }
    }
    
    // MARK: - Private methods
    // This method is going to be used to handle the input bindings
    private func setupBinding() {
        // Bind observers for search results
        selectedLocationSubject.asObservable().subscribe(onNext: { [weak self] (name, lat, lon) in
            guard let self = self else { return }
            self.fetchWeatherReportFor(location: self.locationDataManager.makeANewLocationWith(name, latitude: lat, longitude: lon))
        }).disposed(by: disposeBag)
        
        // Bind observers for search item selected from serch results table view cell
        self.searchItemSelectedSubject.asObservable()
            .withLatestFrom(self.searchResultsDataSourceRelay.asObservable()) { (indexPath, dataSource) -> MKLocalSearchCompletion in
                let selectedItem = dataSource[indexPath.section].items[indexPath.row]
                return selectedItem.result
            }
            .subscribe(onNext: { [weak self] result in
                self?.searchForResultSubject.onNext(result)
            })
            .disposed(by: disposeBag)
        
        // Bind observers for saved locations selection
        self.savedLocationSelectedSubject.asObservable()
            .withLatestFrom(self.savedLocationsDataSourceRelay.asObservable()) { (indexPath, dataSource) -> Location in
                let selectedItem = dataSource[indexPath.section].items[indexPath.row]
                return selectedItem.location
            }
            .subscribe(onNext: { [weak self] location in
                do {
                    try self?.locationDataManager.saveLocationData(location)
                } catch {
                    fatalError("Error in saving location: \(error.localizedDescription)")
                }
                self?.fetchWeatherReportFor(location: Location(value: location))
            })
            .disposed(by: disposeBag)
        
        // bind observers for deleting saved locations
        itemDeletedSubject.asObservable()
            .withLatestFrom(self.savedLocationsDataSourceRelay.asObservable()) { (indexPath, dataSource) -> Location in
                let selectedItem = dataSource[indexPath.section].items[indexPath.row]
                return selectedItem.location
            }
            .subscribe(onNext: { [weak self] location in
                do {
                    try self?.locationDataManager.deleteLocationData(location)
                } catch {
                    fatalError("Error in deleting location: \(error.localizedDescription)")
                }
                self?.getSavedLocationsDataSource()
            })
            .disposed(by: disposeBag)
        
    }
    
    private func buildDataSource() {
        // Building data source for search results table
        searchResultsSubject.asObservable().subscribe(onNext: { [weak self] seachResults in
            self?.hideSearchResultsViewSubject.onNext(seachResults.isEmpty)
            let locationCellItems: [LocationCellModel] =  seachResults.map { result in
                return LocationCellModel(result: result)
            }
            self?.searchResultsDataSourceRelay.accept([SectionModel(model: "", items: locationCellItems)])
        }).disposed(by: disposeBag)
        
        getSavedLocationsDataSource()
    }
    
    // This method is to fetch the saved locations in the device
    private func getSavedLocationsDataSource() {
        do {
            let savedLocations = try locationDataManager.getAllSavedLocations()
            let savedLocationCellItems: [SavedLocationCellModel] =  savedLocations.map { location in
                return SavedLocationCellModel(location: location)
            }
            self.savedLocationsDataSourceRelay.accept([SectionModel(model: "", items: savedLocationCellItems)])
        } catch {
            fatalError("Error in getting locations: \(error.localizedDescription)")
        }
    }
    
    // This method is to fetch last tapped location to show it's weather details without selection
    private func showLastTappedLocationWeather() {
        do {
            guard let lastTappedLocation = try locationDataManager.getLastTappedLocation() else { return }
            try self.locationDataManager.saveLocationData(lastTappedLocation)
            self.fetchWeatherReportFor(location: lastTappedLocation)
        } catch {
            fatalError("Error in deleting location: \(error.localizedDescription)")
        }
    }
    
    // This method is to send api request to fetch weather details
    private func fetchWeatherReportFor(location: Location) {
        loadingStatusSubject.onNext(true)
        httpService.fetchWeatherReportFor(location.latitude, lon: location.longitude).asObservable()
            .materialize()
            .subscribe(onNext: { [weak self] event in
                guard let self = self else { return }
                self.loadingStatusSubject.onNext(false)
                switch event {
                case .next(let weatherResponse):
                    self.didReciveLocationWeatherSubject.onNext((location, weatherResponse))
                case .error(let err):
                    self.showPopupSubject.onNext(err.localizedDescription)
                default:
                    break
                }
            }).disposed(by: disposeBag)
    }
}

