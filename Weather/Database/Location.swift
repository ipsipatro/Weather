//
//  Location.swift
//  Weather
//
//  Created by Ipsi Patro on 15/03/2023.
//

import Foundation
import RealmSwift

class Location: Object {
  @objc dynamic var name = ""
  @objc dynamic var latitude = 0.0
  @objc dynamic var longitude = 0.0
  @objc dynamic var lastTapped: Date? = nil
}

