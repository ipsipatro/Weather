//
//  LocationDataManagerTest.swift
//  WeatherTests
//
//  Created by Ipsi Patro on 18/03/2023.
//

import Quick
import RealmSwift
@testable import Weather

class LocationDataManagerTest: QuickSpec {
    override func spec() {
        super.spec()
        describe("Location Databse Manager") {
            var locationDataManager: LocationDataManager!
            var identifier = "Tests"
            beforeEach {
                let config = Realm.Configuration(
                    inMemoryIdentifier: identifier)
                let realm = try! Realm(configuration: config)
                locationDataManager = LocationDataManager(realm)
            }
            
            context("Database functioning") {
                it("test saving data to database") {
                    do {
                        // Arrange
                        let location = locationDataManager.makeANewLocationWith("Test Location", latitude: 0.0, longitude: 0.0)
                        identifier = "Test One"

                        // Act
                        try locationDataManager.saveLocationData(location)
                        
                        // Assert
                        let locationsList = try locationDataManager.getAllSavedLocations()
                        XCTAssertEqual(locationsList.count, 1)
                        
                    } catch RuntimeError.NoRealmSet {
                        XCTAssert(false, "No realm database was set")
                    } catch {
                        XCTAssert(false, "Unexpected error \(error)")
                    }
                }
                
                it("test update tapped data to database and fetch last tapped location") {
                    do {
                        // Arrange
                        // Save two new cities to the database
                        identifier = "Test two"
                        let firstLocation = locationDataManager.makeANewLocationWith("First Location", latitude: 0.0, longitude: 0.0)
                        let secondLocation = locationDataManager.makeANewLocationWith("Second Location", latitude: 0.0, longitude: 0.0)
                        try locationDataManager.saveLocationData(firstLocation)
                        try locationDataManager.saveLocationData(secondLocation)
                        try locationDataManager.updateLastTappedForLocation(firstLocation.name)
                        
                        // Act
                        // update lastTapped time for the first location
                        let lastTappedLocation = try locationDataManager.getLastTappedLocation()
                        
                        // Assert
                        XCTAssertEqual(lastTappedLocation?.name, "First Location")
                    } catch RuntimeError.NoRealmSet {
                        XCTAssert(false, "No realm database was set")
                    } catch {
                        XCTAssert(false, "Unexpected error \(error)")
                    }
                }
                
                it("test delete location from database") {
                    do {
                        // Arrange
                        identifier = "Test Three"
                        let oldLocation = locationDataManager.makeANewLocationWith("Old Location", latitude: 0.0, longitude: 0.0)
                        try locationDataManager.saveLocationData(oldLocation)
                        let newLocation = locationDataManager.makeANewLocationWith("New Location", latitude: 0.0, longitude: 0.0)
                        try locationDataManager.saveLocationData(newLocation)
                        
                        // Act
                        try locationDataManager.deleteLocationData(newLocation)
                        
                        // Assert
                        let locationsList = try locationDataManager.getAllSavedLocations()
                        XCTAssertEqual(locationsList.count, 1)
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
