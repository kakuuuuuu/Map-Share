//
//  AddUserViewController.swift
//  socketTest
//
//  Created by Kyle Tsuyemura on 7/28/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import UIKit
import Alamofire

class AddUserViewController: UIViewController, UITextFieldDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Variables
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Initialize variables for data passed by RoomTableController
    var roomID: String?
    
    // Initialize UI elements
    @IBOutlet weak var addUserField: UITextField!
    
    // Makes server call to add user to room when form is submitted
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let parameters: [String: AnyObject] = [
            "user": [
                "email": addUserField.text!
            ]
        ]
        addUserField.text = ""
        Alamofire.request(.POST, "http://leforge.co/roomUser/"+self.roomID!, parameters: parameters, encoding: .JSON)
        self.view.endEditing(true)
        return false
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Dismisses keyboard
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // Dismisses keyboard when editing ends
    @IBAction func editingDidEnd(sender: UITextField) {
        dismissKeyboard()
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Server Call / Initialize View
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addUserField.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
}
