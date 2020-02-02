//
//  SplashScreenViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/7/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import NVActivityIndicatorView
import ChameleonFramework
import SideMenu

class SplashScreenViewController: UIViewController {
    
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    let dbManager = DatabaseManager()
    
    let databaseSetter = DatabaseSetter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let start = DispatchTime.now()
//        dbManager.getLeagueAverages { (stats, error) in
//            if let error = error {
//                print(error)
//            } else {
//                let end = DispatchTime.now()
//                let difference = end.uptimeNanoseconds - start.uptimeNanoseconds
//                print("Get League Averages Completed in \(Double(difference) / 1_000_000_000) seconds.")
//                print(stats!)
//            }
//        }
        
        setupLoadingInidicator()
        setupSideMenu()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        let start = DispatchTime.now()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.dbManager.setupApplication { (error) in
                    if let error = error {
                        print("Error Setting Up Application Database: \(error)")
                    } else {
                        let end = DispatchTime.now()
                        let difference = end.uptimeNanoseconds - start.uptimeNanoseconds
                        print("Setup Application Completed in \(Double(difference) / 1_000_000_000) seconds.")
                        self.performSegue(withIdentifier: "SplashToHome", sender: self)
                    }
                }
            } else {
                print("Error: No User Authenticated!!! Add Login Page")
            }
        }
    }
    
    //MARK: - Loading Indicatior Setup
    func setupLoadingInidicator() {
        loadingView.color = UIColor.flatOrange()
        loadingView.type = NVActivityIndicatorType.ballBeat
        loadingView.startAnimating()
    }
    
    //MARK: - SideMenu Setup
    
    func setupSideMenu() {
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as! UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
        
        //Side Menu Options
        SideMenuManager.defaultManager.menuPresentMode = .menuSlideIn
        SideMenuManager.defaultManager.menuAnimationFadeStrength = 0.4
        SideMenuManager.defaultManager.menuFadeStatusBar = false
        SideMenuManager.defaultManager.menuWidth =  max(round(min((UIScreen.main.bounds.width), (UIScreen.main.bounds.height)) * 0.50), 240)
    }
}
