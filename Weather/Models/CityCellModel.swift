//
//  CityCellViewModel.swift
//  Weather
//
//  Created by Ipsi Patro on 15/03/2023.
//

import Foundation
import MapKit

struct CityCellModel {
    let result: MKLocalSearchCompletion
    
    // MARK: - Instantiate
    init(result: MKLocalSearchCompletion) {
        self.result = result
    }
}
