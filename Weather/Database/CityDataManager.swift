//
//  CityDetailsProvider.swift
//  Weather
//
//  Created by Ipsi Patro on 15/03/2023.
//

import Foundation
import RealmSwift

class CityDataManager {
    var realm: Realm = try! Realm()
    var lastTappedCity: City?
    
    
    public func saveCityDetails(_ city: City) {
        try! realm.write {
            realm.add(city)
        }
    }
    
    func getAllObjects<T: Object>(_ objectType: City.Type) -> Results<T> {
        let objects = realm.objects(T.self)
        return objects
    }
    
    public func findCityByName(_ name: String) -> Results<City> {
        let predicate = NSPredicate(format: "name = %@", name)
        return realm.objects(City.self).filter(predicate)
    }
    
    public func makeNewCity(_ name: String, latitude: Double, longitude: Double ) -> City {
        let newCity = City()
        newCity.name = name
        newCity.latitude = latitude
        newCity.longitude = longitude
        return newCity
    }
}


