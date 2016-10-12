//
//  ViewController.swift
//  OnTheMap
//
//  Created by Eduard Meciar on 09/10/2016.
//  Copyright © 2016 Eduard Meciar. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func loginComplete(){
        DispatchQueue.main.async(execute: {
            self.loginTextField.text = ""
            self.passwordTextField.text = ""
            self.loginActivityIndicator.stopAnimating()
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func SignInButtonTouch(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    
    func alertError(errorString: String?){
        DispatchQueue.main.async(execute: {
            if let errorString = errorString {
                let myAlert = UIAlertController(title: errorString, message: nil, preferredStyle: UIAlertControllerStyle.alert)
                myAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(myAlert, animated: true, completion: nil)
                self.loginActivityIndicator.stopAnimating()
            }
        })
    }
    
    @IBAction func loginButtonTouch(_ sender: AnyObject) {
        loginActivityIndicator.startAnimating()
        guard let login = loginTextField?.text , loginTextField.text != "" else {
            self.alertError(errorString: "Email can't be empty")
            return
        }
        
        guard let password = passwordTextField?.text , passwordTextField.text != "" else {
            self.alertError(errorString: "Password can't be empty")
            return
        }

        UdacityClient.sharedInstance().createSesion(username: login, password: password, completitionHandler: {(success, errorString)in
            if success{
                UdacityClient.sharedInstance().getUdacityUserData(UdacityClient.sharedInstance().accountKey!) { (success, errorString) in
                    if success {
                        self.loginComplete()
                    } else {
                        self.alertError(errorString: errorString)
                    }
                }
                
            }else{
                self.alertError(errorString: errorString)
            }
        })
        
        
    }

}

