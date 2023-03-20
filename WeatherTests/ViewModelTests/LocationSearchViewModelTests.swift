//
//  LocationSearchViewModelTests.swift
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
        
        describe("Location Search ViewModel tests") {
            var scheduler: TestScheduler!
            var subject: LocationSearchViewModel!
            var fakeHTTPCommunication: HttpCommunicationManagerFake!
            var locationDataManagerFake: LocationDataManagerFake!
            var bag: DisposeBag!
            
            beforeEach {
                //saving some locations for testing purpose
                let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
                let locationDataManager = LocationDataManager(realm)
                let testLocation = locationDataManager.makeANewLocationWith("Test Location", latitude: 0.0, longitude: 0.0)
                do {
                    try locationDataManager.saveLocationData(testLocation)
                }catch RuntimeError.NoRealmSet {
                    XCTAssert(false, "No realm database was set")
                } catch {
                    XCTAssert(false, "Unexpected error \(error)")
                }
                
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
                    subject.input.savedLocationSelected.onNext(IndexPath(row: 0, section: 0))
                    
                    /// Assert
                    expect(locationDataManagerFake.saveLocationDataCalled) == true
                }
                
                it("test deleting location data to database on request") {
                    // Act
                    subject.input.itemDeleted.onNext(IndexPath(row: 0, section: 0))
                    
                    /// Assert
                    expect(locationDataManagerFake.deleteLocationObjectCalled) == true
                }
                
                it("test fetching weather report for selecting location") {
                    // Arrange
                    let observer = scheduler.createObserver((Location, WeatherResponse).self)
                    subject.output.didReciveLocationWeather.drive(observer).disposed(by: bag)
                                        
                    // Act
                    subject.input.savedLocationSelected.onNext(IndexPath(row: 0, section: 0))
                    
                    /// Assert
                    expect(fakeHTTPCommunication.fetchWeatherReportCalled) == true
                }
                
                it("test updating loading indicator state on fetching weather report") {
                    // Arrange
                    let observer = scheduler.createObserver(Bool.self)
                    subject.output.loadingStatusDriver.drive(observer).disposed(by: bag)

                    // Act
                    subject.input.savedLocationSelected.onNext(IndexPath(row: 0, section: 0))

                    /// Assert
                    observer.assertValueCount(3)
                }
                
                it("test hiding search results table view when the results are empty") {
                    // Arrange
                    let observer = scheduler.createObserver(Bool.self)
                    subject.output.hideSearchResultsViewDriver.drive(observer).disposed(by: bag)
                                        
                    // Act
                    subject.input.searchResultsStream.onNext([])
                    
                    /// Assert
                    observer.assertValues(true)
                }
            }
        }
    }
}
