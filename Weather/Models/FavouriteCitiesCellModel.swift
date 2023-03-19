//
//  FavouriteCitiesCellViewModel.swift
//  Weather
//
//  Created by Ipsi Patro on 15/03/2023.
//

import Foundation

struct FavouriteCitiesCellModel {
    let city: City
    
    // MARK: - Instantiate
    init(city: City) {
        self.city = city
    }
}
