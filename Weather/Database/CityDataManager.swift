//
//  CityDataManager.swift
//  Weather
//
//  Created by Ipsi Patro on 15/03/2023.
//

import Foundation
import RealmSwift

protocol DatabaseCapable {
    func getAllSavedCities() throws -> Results<City>
    func saveCityData(_ city: City) throws
    func updateLastTappedForCity(_ cityName: String) throws
    func deleteCityData(_ city: City) throws
    func getLastTappedCity() throws -> City?
    func makeNewCity(name: String, latitude: Double, longitude: Double ) -> City
}

enum RuntimeError: Error {
    case NoRealmSet
}

class CityDataManager: DatabaseCapable {
    var realm: Realm?
    var lastTappedCity: City?
    
    // MARK: - Instantiate
    init(_ realm: Realm) {
        self.realm = realm
    }
    
    func saveCityData(_ city: City) throws {
        if (realm != nil) {
            guard let city = realm!.objects(City.self).filter("name == %@", city.name).first else {
                // Add the city to the list if not present
                try! realm!.write {
                    realm!.add(city)
                }
                return
            }
            // Update the lastTapped property to the current date
            try! realm!.write {
                city.lastTapped = Date()
            }
        } else {
            throw RuntimeError.NoRealmSet
        }
    }
    
    func updateLastTappedForCity(_ cityName: String) throws {
        let city = try findCityByField("name", value: cityName)
        try! realm!.write {
            city.setValue(Date(), forKey: "lastTapped")
        }
    }
    
    private func findCityByField(_ field: String, value: String) throws -> Results<City> {
        if (realm != nil) {
            let predicate = NSPredicate(format: "%K = %@", field, value)
            return realm!.objects(City.self).filter(predicate)
        } else {
            throw RuntimeError.NoRealmSet
        }
    }
    
    func deleteCityData(_ city: City) throws {
        if (realm != nil) {
            guard let targetCity = realm!.objects(City.self).filter("name == %@", city.name).first else {
                return
            }
            try! realm!.write {
                realm!.delete(targetCity)
            }
        } else {
            throw RuntimeError.NoRealmSet
        }
    }
    
    func getLastTappedCity() throws -> City? {
        if (realm != nil) {
            let lastTappedCity = realm!.objects(City.self).filter("lastTapped != nil").sorted(byKeyPath: "lastTapped", ascending: false).first
            
            return lastTappedCity
        } else {
            throw RuntimeError.NoRealmSet
        }
    }
    
    func getAllSavedCities() throws -> Results<City> {
        if (realm != nil) {
            let objects = realm!.objects(City.self)
            return objects
        } else {
            throw RuntimeError.NoRealmSet
        }
    }
    
    func makeNewCity(name: String, latitude: Double, longitude: Double ) -> City {
        let newCity = City()
        newCity.name = name
        newCity.latitude = latitude
        newCity.longitude = longitude
        newCity.lastTapped = Date()
        return newCity
    }
}


