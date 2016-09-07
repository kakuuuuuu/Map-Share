//
//  NewRoomTableController.swift
//  ShareSearch
//
//  Created by Kyle Tsuyemura on 7/26/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import UIKit

class NewRoomTableController: UITableViewController{
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Variables
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    weak var cancelButtonDelegate: CancelButtonDelegate?
    weak var delegate: NewRoomTableControllerDelegate?
    weak var user: NSDictionary?
    
    @IBOutlet weak var newRoomName: UITextField!
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
    }
    
    @IBAction func doneBarButtonPressed(sender: UIBarButtonItem) {
            let room = newRoomName.text!
            delegate?.newRoomTableController(self, didFinishAddingRoom: room)
        
        
        
    }
    
    
    
}
