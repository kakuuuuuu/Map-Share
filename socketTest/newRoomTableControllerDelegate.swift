//
//  newRoomTableControllerDelegate.swift
//  ShareSearch
//
//  Created by Kyle Tsuyemura on 7/26/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import Foundation
protocol NewRoomTableControllerDelegate: class {
    
    func newRoomTableController(controller: NewRoomTableController, didFinishAddingRoom room: String)
    
}