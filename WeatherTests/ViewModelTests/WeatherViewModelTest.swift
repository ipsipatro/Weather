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
        
        describe("Weather View Model") {
            var scheduler: TestScheduler!
            var cityDataManagerFake: CityDataManagerFake!
            var testCity: City!
            var weatherResponse: WeatherResponse!
            var bag: DisposeBag!
            
            var subject: WeatherViewModel!
            
            beforeEach {
                scheduler = TestScheduler(initialClock: 0)
                cityDataManagerFake = CityDataManagerFake()
                testCity = cityDataManagerFake.makeNewCity(name: "Test City", latitude: 1.1, longitude: 1.1)
                bag = DisposeBag()
            }
            
            context("Outputs") {
                beforeEach {
                    weatherResponse = WeatherResponse(weather: [CityWeather(description: "Sunny", icon: "04")], name: "Test City", main: MainWeather(temp: 1.2, temp_min: 0.5, temp_max: 2.3))
                    subject = WeatherViewModel(cityDataManager: cityDataManagerFake, city: testCity, weatherResponse: weatherResponse)
                }
                
                it("outputs city name as titleText") {
                    // Assert
                    expect(subject.output.titleText).to(equal("Test City"))
                }
                
                it("outputs correct temp values with right formatting") {
                    // Assert
                    expect(subject.output.temperatureValue).to(equal("1°C"))
                    expect(subject.output.minTemperatureValue).to(equal("L: 0°C"))
                    expect(subject.output.maxTemperatureValue).to(equal("H: 2°C"))
                }
                
                it("outputs correct city weather decription") {
                    // Assert
                    expect(subject.output.weatherDescription).to(equal("Sunny"))
                }
                
                it("outputs correct city weather icon url") {
                    // Assert
                    expect(subject.output.iconImageURL).to(equal("https://openweathermap.org/img/wn/04@2x.png"))
                }
                
                it("drives showCityListButtonTappedDriver output") {
                    // Arrange
                    let observer = scheduler.createObserver(Void.self)
                    subject.output.showCityListButtonTappedDriver.drive(observer).disposed(by: bag)
                    
                    // Act
                    subject.input.showCityListButtonTapped.onNext(())
                    
                    // Assert
                    observer.assertValueCount(1)
                }
                
                it("drives add output") {
                    // Act
                    subject.input.addButtonTapped.onNext(())
                    
                    // Assert
                    expect(cityDataManagerFake.saveCityDataCalled) == true
                }
            }
        }
    }
}
