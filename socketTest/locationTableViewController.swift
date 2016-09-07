//
//  locationTableViewController.swift
//  socketTest
//
//  Created by Kyle Tsuyemura on 7/20/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import UIKit
import CoreData
import CoreMotion

class locationTableViewController: UITableViewController{
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Variables
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Initialize Core Data
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // Initialize array of locations
    var locations = [Place]()
    
    // Initialize Core Motion library
    let manager = CMMotionManager()
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Reloads table when new location is favorited
    func loadList(notification: NSNotification){
        //load data here
        print("reloading")
        let userRequest = NSFetchRequest(entityName: "Place")
        do {
            let results = try managedObjectContext.executeFetchRequest(userRequest)
            locations = results as! [Place]
        } catch {
            print("\(error)")
        }
        self.tableView.reloadData()
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Pull Core Data / Initialize View
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetches favorites from core data
        let userRequest = NSFetchRequest(entityName: "Place")
        do {
            let results = try managedObjectContext.executeFetchRequest(userRequest)
            locations = results as! [Place]
        } catch {
            print("\(error)")
        }
        self.tableView.reloadData()
        
        // Removes and resets listener to watch for when user favorites location on Map View
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"load", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"load", object: nil)
        
        // Changes tab back to map view when device is shaken to the left
        // NOTE: Not calibrated properly and is not reliably working yet
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMDeviceMotion?, error: NSError?) in
                
                if data?.userAcceleration.x < -2.5 {
                    self!.tabBarController?.selectedIndex = 0
                }
            }
        }
        
    }
   
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Table Functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // dequeue the cell from our storyboard
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCells")!
        // All UITableViewCell objects have a build in textLabel so set it to the model that is corresponding to the row in array
        cell.textLabel?.text = locations[indexPath.row].location
        // return cell so that Table View knows what to draw in each row
        cell.textLabel?.font = UIFont(name:"Questrial", size: 18)
        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
   
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            managedObjectContext.deleteObject(locations[indexPath.row])
            locations.removeAtIndex(indexPath.row)
            tableView.reloadData()
            
        }
    }
    
    // Loads favorited location on Map View when accessory is tapped
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        print("accessory tapped")
        let myDict = locations[indexPath.row]
        print(myDict)
        NSNotificationCenter.defaultCenter().postNotificationName("history", object: myDict)
        self.tabBarController?.selectedIndex = 0
    }
    
}