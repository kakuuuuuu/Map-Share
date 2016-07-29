//
//  LoginViewController.swift
//  ShareSearch
//
//  Created by Kyle Tsuyemura on 7/26/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController, CancelButtonDelegate, RoomTableControllerDelegate{
    
    let prefs = NSUserDefaults.standardUserDefaults()
    
    var user: NSDictionary?
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var saveSwitch: UISwitch!
    
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if let email = prefs.stringForKey("email"){
            self.emailField.text = email
        }
        if let password = prefs.stringForKey("password"){
            self.passwordField.text = password
        }
                
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let email = prefs.stringForKey("email"){
            self.emailField.text = email
        }
        if let password = prefs.stringForKey("password"){
            self.passwordField.text = password
        }
    }
    
    @IBAction func submitButtonPressed(sender: AnyObject?) {
        print(emailField.text!)
        print(passwordField.text!)
        let parameters: [String: AnyObject] = [
            "email": emailField.text!,
            "password": passwordField.text!
        ]
                Alamofire.request(.POST, "http://leforge.co/login", parameters: parameters, encoding: .JSON)
            .responseJSON { response, JSON, error in
//                print(error)
                Alamofire.request(.GET, "http://leforge.co/getuser").response { (_, _, data, error) in
                    
                    do {
                        print("FINDING")
                        if let userData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        {
                            if self.saveSwitch.on{
                                self.prefs.setValue(self.emailField.text, forKey: "email")
                                self.prefs.setValue(self.passwordField.text, forKey: "password")

                            }
                            self.emailField.text = ""
                            self.passwordField.text = ""

                            self.user = userData
                            print(self.user!["local"]!["name"]!)
                            self.performSegueWithIdentifier("loginSegue", sender: sender)
                        
                        }
                    } catch {
                        print("Something went wrong")
                    }

//                    let str = NSString(data: data!, encoding: NSUTF8StringEncoding)
//                    print(str)
//                    
//                    print(error)
                }
        }
        
    }
    
    func cancelButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logout(controller: RoomTableController){
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! RoomTableController
            controller.cancelButtonDelegate = self
            controller.delegate = self
            controller.user = self.user
            
        }
    }
    
}