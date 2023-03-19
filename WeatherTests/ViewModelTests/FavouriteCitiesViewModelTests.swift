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

class FavouriteCitiesViewModelTests: QuickSpec {
    
    override func spec() {
        super.spec()
        
        describe("Favourite Cities ViewModel") {
            var scheduler: TestScheduler!
            var subject: FavouriteCitiesViewModel!
            var fakeHTTPCommunication: HttpCommunicationManagerFake!
            var cityDataManagerFake: CityDataManagerFake!
            var bag: DisposeBag!

            beforeEach {
                scheduler = TestScheduler(initialClock: 0)
                cityDataManagerFake = CityDataManagerFake()
                fakeHTTPCommunication = HttpCommunicationManagerFake()
                subject = FavouriteCitiesViewModel(httpService: fakeHTTPCommunication, cityDataManager: cityDataManagerFake, showCityListButtonTapped: false)
                bag = DisposeBag()
            }
            context("Outputs") {
                
                it("test showing weather report on selecting city from search result") {
                    // Arrange
                    let observer = scheduler.createObserver((City, WeatherResponse).self)
                    subject.output.didReciveCityWeather.drive(observer).disposed(by: bag)
                    
                    // Act
                    subject.input.selectedCityStream.onNext(("Test City", 0.0, 0.0))
                    
                    // Assert
                    observer.assertValueCount(1)
                }
                
                it("test saving city data to database on request") {
                    // Act
                    subject.input.favouriteCitySelected.onNext(IndexPath(row: 1, section: 0))
                    
                    /// Assert
                    expect(cityDataManagerFake.saveCityDataCalled) == true
                }
            }
        }
    }
}
