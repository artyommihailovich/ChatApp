//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 9/26/20.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //MARK: - Variables
    
    var firstRun: Bool?

    
    //MARK: - Application
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        firstCheckRun()
        LocationManager.shared.startUpdating()
        return true
    }

    
    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {

   
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
    
    
    //MARK: - First run
    
    private func firstCheckRun() {
        firstRun = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstRun! {
            let status = Status.allCases.map {$0.rawValue}
            userDefaults.set(status,forKey: kSTATUS)
            userDefaults.set(true, forKey: kFIRSTRUN)
            
            userDefaults.synchronize()
        }
    }
}
