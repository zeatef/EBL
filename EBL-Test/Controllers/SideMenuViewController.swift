//
//  RootTableViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/12/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Firebase

class SideMenuViewController: UITableViewController {

    var parentSender : UIViewController = UIViewController()
    var zodiac = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(zodiac)
    }
    
    @IBAction func dismissSideMenuButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch (indexPath.row) {
            case 1:
                dismiss(animated: true, completion: nil)
                parentSender.performSegue(withIdentifier: "goToTeams", sender: parentSender)
            default:
                print("nothing")
            }
        case 1:
            switch (indexPath.row) {
            case 0:
                signOut()
            default:
                print("nothing")
            }
        default:
            print("nothing")
        }
    }
    
    func signOut(){
        dismiss(animated: true, completion: nil)

        let signOutAlert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        
        let okAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
            do {
                try Auth.auth().signOut()
                
                //Change Root VC to SignInVC
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "SignInViewController")
                UIApplication.shared.keyWindow?.rootViewController = viewController
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        // Add the actions
        signOutAlert.addAction(okAction)
        signOutAlert.addAction(cancelAction)
        
        
        // Present the controller
        parentSender.present(signOutAlert, animated: true, completion: nil)
    }
}
