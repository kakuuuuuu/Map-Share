//
//  RoomTableController.swift
//  ShareSearch
//
//  Created by Kyle Tsuyemura on 7/26/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import UIKit
import Alamofire

class RoomTableController: UITableViewController, CancelButtonDelegate, MapViewControllerDelegate, NewRoomTableControllerDelegate{
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Variables
    ///////////////////////////////////////////////////////////////////////////////////////////////////

    // Initializes variables passed from Login View
    weak var cancelButtonDelegate: CancelButtonDelegate?
    weak var delegate: RoomTableControllerDelegate?
    weak var user: NSDictionary?
    
    // Initializes room array
    var rooms = [AnyObject]()
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Returns to login view when logout button is pressed
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
    }
    
    func cancelButtonPressedFrom(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Server Call / Initialize View
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        // Requests server to return rooms user is invited
        Alamofire.request(.GET, "http://leforge.co/getrooms/"+(user!["_id"]! as! String)).response { (_, _, data, error) in
            do {
                print("FINDING")
                // 
                if let roomData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSArray
                {
                    for item in roomData{
                        self.rooms.append(item as! NSDictionary)
                    }
                    // Refreshes table on success
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
            } catch {
                print("Something went wrong")
            }
        }
        super.viewDidLoad()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Table Functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // dequeue the cell from our storyboard
        let cell = tableView.dequeueReusableCellWithIdentifier("roomCell")!
        cell.tintColor = UIColor(red: 29.0/255.0, green: 113.0/255.0, blue: 132.0/255.0, alpha: 1.0)
        cell.textLabel?.font = UIFont(name:"Questrial", size: 18)

        // All UITableViewCell objects have a build in textLabel so set it to the model that is corresponding to the row in array
        cell.textLabel?.text = rooms[indexPath.row]["name"] as? String
        // return cell so that Table View knows what to draw in each row
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("roomSegue", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Segue Functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Segue to room view
        if segue.identifier == "roomSegue" {
            let navigationController = segue.destinationViewController as! UITabBarController
            // Grab tab views to pass data
            let controller = navigationController.viewControllers![0] as! MapViewController
            let controller2 = navigationController.viewControllers![2] as! ChatController
            let controller3 = navigationController.viewControllers![3] as! AddUserViewController
            // Passes self as view to return to when view is dismissed
            controller.cancelButtonDelegate = self
            controller2.cancelButtonDelegate = self
            controller.delegate = self
            // Passes user data to tab views
            controller.user = self.user
            controller2.user = self.user
            // Passes room ID to each tab view
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell){
                controller.roomID = rooms[indexPath.row]["_id"] as! String
                controller2.roomID = rooms[indexPath.row]["_id"] as! String
                controller3.roomID = rooms[indexPath.row]["_id"] as! String
            }
            
        }
        // Segue to form for new room
        else if segue.identifier == "newRoomSegue"{
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! NewRoomTableController
            // Passes data to form
            controller.cancelButtonDelegate = self
            controller.delegate = self
            controller.user = self.user
        }
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Add New Room
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    func newRoomTableController(controller: NewRoomTableController, didFinishAddingRoom room: String){
        dismissViewControllerAnimated(true, completion: nil)
        // Set parameters to send to server
        let parameters = [
            "user": self.user!,
            "room": room
        ]
        // Post new room data to server
        Alamofire.request(.POST, "http://leforge.co/createRoom", parameters: parameters, encoding: .JSON)
            .responseJSON { response, JSON, error in
                self.rooms = []
                // GET request to server to update current list of rooms after adding
                Alamofire.request(.GET, "http://leforge.co/getrooms/"+(self.user!["_id"]! as! String)).response { (_, _, data, error) in
                    do {
                        print("FINDING")
                        if let roomData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSArray
                        {
                            for item in roomData{
                                self.rooms.append(item as! NSDictionary)
                            }
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                            
                        }
                    } catch {
                        print("Something went wrong")
                    }
                }
        }
    }
}