//
//  LocationDataManager.swift
//  Weather
//
//  Created by Ipsi Patro on 15/03/2023.
//

import Foundation
import RealmSwift

protocol DatabaseCapable {
    func saveLocationData(_ location: Location) throws
    func updateLastTappedForLocation(_ locationName: String) throws
    func deleteLocationData(_ location: Location) throws
    func getLastTappedLocation() throws -> Location?
    func getAllSavedLocations() throws -> Results<Location>
    func makeANewLocationWith(_ name: String, latitude: Double, longitude: Double ) -> Location
}

enum RuntimeError: Error {
    case NoRealmSet
}

class LocationDataManager: DatabaseCapable {

    var realm: Realm?
    var lastTappedLocation: Location?
    
    // MARK: - Instantiate
    init(_ realm: Realm) {
        self.realm = realm
    }
    
    func saveLocationData(_ location: Location) throws {
        if (realm != nil) {
            guard let location = realm!.objects(Location.self).filter("name == %@", location.name).first else {
                // Add the location to the list if not present
                try! realm!.write {
                    realm!.add(location)
                }
                return
            }
            // Update the lastTapped property to the current date
            try! realm!.write {
                location.lastTapped = Date()
            }
        } else {
            throw RuntimeError.NoRealmSet
        }
    }
    
    func updateLastTappedForLocation(_ locationName: String) throws {
        let location = try findLocationByField("name", value: locationName)
        try! realm!.write {
            location.setValue(Date(), forKey: "lastTapped")
        }
    }
    
    private func findLocationByField(_ field: String, value: String) throws -> Results<Location> {
        if (realm != nil) {
            let predicate = NSPredicate(format: "%K = %@", field, value)
            return realm!.objects(Location.self).filter(predicate)
        } else {
            throw RuntimeError.NoRealmSet
        }
    }
    
    func deleteLocationData(_ location: Location) throws {
        if (realm != nil) {
            guard let targetLocation = realm!.objects(Location.self).filter("name == %@", location.name).first else {
                return
            }
            try! realm!.write {
                realm!.delete(targetLocation)
            }
        } else {
            throw RuntimeError.NoRealmSet
        }
    }
    
    func getLastTappedLocation() throws -> Location? {
        if (realm != nil) {
            let lastTappedLocation = realm!.objects(Location.self).filter("lastTapped != nil").sorted(byKeyPath: "lastTapped", ascending: false).first
            
            return lastTappedLocation
        } else {
            throw RuntimeError.NoRealmSet
        }
    }
    
    func getAllSavedLocations() throws -> Results<Location> {
        if (realm != nil) {
            let objects = realm!.objects(Location.self)
            return objects
        } else {
            throw RuntimeError.NoRealmSet
        }
    }
    
    func makeANewLocationWith(_ name: String, latitude: Double, longitude: Double ) -> Location {
        let newLocation = Location()
        newLocation.name = name
        newLocation.latitude = latitude
        newLocation.longitude = longitude
        newLocation.lastTapped = Date()
        return newLocation
    }
}


