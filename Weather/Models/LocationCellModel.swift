//
//  LocationCellModel.swift
//  Weather
//
//  Created by Ipsi Patro on 15/03/2023.
//

import Foundation
import MapKit

struct LocationCellModel {
    let result: MKLocalSearchCompletion
    
    // MARK: - Instantiate
    init(result: MKLocalSearchCompletion) {
        self.result = result
    }
}
