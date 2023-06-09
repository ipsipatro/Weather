//
//  WeatherViewModel.swift
//  WeatherTests
//
//  Created by Ipsi Patro on 17/03/2023.
//

import Quick
import Nimble
import RxSwift
import RxTest
import RxBlocking
import RealmSwift
@testable import Weather

class WeatherViewModelTest: QuickSpec {
    
    override func spec() {
        super.spec()
        
        describe("Weather View Model Tests") {
            var scheduler: TestScheduler!
            var locationDataManagerFake: LocationDataManagerFake!
            var testLocation: Location!
            var weatherResponse: WeatherResponse!
            var bag: DisposeBag!
            
            var subject: WeatherViewModel!
            
            beforeEach {
                scheduler = TestScheduler(initialClock: 0)
                locationDataManagerFake = LocationDataManagerFake()
                testLocation = locationDataManagerFake.makeANewLocationWith("Test Location", latitude: 1.1, longitude: 1.1)
                bag = DisposeBag()
            }
            
            context("Outputs") {
                beforeEach {
                    weatherResponse = WeatherResponse(weather: [LocationWeather(description: "Sunny", icon: "04")], name: "Test Location", main: MainWeather(temp: 1.2, temp_min: 0.5, temp_max: 2.3))
                    subject = WeatherViewModel(locationDataManager: locationDataManagerFake, location: testLocation, weatherResponse: weatherResponse)
                }
                
                it("test setting location name as titleText") {
                    // Assert
                    expect(subject.output.titleText).to(equal("Test Location"))
                }
                
                it("test setting temp values with right formatting") {
                    // Assert
                    expect(subject.output.temperatureValue).to(equal("1°C"))
                    expect(subject.output.minTemperatureValue).to(equal("L: 0°C"))
                    expect(subject.output.maxTemperatureValue).to(equal("H: 2°C"))
                }
                
                it("test setting weather decription") {
                    // Assert
                    expect(subject.output.weatherDescription).to(equal("Sunny"))
                }
                
                it("test setting weather icon url") {
                    // Assert
                    expect(subject.output.iconImageURL).to(equal("https://openweathermap.org/img/wn/04@2x.png"))
                }
                
                it("test setting showSavedLocationsButtonTapped action") {
                    // Arrange
                    let observer = scheduler.createObserver(Void.self)
                    subject.output.showSavedLocationsButtonTappedDriver.drive(observer).disposed(by: bag)
                    
                    // Act
                    subject.input.showSavedLocationsButtonTapped.onNext(())
                    
                    // Assert
                    observer.assertValueCount(1)
                }
                
                it("test saving location on button tapped") {
                    // Act
                    subject.input.addButtonTapped.onNext(())
                    
                    // Assert
                    expect(locationDataManagerFake.saveLocationDataCalled) == true
                }
                
                it("test cancel button tapped action") {
                    // Arrange
                    let observer = scheduler.createObserver(Void.self)
                    subject.output.cancelDriver.drive(observer).disposed(by: bag)
                    
                    // Act
                    subject.input.cancelTapped.onNext(())
                    
                    // Assert
                    observer.assertValueCount(1)
                }
            }
        }
    }
}
