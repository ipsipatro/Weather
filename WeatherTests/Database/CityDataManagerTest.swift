//
//  CityDataManagerTest.swift
//  WeatherTests
//
//  Created by Ipsi Patro on 18/03/2023.
//

import Quick
import RealmSwift
@testable import Weather

class CityDataManagerTest: QuickSpec {
    override func spec() {
        super.spec()
        describe("City Databse Manager") {
            var cityDataManager: CityDataManager!
            var identifier = "Tests"
            beforeEach {
                let config = Realm.Configuration(
                    inMemoryIdentifier: identifier)
                let realm = try! Realm(configuration: config)
                cityDataManager = CityDataManager(realm)
            }
            
            context("Database functioning") {
                it("test saving data to database") {
                    do {
                        // Arrange
                        let city = cityDataManager.makeNewCity(name: "Test City", latitude: 0.0, longitude: 0.0)
                        identifier = "Test One"

                        // Act
                        try cityDataManager.saveCityData(city)
                        
                        // Assert
                        let cityList = try cityDataManager.getAllSavedCities()
                        XCTAssertEqual(cityList.count, 1)
                        
                    } catch RuntimeError.NoRealmSet {
                        XCTAssert(false, "No realm database was set")
                    } catch {
                        XCTAssert(false, "Unexpected error \(error)")
                    }
                }
                
                it("test update tapped data to database and fetch last tapped city") {
                    do {
                        // Arrange
                        // Save two new cities to the database
                        identifier = "Test two"
                        let firstCity = cityDataManager.makeNewCity(name: "First City", latitude: 0.0, longitude: 0.0)
                        let secondCity = cityDataManager.makeNewCity(name: "Second City", latitude: 0.0, longitude: 0.0)
                        try cityDataManager.saveCityData(firstCity)
                        try cityDataManager.saveCityData(secondCity)
                        try cityDataManager.updateLastTappedForCity(firstCity.name)
                        
                        // Act
                        // update lastTapped time for the first city
                        let lastTappedCity = try cityDataManager.getLastTappedCity()
                        
                        // Assert
                        XCTAssertEqual(lastTappedCity?.name, "First City")
                    } catch RuntimeError.NoRealmSet {
                        XCTAssert(false, "No realm database was set")
                    } catch {
                        XCTAssert(false, "Unexpected error \(error)")
                    }
                }
                
                it("test delete city from database") {
                    do {
                        // Arrange
                        identifier = "Test Three"
                        let oldCity = cityDataManager.makeNewCity(name: "Old City", latitude: 0.0, longitude: 0.0)
                        try cityDataManager.saveCityData(oldCity)
                        let newCity = cityDataManager.makeNewCity(name: "New City", latitude: 0.0, longitude: 0.0)
                        try cityDataManager.saveCityData(newCity)
                        
                        // Act
                        try cityDataManager.deleteCityData(newCity)
                        
                        // Assert
                        let cityList = try cityDataManager.getAllSavedCities()
                        XCTAssertEqual(cityList.count, 1)
                    } catch RuntimeError.NoRealmSet {
                        XCTAssert(false, "No realm database was set")
                    } catch {
                        XCTAssert(false, "Unexpected error \(error)")
                    }
                }
                
            }
            
        }
    }
}
