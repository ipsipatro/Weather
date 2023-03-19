//
//  Coordinator.swift
//  Weather
//
//  Created by Ipsi Patro on 13/03/2023.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController { get set }

    func start()
}
