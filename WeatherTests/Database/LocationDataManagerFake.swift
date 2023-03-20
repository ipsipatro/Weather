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
    
    func saveLocationData(_ location: Location) throws {
        saveLocationDataCalled = true
    }
    
    func updateLastTappedForLocation(_ locationName: String) throws {
    }
    
    func deleteLocationData(_ location: Location) throws {
        deleteLocationObjectCalled = true
    }
    
    func getLastTappedLocation() throws -> Location? {
        return nil
    }
    
    func getAllSavedLocations() throws -> RealmSwift.Results<Location> {
        let realm = try! Realm()
        return realm.objects(Location.self)
    }
    
    func makeANewLocationWith(_ name: String, latitude: Double, longitude: Double) -> Location {
        return Location()
    }
}
