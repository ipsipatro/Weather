//
//  FavouriteCitiesViewModelTests.swift
//  WeatherTests
//
//  Created by Ipsi Patro on 18/03/2023.
//

import Quick
import Nimble
import RxSwift
import RxTest
import RxBlocking
import RealmSwift
@testable import Weather

class LocationSearchViewModelTests: QuickSpec {
    
    override func spec() {
        super.spec()
        
        describe("Favourite Cities ViewModel") {
            var scheduler: TestScheduler!
            var subject: LocationSearchViewModel!
            var fakeHTTPCommunication: HttpCommunicationManagerFake!
            var locationDataManagerFake: LocationDataManagerFake!
            var bag: DisposeBag!

            beforeEach {
                scheduler = TestScheduler(initialClock: 0)
                locationDataManagerFake = LocationDataManagerFake()
                fakeHTTPCommunication = HttpCommunicationManagerFake()
                subject = LocationSearchViewModel(httpService: fakeHTTPCommunication, locationDataManager: locationDataManagerFake, showSavedLocationsButtonTapped: false)
                bag = DisposeBag()
            }
            context("Outputs") {
                
                it("test showing weather report on selecting location from search result") {
                    // Arrange
                    let observer = scheduler.createObserver((Location, WeatherResponse).self)
                    subject.output.didReciveLocationWeather.drive(observer).disposed(by: bag)
                    
                    // Act
                    subject.input.selectedLocationStream.onNext(("Test Location", 0.0, 0.0))
                    
                    // Assert
                    observer.assertValueCount(1)
                }
                
                it("test saving location data to database on request") {
                    // Act
                    subject.input.savedLocationSelected.onNext(IndexPath(row: 1, section: 0))
                    
                    /// Assert
                    expect(locationDataManagerFake.saveLocationDataCalled) == true
                }
            }
        }
    }
}
