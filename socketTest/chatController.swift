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
    
    weak var user: NSDictionary?
    var roomID: String?
    
    weak var cancelButtonDelegate: CancelButtonDelegate?
    
    @IBOutlet weak var newChatField: UITextField!
    
    let socket = SocketIOClient(socketURL: NSURL(string: "http://leforge.co")!, options: [.Reconnects(true)])
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newChatField.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        self.socket.connect()
        socket.on("connect") {data, ack in
            print("socket connected")
            let id = self.roomID!
            self.socket.emit("joinRoom", id)
        }
        
        socket.on("roomJoined") {data, ack in
            print(data)
        }

    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embeddedTableSegue" {
            let childViewController = segue.destinationViewController as! ChatViewController
            childViewController.user = self.user!
            childViewController.roomID = self.roomID!
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        let parameters: [String: AnyObject] = [
            "user": self.user!,
            "comment": [
                "text": self.newChatField.text!
            ]
        ]
        Alamofire.request(.POST, "http://leforge.co/createComment/"+self.roomID!, parameters: parameters, encoding: .JSON)
        
        
        let message: NSDictionary = [
            "room": self.roomID!,
            "user": self.user!,
            "message": self.newChatField.text!
        ]
        self.newChatField.text = ""
        print("SENDING")
        self.socket.emit("sendMessage", message)
        return false
    }
    
    
    
    @IBAction func editingDidEnd(sender: UITextField) {
        dismissKeyboard()
    }
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        NSNotificationCenter.defaultCenter().postNotificationName("back", object: nil)
        print("dismiss")
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
    }

    
    
    
    
}