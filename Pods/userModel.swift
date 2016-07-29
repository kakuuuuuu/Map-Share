//
//  userModel.swift
//  Pods
//
//  Created by Kyle Tsuyemura on 7/26/16.
//
//


import Foundation
class TaskModel {
    static func getUser(email: String, password: String, completionHandler: (data:NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
        if let urlToReq = NSURL(string: "http://localhost:8000/login"){
            let request = NSMutableURLRequest(URL: urlToReq)
            request.HTTPMethod = "POST"
            let bodyData = "email=\(email), password=\(password)"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
            task.resume()
        }
    }
//    static func getAllTasks(completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
//        let url = NSURL(string: "http://localhost:8000/tasks")
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithURL(url!, completionHandler: completionHandler)
//        task.resume()
//    }
//    static func addTaskWithObjective(objective: String, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
//        // Create the url to request
//        if let urlToReq = NSURL(string: "http://localhost:8000/tasks") {
//            // Create an NSMutableURLRequest using the url. This Mutable Request will allow us to modify the headers.
//            let request = NSMutableURLRequest(URL: urlToReq)
//            // Set the method to POST
//            request.HTTPMethod = "POST"
//            // Create some bodyData and attach it to the HTTPBody
//            let bodyData = "objective=\(objective)"
//            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
//            // Create the session
//            let session = NSURLSession.sharedSession()
//            let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
//            task.resume()
//        }
//    }
//    static func editTask(_id: String, objective: String, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
//        // Create the url to request
//        if let urlToReq = NSURL(string: "http://localhost:8000/tasks/edit/\(_id)") {
//            // Create an NSMutableURLRequest using the url. This Mutable Request will allow us to modify the headers.
//            let request = NSMutableURLRequest(URL: urlToReq)
//            // Set the method to POST
//            request.HTTPMethod = "POST"
//            // Create some bodyData and attach it to the HTTPBody
//            let bodyData = "objective=\(objective)"
//            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
//            // Create the session
//            let session = NSURLSession.sharedSession()
//            let task = session.dataTaskWithRequest(request, completionHandler: completionHandler)
//            task.resume()
//        }
//    }
//    static func removeTask(_id: String, completionHandler: (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void) {
//        let url = NSURL(string: "http://localhost:8000/delete/\(_id)")
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithURL(url!, completionHandler: completionHandler)
//        task.resume()
//    }
    
    
}