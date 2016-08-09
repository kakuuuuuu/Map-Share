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
    
    
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
    }
    
    
    weak var cancelButtonDelegate: CancelButtonDelegate?
    weak var delegate: RoomTableControllerDelegate?
    weak var user: NSDictionary?
    var rooms = [AnyObject]()
    override func viewDidLoad() {
        print(user!["local"]!["name"]!)
        Alamofire.request(.GET, "http://leforge.co/getrooms/"+(user!["_id"]! as! String)).response { (_, _, data, error) in
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
        
        super.viewDidLoad()
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // dequeue the cell from our storyboard
        let cell = tableView.dequeueReusableCellWithIdentifier("roomCell")!
        cell.tintColor = UIColor(red: 29.0/255.0, green: 113.0/255.0, blue: 132.0/255.0, alpha: 1.0)

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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "roomSegue" {
            let navigationController = segue.destinationViewController as! UITabBarController
            let controller = navigationController.viewControllers![0] as! MapViewController
            let controller2 = navigationController.viewControllers![2] as! ChatController
            let controller3 = navigationController.viewControllers![3] as! AddUserViewController
            controller.cancelButtonDelegate = self
            controller2.cancelButtonDelegate = self
            controller.delegate = self
            controller.user = self.user
            controller2.user = self.user
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell){
                controller.roomID = rooms[indexPath.row]["_id"] as! String
                controller2.roomID = rooms[indexPath.row]["_id"] as! String
                controller3.roomID = rooms[indexPath.row]["_id"] as! String
            }
            
        }
        else if segue.identifier == "newRoomSegue"{
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! NewRoomTableController
            controller.cancelButtonDelegate = self
            controller.delegate = self
            controller.user = self.user
        }
        
    }
    
    func cancelButtonPressedFrom(controller: UIViewController) {
//        let alert = UIAlertController(title: "Logging Out", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.Alert)
//        var okAction = UIAlertAction(title: "Log Out", style: UIAlertActionStyle.Default) {
//            UIAlertAction in
//            print("Yes")
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
//        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
//            UIAlertAction in
//            print("Canceled")
//        }
//        alert.addAction(okAction)
//        alert.addAction(cancelAction)
//        self.presentViewController(alert, animated: true, completion: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func newRoomTableController(controller: NewRoomTableController, didFinishAddingRoom room: String){
        dismissViewControllerAnimated(true, completion: nil)
        let parameters = [
            "user": self.user!,
            "room": room
        ]
        Alamofire.request(.POST, "http://leforge.co/createRoom", parameters: parameters, encoding: .JSON)
            .responseJSON { response, JSON, error in
                self.rooms = []
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