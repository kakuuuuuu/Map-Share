//
//  ViewController.swift
//  socketTest
//
//  Created by Kyle Tsuyemura on 7/20/16.
//  Copyright © 2016 Kyle Tsuyemura. All rights reserved.
//

import UIKit
import Alamofire
import SocketIOClientSwift
import CoreLocation
import MapKit
import CoreData
import CoreMotion

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Variables
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Initialize variables passed by RoomTableController
    weak var cancelButtonDelegate: CancelButtonDelegate?
    weak var delegate: MapViewControllerDelegate?
    weak var user: NSDictionary?
    var roomID: String?
    weak var room: NSDictionary?
    
    // Initialize included libraries
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let manager = CMMotionManager()
    let socket = SocketIOClient(socketURL: NSURL(string: "http://leforge.co")!, options: [.Reconnects(true)])
    
    // Initialize Map Variables
    let locationManager = CLLocationManager()
    var source:MKMapItem?
    var destination:MKMapItem?
    var request:MKDirectionsRequest = MKDirectionsRequest()
    var meetup: CLLocation?
    var route:MKRoute = MKRoute()
    var locMark: MKPlacemark?
    var destMark: MKPlacemark?
    var meet: String?
    var geocoder = CLGeocoder()
    
    // Initialize UI Map Elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressField: UITextField!
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Initialize Functions
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Empty placeholder when editing begins
    @IBAction func editingDidBegin(sender: UITextField) {
        self.addressField.placeholder = ""
    }
    
    // Reset address field and replace placeholder
    @IBAction func editingDidEnd(sender: AnyObject) {
        if self.addressField.text == ""{
            self.addressField.placeholder = "Enter Address Here"
        }
    }
    
    // Dismiss Room View
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        // Exits room on server
        self.socket.emit("leaverooms")
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
    }
    // Dismiss Room View in response to cancel button on different tab
    func backbutton(notification: NSNotification){
        self.socket.emit("leaverooms")
        cancelButtonDelegate?.cancelButtonPressedFrom(self)
    }
    
    // Turns socket connection on and off
    // NOTE: All socket data regardless of tabs is sent through this view due to trouble integrating sockets into table views
    @IBAction func socketSwitched(sender: UISwitch) {
        if sender.on {
            socket.connect()
        }
        else{
            socket.disconnect()
        }
    }
    
    // Saves changes to core data
    func updateCoreData(){
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                print("Success")
            } catch {
                print("\(error)")
            }
        }
    }
    
    // Dismisses Keyboard
    func dismissKeyboard() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Map Functions
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Set Default Map Radius
    let regionRadius: CLLocationDistance = 1000
    
    // Set Default Map Center on current location
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Change map on address change
    @IBAction func addressEntered(sender: AnyObject) {
        if addressField.text != "" {
            geocoder.geocodeAddressString(addressField.text!, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    print("Error", error)
                    let alert = UIAlertController(title: "Could not find the location", message: "Try to be more specific!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.addressField.text = ""
                    
                }
                if let placemark = placemarks?.first {
                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                    let address = [
                        "room": self.roomID!,
                        "name":self.addressField.text!,
                        "lat": coordinates.latitude,
                        "lng": coordinates.longitude
                    ]
                    let parameters: [String: AnyObject] = [
                        "coords": [
                            "lat": coordinates.latitude,
                            "lng": coordinates.longitude
                        ],
                        "destination": self.addressField.text!
                    ]
                    Alamofire.request(.POST, "http://leforge.co/changeCoords/"+self.roomID!, parameters: parameters, encoding: .JSON)
                    self.socket.emit("coords", address)
                    self.addressField.text = ""
                }
            })
        }
    }
    
    // Loads location onto map from favorites
    func loadLocation(notification: NSNotification){
        //load data here
        let dict = notification.object as! Place
        let coord: NSDictionary = ["name": (dict.location! as String), "lat": dict.lat! as Double, "lng":dict.lng! as Double]
        self.drawRoute(coord)
    }
    
    // Sends comment data passed from chat view to all connected users
    func sendComment(notification: NSNotification){
        let dict = notification.object as! NSDictionary
        self.socket.emit("sendMessage", dict)
    }
    
    // Attempt to create route from new location
    func drawRoute(coord: NSDictionary){
        self.meet = coord["name"] as? String
        self.meetup = CLLocation(latitude: coord["lat"] as! Double, longitude: coord["lng"] as! Double)
        print(self.meetup)
        self.centerMapOnLocation(self.meetup!)
        let location = Location(
            title: "Meet Up Here",
            locationName: coord["name"] as! String,
            discipline: "Meetup Place",
            coordinate: CLLocationCoordinate2D(latitude:coord["lat"] as! Double, longitude: coord["lng"] as! Double),
            link: "facebook.com"
        )
        // Set parameters for polyline
        self.destMark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), addressDictionary: nil)
        self.source = MKMapItem(placemark: self.locMark!)
        self.destination = MKMapItem(placemark: self.destMark!)
        self.request.source = self.source
        self.request.destination = self.destination
        self.request.transportType = MKDirectionsTransportType.Automobile
        self.request.requestsAlternateRoutes = true
        // Request directions based on parameters
        var directions = MKDirections(request: self.request)
        directions.calculateDirectionsWithCompletionHandler({
            (response:MKDirectionsResponse?, error:NSError?) in
            if error == nil{
                self.plotPolyline(response!.routes[0])
            }
            else{
                print(error)
            }
        })
        // Resets Annotations
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(location)
    }
    
    // Set visual parameters for polyline
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let polylineOverlay = overlay as? MKPolyline {
            let render = MKPolylineRenderer(polyline: polylineOverlay)
            render.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.5)
            render.lineWidth = 5.0
            return render
        }
        return nil
    }
    
    // Sets accessories for destination markers
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // Ignores current location marker as to not change it
        if (mapView.userLocation === annotation as MKAnnotation)
        {
            return nil;
        }
        else{
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier("AnnotationView Id")
            if view == nil{
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView Id")
                view!.canShowCallout = true
            } else {
                view!.annotation = annotation
            }
            view?.leftCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            view?.rightCalloutAccessoryView = UIButton(type: UIButtonType.ContactAdd)
            return view
        }
    }
    
    // Accessory Functions
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Prompts user to add location to favorites
        if (control as? UIButton)?.buttonType == UIButtonType.ContactAdd {
            mapView.deselectAnnotation(view.annotation, animated: false)
            let alert = UIAlertController(title: "Save location?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            // Saves location data to Core Data
            var okAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                print("Saved")
                let newlocation = NSEntityDescription.insertNewObjectForEntityForName("Place", inManagedObjectContext: self.managedObjectContext) as! Place
                newlocation.location = self.meet
                newlocation.lat = self.meetup?.coordinate.latitude
                newlocation.lng = self.meetup?.coordinate.longitude
                self.updateCoreData()
                NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
            }
            // Cancels dialogue
            var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                print("Canceled")
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        // Redirects user to Apple Maps for step by step directions
        else if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?daddr=\((self.meetup?.coordinate.latitude)!),\((self.meetup?.coordinate.longitude)!)")!)
        }
    }
    
    
    // Plots polyline route on Map
    func plotPolyline(route: MKRoute) {
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
        if mapView.overlays.count == 1 {
            mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                      edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                      animated: false)
        }
        else {
            let polylineBoundingRect =  MKMapRectUnion(mapView.visibleMapRect,
                                                       route.polyline.boundingMapRect)
            mapView.setVisibleMapRect(polylineBoundingRect,
                                      edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                      animated: false)
        }
    }
    
    // Obtains current location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let currentLocation = MKPlacemark (coordinate: CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude), addressDictionary: nil)
        locMark = currentLocation
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
        // GET request for current location
        Alamofire.request(.GET, "http://leforge.co/getroom/"+(roomID!)).response { (_, _, data, error) in
            do {
                print("FINDING")
                if let roomData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                {
                    self.room = roomData
                    if self.room!["latitude"] != nil && self.room!["longitude"] != nil {
                        let coord: NSDictionary = [
                            "name": self.room!["destination"]!,
                            "lat": self.room!["latitude"]!,
                            "lng": self.room!["longitude"]!
                        ]
                        // Only draw route on load if there is a location saved in server
                        self.drawRoute(coord)
                    }
                }
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    // Error handler for current location
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        print("Errors: " + error.localizedDescription)
    }

    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // Server Call / Initialize View
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        print(self.room)
        
        // Sets address field placeholder
        self.addressField.placeholder = "Enter Address Here"
        
        super.viewDidLoad()
        
        // Changes view when device is shaken to the left
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self] (data: CMDeviceMotion?, error: NSError?) in
                
                if data?.userAcceleration.x < -2.5 {
                    self!.tabBarController?.selectedIndex = 1
                }
            }
        }

        self.addressField.delegate = self;
        
        // Dismisses keyboard when tapping screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Connect sockets
        self.socket.connect()
        
        // Initializes Map variables on view
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        ////////////////////////////////////
        // Socket functions
        ////////////////////////////////////
        
        // Attempts to join room on successful connection to server socket
        socket.on("connect") {data, ack in
            print("socket connected")
            let id = self.roomID!
            self.socket.emit("joinRoom", id)
        }
        
        // Confirm success on joining room
        socket.on("roomJoined") {data, ack in
            print(data)
        }
        
        // Change coordinates in response to external address change
        socket.on("changeCoords") {data, ack in
            if let coord = data[0] as? NSDictionary{
                print(coord)
                self.drawRoute(coord)
            }
        }
        
        // Adds message in response to external comment
        socket.on("broadcastMessage"){data, ack in
            NSNotificationCenter.defaultCenter().postNotificationName("newcomment", object: data)
            print("message recieved")
            self.tabBarController?.selectedIndex = 2
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

