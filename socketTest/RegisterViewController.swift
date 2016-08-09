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
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmField: UITextField!
    
    var user: NSDictionary?
    
    override func viewDidLoad() {
        self.emailField.delegate = self;
        self.nameField.delegate = self;
        self.passwordField.delegate = self;
        self.confirmField.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        super.viewDidLoad()
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
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
        
        Alamofire.request(.POST, "http://leforge.co/signup", parameters: parameters, encoding: .JSON)
            .responseJSON { response, JSON, error in
                Alamofire.request(.GET, "http://leforge.co/getuser").response { (_, _, data, error) in
                    
                    do {
                        print("FINDING")
                        if let userData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                        {
                            print(userData)
                            self.emailField.text = ""
                            self.nameField.text = ""
                            self.passwordField.text = ""
                            self.confirmField.text = ""
                            
                            self.user = userData
                            print(self.user!["local"]!["name"]!)
                            self.performSegueWithIdentifier("registerSegue", sender: sender)
                            
                        }
                    } catch {
                        print("Something went wrong")
                    }
                }
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "registerSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! RoomTableController
            controller.cancelButtonDelegate = self
            controller.delegate = self
            controller.user = self.user
            
        }
    }
    func cancelButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        navigationController!.popViewControllerAnimated(true)
    }
    func logout(controller: RoomTableController){
    }
}
