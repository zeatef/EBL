//
//  SignInViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/3/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FacebookCore
import FacebookLogin
import SVProgressHUD

class SignInViewController: UIViewController, GIDSignInDelegate , GIDSignInUIDelegate {

    @IBOutlet weak var backgroundImage: UIImageView!
    
    let defaults = UserDefaults.standard
    let dbManager = DatabaseManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Google Sign In
    
    //Google Sign In Button
    @IBAction func googleSignInButtonPressed(_ sender: Any) {
        //Show loading indicator
        SVProgressHUD.show()
        
        //Assign SignInViewController as GoogleSignIn's Delegate
        GIDSignIn.sharedInstance()?.delegate = self
        
        //Assign SignInViewController as GoogleSignIn's UIDelegate
        GIDSignIn.sharedInstance()?.uiDelegate = self
        
        //Call Sign In Method
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print(error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let idToken = authentication.idToken!
        let accessToken = authentication.accessToken
        self.defaults.set(idToken, forKey: "GoogleIDToken")
        self.defaults.set(accessToken, forKey: "GoogleAccessToken")
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        authenticateUserToFirebase(credential: credential, signInMethod: "Google")
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    
    
    //MARK: - Facebook Sign In
    @IBAction func facebookSignInButtonPressed(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { loginResult in
            switch loginResult {
                case .failed(let error):
                    print("Error logging in using Facebook: \(error)")
                case .cancelled:
                    print("User cancelled login.")
            case .success(_, _, let accessToken):
                    //Show Loading Indicator
                    SVProgressHUD.show()

                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                    self.authenticateUserToFirebase(credential: credential, signInMethod: "Facebook")
                    print("Logged in!")
            }
        }
    }
    
    //MARK: - Authenticate User To Firebase
    func authenticateUserToFirebase(credential: AuthCredential, signInMethod: String) {
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error as NSError? {
                switch error.code {
                    case AuthErrorCode.accountExistsWithDifferentCredential.rawValue :
                        if (signInMethod == "Facebook") {
                            //Sign in with Google Silently
                            if let idToken = self.defaults.string(forKey: "GoogleIDToken") {
                                if let accessToken = self.defaults.string(forKey: "GoogleAccessToken") {
                                    let registeredCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                                    self.signInUserSilently(credential: registeredCredential)
                                    self.linkUserAccounts(credential: credential)
                                }
                            }
                        }
                    default :
                        print("Error Authenticating User To Firebase: \(error)")
                    }
            } else {
                // User is signed in
                // ...
                print("Authenticated to Firebase")
                self.dbManager.setupApplicationDatabase { (error, errorCode) in
                    if let error = error {
                        print("Error Setting Up Application Database, \(errorCode!): \(error)")
                    } else {
                        SVProgressHUD.dismiss()
                        self.performSegue(withIdentifier: "SignInToHome", sender: self)
                    }
                }
            }
        }
    }
    
    func signInUserSilently(credential: AuthCredential) {
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print("Error Signing In Silently: \(error)")
            } else {
                print("Signed In Silently")
            }
        }
    }
    
    func linkUserAccounts(credential: AuthCredential) {
        let registeredUser = Auth.auth().currentUser
        registeredUser?.linkAndRetrieveData(with: credential, completion: { (linkingResult, error) in
            if let linkingError = error {
                print("Error Linking Accounts: \(linkingError)")
            } else {
                print("Accounts Linked Successfully")
                self.dbManager.setupApplicationDatabase { (error, errorCode) in
                    if let error = error {
                        print("Error Setting Up Application Database, \(errorCode!): \(error)")
                    } else {
                        SVProgressHUD.dismiss()
                        self.performSegue(withIdentifier: "SignInToHome", sender: self)
                    }
                }
            }
        })
    }
}
