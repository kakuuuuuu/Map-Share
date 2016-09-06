//
//  ChatViewController.swift
//  socketTest
//
//  Created by Kyle Tsuyemura on 7/27/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import UIKit
import Alamofire
class ChatViewController: UITableViewController{
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Variables
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Initialize variables for data passed from parent chatController
    weak var user: NSDictionary?
    var roomID: String?
    weak var room: NSDictionary?
    
    // Initialize comments array
    var comments = [NSDictionary]()
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Chat Functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Adds new comment to array in response to notification from MapViewController
    func loadComments(notification: NSNotification){
        //load data here
        let dict = notification.object as! NSArray
        let commentdata = dict[0] as! NSDictionary
        let comment:NSDictionary = [
            "text":commentdata["message"] as! String,
            "_user":commentdata["user"] as! NSDictionary
        ]
        self.comments.append(comment)
        self.tableView.reloadData()
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: comments.count-1 , inSection: 0), atScrollPosition: .Bottom, animated: true)
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Server Call / Initialize View
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        
        // Set visual parameters for table
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 40, 0);
        self.tableView.separatorStyle = .None
        
        super.viewDidLoad()
        
        // GET Request for room's comments from server
        Alamofire.request(.GET, "http://leforge.co/getroom/"+(roomID! as String)).response { (_, _, data, error) in
            do {
                print("FINDING")
                if let roomData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                {
                    self.room = roomData
                                            let comments = self.room!["_comments"] as! NSArray
                        for comment in comments{
                            self.comments.append(comment as! NSDictionary)
                        }
                        // Reloads table upon successful fetch
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tableView.reloadData()
                        })
                    
                }
            } catch {
                print("Something went wrong")
            }
        }
        
        // Removes and resets observer to update comments upon response from MapViewController
        // NOTE: Observer used in this situation due to problems integrating sockets to table views, so socket is used externally
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"newcomment", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadComments:",name:"newcomment", object: nil)
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // Table Functions
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // dequeue the cell from our storyboard
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell")! as! CustomCell
        // All UITableViewCell objects have a build in textLabel so set it to the model that is corresponding to the row in array
        
        // Sets visual parameters for table cells
        cell.contentView.backgroundColor = UIColor.clearColor()
        let whiteRoundedView : UIView = UIView(frame: CGRectMake(10, 8, self.view.frame.size.width - 20, 60))
        whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 0.8])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 10.0
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
        cell.commentLabel?.text = comments[indexPath.row]["text"]! as? String
        cell.nameLabel?.text = comments[indexPath.row]["_user"]!["local"]!!["name"] as? String

        return cell
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
}
