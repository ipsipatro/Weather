//
//  UIViewController+Extension.swift
//  Weather
//
//  Created by Ipsi Patro on 13/03/2023.
//

import UIKit

extension UIViewController {
    private static var storyboardId: String {
        return String(describing: self)
    }

    static func instantiate(from storyboard: UIStoryboard) -> UIViewController {
        return storyboard.instantiateViewController(withIdentifier: storyboardId)
    }
}
