//
//  SavedLocationCellModel.swift
//  Weather
//
//  Created by Ipsi Patro on 15/03/2023.
//

import Foundation

struct SavedLocationCellModel {
    let location: Location
    
    // MARK: - Instantiate
    init(location: Location) {
        self.location = location
    }
}
