//
//  RegisterViewController.swift
//  socketTest
//
//  Created by Kyle Tsuyemura on 7/28/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import UIKit
import Alamofire


class RegisterViewController: UIViewController, CancelButtonDelegate, RoomTableControllerDelegate, UITextFieldDelegate{
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Variables
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Initialize form UI elements
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    // Intialize user variable
    var user: NSDictionary?
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Dismisses Keyboard
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // Adds r
    @IBAction func submitButtonPressed(sender: UIButton) {
        print(emailField.text)
        print(nameField.text)
        print(passwordField.text)
        print(confirmField.text)
        let parameters :[String: AnyObject] = [
            "email": emailField.text!,
            "name": nameField.text!,
            "password": passwordField.text!,
            "confirm" : confirmField.text!
        ]
        // POST user data to server
        Alamofire.request(.POST, "http://leforge.co/signup", parameters: parameters, encoding: .JSON)
            .responseJSON { response, JSON, error in
                
                // GET request for user data to check for success
                Alamofire.request(.GET, "http://leforge.co/getuser").response { (_, _, data, error) in
                    do {
                        print("FINDING")
                        if let userData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        {
                            // Reset form fields on success
                            self.emailField.text = ""
                            self.nameField.text = ""
                            self.passwordField.text = ""
                            self.confirmField.text = ""
                            self.user = userData
                            print(self.user!["local"]!["name"]!)
                            // Perform Segue on success
                            self.performSegueWithIdentifier("registerSegue", sender: sender)
                        }
                    } catch {
                        print("Something went wrong")
                    }
                }
        }
    }
    
    // Dismisses view when cancel button is pressed
    func cancelButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        navigationController!.popViewControllerAnimated(true)
    }
    func logout(controller: RoomTableController){
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Server Call / Initialize View
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        self.emailField.delegate = self;
        self.nameField.delegate = self;
        self.passwordField.delegate = self;
        self.confirmField.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        super.viewDidLoad()
    }
    
    // Segue to RoomTableController on successful registration
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "registerSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! RoomTableController
            controller.cancelButtonDelegate = self
            controller.delegate = self
            controller.user = self.user
            
        }
    }
    
}
