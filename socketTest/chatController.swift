//
//  chatController.swift
//  socketTest
//
//  Created by Kyle Tsuyemura on 7/27/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import UIKit
import Alamofire
import SocketIOClientSwift

class ChatController: UIViewController, UITextFieldDelegate {
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Variables
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Initialize variables for data passed by RoomTableController
    weak var user: NSDictionary?
    var roomID: String?
    weak var cancelButtonDelegate: CancelButtonDelegate?
    
    // Initialize UI elements
    @IBOutlet weak var newChatField: UITextField!
    
    // Initializes socket library
    let socket = SocketIOClient(socketURL: NSURL(string: "http://leforge.co")!, options: [.Reconnects(true)])

    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Removes placeholder when editing begins
    @IBAction func editingDidBegin(sender: AnyObject) {
        self.newChatField.placeholder = ""
    }
    // Resets placeholder if textfield is empty
    @IBAction func editingDidEndMessage(sender: UITextField) {
        if self.newChatField.text == "" {
            self.newChatField.placeholder = "Enter message here"
        }
    }
    
    // Dismisses Keyboard
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // Submit comment
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        // Sets comment data parameters
        let parameters: [String: AnyObject] = [
            "user": self.user!,
            "comment": [
                "text": self.newChatField.text!
            ]
        ]
        // Posts comment data to server
        Alamofire.request(.POST, "http://leforge.co/createComment/"+self.roomID!, parameters: parameters, encoding: .JSON)
        
        // Initializes message object to send through socket
        let message: NSDictionary = [
            "room": self.roomID!,
            "user": self.user!,
            "message": self.newChatField.text!
        ]
        
        // Resets chat field
        self.newChatField.text = ""
        
        // Sends comment to all connected users in the room
        self.socket.emit("sendMessage", message)
        
        return false
    }
    
    // Dismisses keyboard when editing ends
    @IBAction func editingDidEnd(sender: UITextField) {
        dismissKeyboard()
    }
    
    // Sends notification to MapViewControllet to dismiss self back to RoomTableController
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().postNotificationName("back", object: nil)
        print("dismiss")
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
    }

    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Server Call / Initialize View
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        
        // Set chat field placeholder
        self.newChatField.placeholder = "Enter message here"
        
        super.viewDidLoad()
        
        // Sets view as chat field delegate
        self.newChatField.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        self.socket.connect()
        socket.on("connect") {data, ack in
            print("socket connected")
            let id = self.roomID!
            self.socket.emit("joinRoom", id)
        }
        
        // Confirm room joined
        socket.on("roomJoined") {data, ack in
            print(data)
        }

    }
    
    // Segue to pass data to child table view
    // NOTE: Does not transition to completely new view, only passes chat data due to issues directly connecting sockets to table views
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embeddedTableSegue" {
            let childViewController = segue.destinationViewController as! ChatViewController
            childViewController.user = self.user!
            childViewController.roomID = self.roomID!
        }
        
    }
}