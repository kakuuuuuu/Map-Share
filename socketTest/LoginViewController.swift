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
    // Initialize and assign variables to UI
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var saveSwitch: UISwitch!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    // Grabs user defaults for saved user email and password if available
    func setDefaults(){
        if let email = prefs.stringForKey("email"){
            self.emailField.text = email
        }
        if let password = prefs.stringForKey("password"){
            self.passwordField.text = password
        }

    }
    
    override func viewDidLoad() {
        // Sets defaults if available
        setDefaults()
        loginButton.layer.cornerRadius = 7
        super.viewDidLoad()
        
    }
    override func viewDidAppear(animated: Bool) {
        // Sets defaults if available
        setDefaults()
        super.viewDidAppear(animated)

    }
    
    // Attempt to log in
    @IBAction func submitButtonPressed(sender: AnyObject?) {
        // sets parameters to pass to server
        let parameters: [String: AnyObject] = [
            "email": emailField.text!,
            "password": passwordField.text!
        ]
                // Posts email and password to server
                Alamofire.request(.POST, "http://leforge.co/login", parameters: parameters, encoding: .JSON)
                    .responseJSON { response, JSON, error in
                        
                // Requests response from server
                Alamofire.request(.GET, "http://leforge.co/getuser").response { (_, _, data, error) in
                    do {
                        print("FINDING")
                        // Logs user in if user data is returned
                        if let userData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        {
                            // Saves information to user defaults if UI Switch is on
                            if self.saveSwitch.on{
                                self.prefs.setValue(self.emailField.text, forKey: "email")
                                self.prefs.setValue(self.passwordField.text, forKey: "password")

                            }
                            // Empties information fields
                            self.emailField.text = ""
                            self.passwordField.text = ""

                            // Grabs user data
                            self.user = userData
                            // Segue on successful log in
                            self.performSegueWithIdentifier("loginSegue", sender: sender)
                        
                        }
                        // does not log user in
                    } catch {
                        print("Something went wrong")
                    }
                }
        }
        
    }
    
    func cancelButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logout(controller: RoomTableController){
    }
    
    // Performs segue to RoomTableController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! RoomTableController
            controller.cancelButtonDelegate = self
            controller.delegate = self
            // Passes user data to next view
            controller.user = self.user
            
        }
    }

}