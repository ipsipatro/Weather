//
//  LocationDataManagerFake.swift
//  WeatherTests
//
//  Created by Ipsi Patro on 18/03/2023.
//

import Foundation
import RealmSwift
@testable import Weather

class LocationDataManagerFake: DatabaseCapable {
    private(set) var saveLocationDataCalled = false
    private(set) var deleteLocationObjectCalled = false
    
    func saveLocationData(_ location: Weather.Location) throws {
        saveLocationDataCalled = true
    }
    
    func updateLastTappedForLocation(_ locationName: String) throws {
    }
    
    func deleteLocationData(_ location: Weather.Location) throws {
        deleteLocationObjectCalled = true
    }
    
    func getLastTappedLocation() throws -> Weather.Location? {
        return nil
    }
    
    func getAllSavedLocations() throws -> RealmSwift.Results<Weather.Location> {
        let realm = try! Realm()
        return realm.objects(Location.self)
    }
    
    func makeANewLocationWith(_ name: String, latitude: Double, longitude: Double) -> Weather.Location {
        return Location()
    }
}
