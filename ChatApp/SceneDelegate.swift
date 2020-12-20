//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Artyom Mihailovich on 9/26/20.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        autoLogin()
        resetBudge()
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        resetBudge()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        LocationManager.shared.startUpdating()
        resetBudge()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        LocationManager.shared.stopUpdating()
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        resetBudge()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        LocationManager.shared.stopUpdating()
        resetBudge()
    }

    
    //MARK: - Autologin
    
    func autoLogin() {
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil && userDefaults.object(forKey: kCURRENTUSER) != nil {
                
                //Go to main thread
                DispatchQueue.main.async {
                    self.goToApp()
                }
            }
        })
    }
    
    private func goToApp() {
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        
        self.window?.rootViewController = mainView
    }
    
    private func resetBudge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

