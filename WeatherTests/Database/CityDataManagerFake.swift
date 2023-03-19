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
    
    func saveCityData(_ city: City) throws {
        saveCityDataCalled = true
    }
    
    func deleteCityObject(_ city: City) throws {
        deleteCityObjectCalled = true
    }
    
    func getAllSavedCities() throws -> RealmSwift.Results<City> {
        let realm = try! Realm()
        return realm.objects(City.self)
    }
    
    func getLastTappedCity() throws -> City? {
        return nil
    }
    
    func makeNewCity(name: String, latitude: Double, longitude: Double) -> City {
        return City()
    }
    
    func updateDataForCity(_ cityName: String) throws {
    }
    
    func deleteCityData(_ city: Weather.City) throws {
        deleteCityObjectCalled = true
    }
    func updateLastTappedForCity(_ cityName: String) throws {
    }
    
    func findCityByField(_ field: String, value: String) throws -> RealmSwift.Results<Weather.City> {
        let realm = try! Realm()
        return realm.objects(City.self)
    }
}
