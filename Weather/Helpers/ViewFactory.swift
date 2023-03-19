//
//  ViewFactory.swift
//  Weather
//
//  Created by Ipsi Patro on 13/03/2023.
//

import UIKit

struct ViewFactory {
    let storyboards = StoryboardFactory()
}

struct StoryboardFactory {
    let main = MainStoryboard()
}

struct MainStoryboard {
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    var weatherViewController: WeatherViewController {
        return WeatherViewController.instantiate(from: storyboard) as! WeatherViewController
    }
    
    var locationSearchViewController: LocationSearchViewController {
        return LocationSearchViewController.instantiate(from: storyboard) as! LocationSearchViewController
    }
}
