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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonTouch(_ sender: AnyObject) {
        print("login start")
        var username: String? = "eduard.meciar@gmail.com"
        var password: String? = "cislokleslo"
        
        UdacityClient.sharedInstance().createSesion(username: username!, password: password!, completitionHandler: {(success, errorString)in
            if success{
                print("login success")
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                self.present(controller, animated: true, completion: nil)
            }else{
                print("login failed")
            }
        })
        
        
    }

}

