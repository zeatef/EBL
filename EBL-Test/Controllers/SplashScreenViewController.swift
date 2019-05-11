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
        
        
//        dbManager.AddTeamImageURLToLocal(team: "League")
        
//        populateDatabase(tag: 4)
                
        setupLoadingInidicator()
        setupSideMenu()
    }
    
    func populateDatabase(tag: Int) {
        switch tag {
        case 0:
            databaseSetter.AddAllTeams { (error) in
                if error == nil {
                    print("Added All Teams Successfully")
                }
            }
        case 1:
            databaseSetter.AddAllPlayersTotalStats { (error) in
                if error == nil {
                    print("Adding Player Total Stats Completed")
                }
            }
        case 2:
            databaseSetter.AddAllTeamGameStats(completion: { (error) in
                if error == nil {
                    print("Adding Team Game Stats Completed")
                }
            })
        case 3:
            databaseSetter.AddAllTeamTotalStats(completion: { (error) in
                if error == nil {
                    print("Adding Team Total Stats Completed")
                }
            })
        case 4:
            databaseSetter.convertPlayerDates(completion: { (error) in
                if error == nil {
                    print("Converting All Player Birth Dates Completed")
                }
            })
        default:
            print("None")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.dbManager.setupApplicationDatabase { (error, errorCode) in
                    if let error = error {
                        print("Error Setting Up Application Database, \(errorCode!): \(error)")
                    } else {
                        self.performSegue(withIdentifier: "SplashToHome", sender: self)
                    }
                }
            } else {
                self.performSegue(withIdentifier: "SplashToSignIn", sender: self)
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
