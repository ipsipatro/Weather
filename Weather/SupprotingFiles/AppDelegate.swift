//
//  AppDelegate.swift
//  Weather
//
//  Created by Ipsi Patro on 13/03/2023.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var coordinator: MainCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // create the main navigation controller to be used for our app
            let navController = UINavigationController()

            // send that into our coordinator so that it can display view controllers
            coordinator = MainCoordinator(navigationController: navController)

            // tell the coordinator to take over control
            coordinator?.start()

            // create a basic UIWindow and activate it
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = navController
            window?.makeKeyAndVisible()

            return true
    }


}

