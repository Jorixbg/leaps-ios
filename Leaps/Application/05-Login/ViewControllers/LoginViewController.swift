//
//  LoginViewController.swift
//  Leaps
//
//  Created by Chavdar Nedialkov on 6/3/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    typealias T = LoginViewModel
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    var viewModel: LoginViewModel?
    var onLogin: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        asserDependencies(viewModel: viewModel)
        UIApplication.shared.statusBarStyle = .default
    }
    
    @IBAction func didPressLogin(_ sender: Any) {
        let storyboard = UIStoryboard(name: .onboarding, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let vc = factory.createStandardLoginFlowViewController(onLogin: onLogin) else {
            return
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didPressCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //this needs refactoring if time available.
    @IBAction func didPressFacebookLogin(_ sender: Any) {
        
        if FBSDKAccessToken.current() != nil {
            //request login with facebook id
            let fbID = FBSDKAccessToken.current().userID
            viewModel?.login(fbID: fbID) { [weak self] error in
                if let leapsErr = error as? LeapsError {
                    switch leapsErr {
                    case .unauthorized:
                        let prefilledData = UserSignUpStepsData()
                        prefilledData.facebookID = fbID
                        self?.createRegistrationFlow(prefilledData: prefilledData, isSocialNetworkRegistration: true, onLogin: self?.onLogin)
                    default:
                        self?.onLogin?(false)
                        print("facebook lgoin leaps error = \(error)")
                    }
                } else if error == nil {
                    NotificationCenter.default.post(name: .refreshData, object: nil)
                    self?.dismiss(animated: true) {
                        self?.onLogin?(true)
                    }
                } else {
                    self?.onLogin?(false)
                    print("facebook lgoin error = \(error)")
                }
            }
            
        } else {
            //create new account
            let manager = FBSDKLoginManager()
            manager.logOut()
            // just because of the self you can leave it here
            manager.logIn(withReadPermissions: ["email", "public_profile"], from: self) { [weak self] (result, error) in
                guard result?.isCancelled == false else { return }
                
                self?.viewModel?.requestFacebookInfo(completion: { [weak self] (result) in
                    switch result {
                    case .error(let error):
                        self?.onLogin?(false)
                        print("requestFacebookInfo error = \(error)")
                    case .success(let prefiiledData):
                        //need to handle facebook token
                        guard let fbID = prefiiledData.facebookID else {
                            return
                        }
                        
                        self?.viewModel?.login(fbID: fbID) { [weak self] error in
                            if let leapsErr = error as? LeapsError {
                                switch leapsErr {
                                case .unauthorized:
                                    self?.createRegistrationFlow(prefilledData: prefiiledData, isSocialNetworkRegistration: true, onLogin: self?.onLogin)
                                default:
                                    print("facebook lgoin leaps error = \(String(describing: error))")
                                    self?.onLogin?(false)
                                }
                            } else if error == nil {
                                NotificationCenter.default.post(name: .refreshData, object: nil)
                                self?.dismiss(animated: true) {
                                    self?.onLogin?(true)
                                }
                            } else {
                                self?.onLogin?(false)
                               print("facebook lgoin error = \(String(describing: error))")
                            }
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func didPressGoogleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func didPressCreateAccount(_ sender: Any) {
        let blankUserDetials = UserSignUpStepsData()
        createRegistrationFlow(prefilledData: blankUserDetials, isSocialNetworkRegistration: false, onLogin: onLogin)
    }
    
    func createRegistrationFlow(prefilledData data: UserSignUpStepsData?, isSocialNetworkRegistration: Bool, onLogin: ((Bool) -> Void)?) {
        let storyboard = UIStoryboard(name: .onboarding, bundle: nil)
        let factory = StoryboardViewControllerFactory(storyboard: storyboard)
        guard let registrationViewController = factory.createRegistrationFlowViewController(prefilledData: data, isSocialNetworkRegistration: isSocialNetworkRegistration, onLogin: onLogin) else {
            return
        }
        
        navigationController?.pushViewController(registrationViewController, animated: true)
    }
}

extension LoginViewController: Injectable {
    func inject(_ viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }
}

//MARK: will keep this of the network manager as it complicates stuff unnecessary
extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            
            //need to handle google token
            let goggleID = user.userID
            
            viewModel?.login(googleID: goggleID, completion: { [weak self] (error) in
                if let leapsErr = error as? LeapsError {
                    switch leapsErr {
                    case .unauthorized:
                        let fullName = user.profile.name
                        let email = user.profile.email
                        let names = fullName?.components(separatedBy: " ")
                        let firstName = names?.first ?? ""
                        let lastName = names?.last ?? ""
                        
                        let prefilledDataAndToken = UserSignUpStepsData(facebookID: nil,
                                                                        googleID: goggleID,
                                                                        firstName: firstName,
                                                                        lastName: lastName,
                                                                        email: email,
                                                                        dateAsString: nil,
                                                                        password: nil)
                        self?.createRegistrationFlow(prefilledData: prefilledDataAndToken, isSocialNetworkRegistration: true, onLogin: self?.onLogin)
                    default:
                        break
                    }
                } else if error == nil {
                    NotificationCenter.default.post(name: .refreshData, object: nil)
                    self?.navigationController?.dismiss(animated: true) {
                        self?.onLogin?(true)
                    }
                } else {
                    self?.onLogin?(false)
                    print("google sing server errpr = \(String(describing: error))")
                }
            })
        } else {
            onLogin?(false)
            print("err0r = \(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("didDisconnectWith user: GIDGoogleUser")
    }
}

extension LoginViewController: GIDSignInUIDelegate { }
