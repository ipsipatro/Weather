//
//  CityDataManagerFake.swift
//  WeatherTests
//
//  Created by Ipsi Patro on 18/03/2023.
//

import Foundation
import RealmSwift
@testable import Weather

class CityDataManagerFake: DatabaseCapable {
    private(set) var saveCityDataCalled = false
    private(set) var deleteCityObjectCalled = false
    
    func saveCityData(_ city: City) {
        saveCityDataCalled = true
    }
    
    func deleteCityObject(_ city: City) {
        deleteCityObjectCalled = true
    }
    
    func getAllSavedCities() -> RealmSwift.Results<City> {
        let realm = try! Realm()
        return realm.objects(City.self)
    }
    
    func getLastTappedCity() -> City? {
        return nil
    }
    
    func makeNewCity(name: String, latitude: Double, longitude: Double) -> City {
        return City()
    }
}
