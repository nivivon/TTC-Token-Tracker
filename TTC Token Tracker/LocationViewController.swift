//
//  LocationViewController.swift
//  TTC Token Tracker
//
//  Created by Niv Yahel on 2014-09-25.
//  Copyright (c) 2014 Niv Yahel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tokensLabel: UILabel!
    @IBOutlet var lastRegionLabel: UILabel!
    
    var locationManager: CLLocationManager!
    
    let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let radius: CLLocationDistance = 100
    
    var numTokens : Int {
        get {
            let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let numTokens: Int = userDefaults.valueForKey("tokens").integerValue
            return numTokens
        }
        set(newNumTokens) {
            userDefaults.setInteger(newNumTokens, forKey: "tokens")
            userDefaults.synchronize()
            updateTokensLabel()
        }
    }
    
    @IBAction func incrementTokenByOne() {
        numTokens++
    }

    @IBAction func decrementTokenByOne() {
        if (numTokens > 0) {
            numTokens--
        }
    }
    
    var lastRegionIdentifier: String {
        get {
            let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
            if let lastRegionIdentifier: String = userDefaults.stringForKey("lastRegion") {
                return lastRegionIdentifier
            }
            else {
                return "none so far"
            }
            
        }
        set(newLastRegionIdentifier) {
            userDefaults.setValue(newLastRegionIdentifier, forKey: "lastRegion")
            updateLastRegionLabel()
        }
    }
    
    func updateTokensLabel() {
        tokensLabel.text = String(format: "%d", numTokens)
    }
    
    
    func updateLastRegionLabel() {
        lastRegionLabel.text = lastRegionIdentifier
    }
    
    func updateLabels() {
        updateTokensLabel()
        updateLastRegionLabel()
    }
    
    func getCentreCoordinate(regionIdentifier: String) -> CLLocationCoordinate2D {
        let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let storedCentreCoordinate: Dictionary = userDefaults.dictionaryForKey(regionIdentifier) as Dictionary<String, CLLocationDegrees>
        let centreCoordinate = CLLocationCoordinate2D(latitude: storedCentreCoordinate["latitude"]!, longitude: storedCentreCoordinate["longitude"]!)
        return centreCoordinate
    }
    
    func notifyOnEnteringRegion(identifier: String, coordinate: CLLocationCoordinate2D) {
        let region: CLCircularRegion = CLCircularRegion(center: coordinate, radius: radius, identifier: identifier)
        region.notifyOnEntry = true
        locationManager.startMonitoringForRegion(region)
    }
    
    func addPin(regionCentreCoordinate: CLLocationCoordinate2D, regionIdentifier: String) {
        let regionCentreAnnotation: MKPointAnnotation = MKPointAnnotation()
        regionCentreAnnotation.coordinate = regionCentreCoordinate
        regionCentreAnnotation.title = regionIdentifier
        mapView.addAnnotation(regionCentreAnnotation)
    }
    
    func drawCircle(coordinate: CLLocationCoordinate2D) {
        let circleOverlay: MKCircle = MKCircle(centerCoordinate: coordinate, radius: radius)
        mapView.addOverlay(circleOverlay, level: MKOverlayLevel.AboveRoads)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if let circle: MKCircle = overlay as? MKCircle {
            let circleRenderer: MKCircleRenderer = MKCircleRenderer(circle: circle)
            circleRenderer.fillColor = UIColor.cyanColor().colorWithAlphaComponent(0.2)
            circleRenderer.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.7)
            circleRenderer.lineWidth = 3
            return circleRenderer
        }
        else {
            return nil
        }
    }
    
    func addRegion(regionIdentifier: String) {
        let regionCentreCoordinate: CLLocationCoordinate2D = getCentreCoordinate(regionIdentifier)
        notifyOnEnteringRegion(regionIdentifier,coordinate: regionCentreCoordinate)
        addPin(regionCentreCoordinate, regionIdentifier: regionIdentifier)
        drawCircle(regionCentreCoordinate)
    }
    
    func showLocalNotification(regionIdentifier: String) {
        let notificationText: String = String(format: "Entered %@ - %d tokens left",regionIdentifier, numTokens)
        var notification = UILocalNotification()
        let now = NSDate()
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.fireDate = now
        notification.alertBody = notificationText
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

    func isNewRegion(newRegionIdentifier: String) -> Bool {
        return lastRegionIdentifier != newRegionIdentifier
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        if (isNewRegion(region.identifier)) {
            numTokens--
            lastRegionIdentifier = region.identifier
            showLocalNotification(lastRegionIdentifier)
        }
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        let ZOOM_LEVEL: CLLocationDegrees = 0.005
        let span = MKCoordinateSpan(latitudeDelta: ZOOM_LEVEL, longitudeDelta: ZOOM_LEVEL)
        let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func initializeLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        if (locationManager.respondsToSelector(Selector("requestAlwaysAuthorization"))) {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
    
    func getNotificationPermissions() {
        if(UIApplication.instancesRespondToSelector(Selector("registerUserNotificationSettings:"))) {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        getNotificationPermissions()
        addRegion("home")
        addRegion("work")
        updateLabels()
    }
}
