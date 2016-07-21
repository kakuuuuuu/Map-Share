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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let manager = CMMotionManager()
    
    let socket = SocketIOClient(socketURL: NSURL(string: "http://leforge.co")!, options: [.Reconnects(true)])
    
    @IBAction func socketSwitched(sender: UISwitch) {
        if sender.on {
            socket.connect()
        }
        else{
            socket.disconnect()
        }
    }
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressField: UITextField!
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
                    print(placemark)
                    let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                    print(coordinates)
                    print(coordinates.latitude)
                    let address = [
                        "location":self.addressField.text!,
                        "lat": coordinates.latitude,
                        "lng": coordinates.longitude
                    ]
                    self.socket.emit("location_sumbitted", address)
                    self.addressField.text = ""
                }
            })

        }
    }
    
    
    
    func loadLocation(notification: NSNotification){
        //load data here
        print("History")
        let dict = notification.object as! Place
        print(dict.lat)
        let coord: NSDictionary = ["location": (dict.location! as String), "lat": dict.lat as! Double, "lng":dict.lng as! Double]
        self.drawRoute(coord)
    }

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadLocation:",name:"history", object: nil)
        
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
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        self.socket.connect()
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
       
        
        
        
        
        socket.on("connect") {data, ack in
            print("socket connected")
        }
        socket.on("location_recieved") {data, ack in
            if let coord = data[0] as? NSDictionary{
                print(coord)
                self.drawRoute(coord)
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func drawRoute(coord: NSDictionary){
        self.meet = coord["location"] as! String
        self.meetup = CLLocation(latitude: coord["lat"] as! Double, longitude: coord["lng"] as! Double)
        print(self.meetup)
        self.centerMapOnLocation(self.meetup!)
        let location = Location(
            title: "Meet Up Here",
            locationName: coord["location"] as! String,
            discipline: "Meetup Place",
            coordinate: CLLocationCoordinate2D(latitude:coord["lat"] as! Double, longitude: coord["lng"] as! Double)
        )
        
        self.destMark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), addressDictionary: nil)
        self.source = MKMapItem(placemark: self.locMark!)
        self.destination = MKMapItem(placemark: self.destMark!)
        self.request.source = self.source
        self.request.destination = self.destination
        self.request.transportType = MKDirectionsTransportType.Automobile
        self.request.requestsAlternateRoutes = true
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
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(location)

    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func plotPolyline(route: MKRoute) {
        // 1
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
        // 2
        if mapView.overlays.count == 1 {
            mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                      edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                      animated: false)
        }
            // 3
        else {
            let polylineBoundingRect =  MKMapRectUnion(mapView.visibleMapRect,
                                                       route.polyline.boundingMapRect)
            mapView.setVisibleMapRect(polylineBoundingRect,
                                      edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0),
                                      animated: false)
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let polylineOverlay = overlay as? MKPolyline {
            
            let render = MKPolylineRenderer(polyline: polylineOverlay)
            render.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.5)
            render.lineWidth = 5.0
            return render
        }
        return nil
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        print("ANNOTATION \(annotation)")
        print("USER LOCATION \(mapView.userLocation)")
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
            
            view?.leftCalloutAccessoryView = nil
            view?.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            //swift 1.2
            //view?.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
            
            return view

        }
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //I don't know how to convert this if condition to swift 1.2 but you can remove it since you don't have any other button in the annotation view
        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: false)
            let alert = UIAlertController(title: "Save Location?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            var okAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                print("OK Pressed")
                let newlocation = NSEntityDescription.insertNewObjectForEntityForName("Place", inManagedObjectContext: self.managedObjectContext) as! Place
                newlocation.location = self.meet
                newlocation.lat = self.meetup?.coordinate.latitude
                newlocation.lng = self.meetup?.coordinate.longitude
                self.updateCoreData()
                NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
            }
            var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                print("Cancel Pressed")
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }



    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let currentLocation = MKPlacemark (coordinate: CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude), addressDictionary: nil)
        locMark = currentLocation
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        self.mapView.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        print("Errors: " + error.localizedDescription)
    }
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

}

