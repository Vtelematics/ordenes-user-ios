//
//  TrackingVc.swift
//  Talabat clone
//
//  Created by Adyas infotech on 12/10/22.
//

import UIKit
import GoogleMaps
import Firebase

class TrackingVc: UIViewController {

    @IBOutlet weak var myViewTrack : UIView!
    @IBOutlet weak var myMapViewTrack : GMSMapView!
    @IBOutlet weak var myLblDeliveryTime : UILabel!
    
    var mapTasks = MapTasks()
    var routePolyline: GMSPolyline!
    var locationMarker: GMSMarker!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var markersArray: Array<GMSMarker> = []
    var waypointsArray: Array<String> = []
    var markerList = [GMSMarker]()
    var currentLat = ""
    var currentLong = ""
    var driverId = ""
    var oldDegree = Float()
    var valSeconds = 4
    var locationTimer = Timer()
    var fromLatLong = ""
    var toLatLong = ""
    var estimateTimer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
          locationTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(getDriverLocationNew), userInfo: nil, repeats: true)
          locationTimer.fire()
          createRoutes(fromLatLong, toAdd: toLatLong)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationTimer.invalidate()
        estimateTimer.invalidate()
    }
    
    //MARK: Function
    func createRoutes(_ fromAdd: String, toAdd: String)
    {
        if self.routePolyline != nil
        {
            self.clearRoute()
            self.waypointsArray.removeAll(keepingCapacity: false)
        }
        self.mapTasks.getDirections(fromAdd , destination: toAdd, waypoints: nil, travelMode: TravelModes.driving, completionHandler: { (status, success) -> Void in
            if success
            {
                self.configureMapAndMarkersForRoute()
                self.myLblDeliveryTime.text = self.mapTasks.totalDuration
                self.drawRoute()
                self.estimateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.getEstimateTime), userInfo: nil, repeats: true)
                self.estimateTimer.fire()
            }
            else
            {
                print(status)
            }
        })
    }
    
    @objc func getEstimateTime() {
        var directionsURLString = "https://maps.googleapis.com/maps/api/directions/json?" + "origin=" + fromLatLong + "&destination=" + toLatLong
        directionsURLString += "&mode=driving"
        directionsURLString += "&key=\(apiKey)"
        let trimmedUrl = directionsURLString.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: " ", with: "%20") as String
        let trimmedUrl1 = trimmedUrl.trimmingCharacters(in: CharacterSet(charactersIn: "")).replacingOccurrences(of: "\n", with: "%20") as String
        let directionsURL = URL(string: trimmedUrl1)
        print(trimmedUrl)
        DispatchQueue.main.async(execute: { () -> Void in
            do {
                if let directionsData = try? Data(contentsOf: directionsURL!)
                {
                    if let dictionary = try JSONSerialization.jsonObject(with: directionsData, options: .allowFragments) as? [String: Any]{
                        if let status = dictionary["status"] as? String {
                            if status == "OK" {
                                if let routes = dictionary["routes"] as? [[String:Any]]{
                                    let selectedRoute = routes.first
                                    let legs = selectedRoute?["legs"] as! [[String:Any]]
                                    let duration = legs.first?["duration"] as! [String:Any]
                                    let estimateTime = duration["text"] as? String
                                    if isRTLenabled{
                                        self.myLblDeliveryTime.text = (estimateTime ?? "") + " " + NSLocalizedString("Within", comment: "")
                                    }else{
                                        self.myLblDeliveryTime.text = NSLocalizedString("Within", comment: "") + " " + (estimateTime ?? "")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch
            {
                print("error in JSONSerialization")
            }
        })
    }
    
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            markersArray.removeAll(keepingCapacity: false)
        }
    }
    
    func configureMapAndMarkersForRoute() {
        myMapViewTrack.camera = GMSCameraPosition.camera(withTarget: self.mapTasks.originCoordinate, zoom: 17.0)
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.myMapViewTrack
        originMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        originMarker.title = self.mapTasks.originAddress
        //originMarker.title = self.lblFromLocation.text!
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.myMapViewTrack
        destinationMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        destinationMarker.title = self.mapTasks.destinationAddress
        //destinationMarker.title = self.lblDeliveryLocation.text!
        self.markerList.append(self.originMarker)
        self.markerList.append(self.destinationMarker)
        if waypointsArray.count > 0
        {
            for waypoint in waypointsArray
            {
                let lat: Double = (waypoint.components(separatedBy: ",")[0] as NSString).doubleValue
                let lng: Double = (waypoint.components(separatedBy: ",")[1] as NSString).doubleValue
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                marker.map = myMapViewTrack
                marker.icon = GMSMarker.markerImage(with: UIColor.purple)
                markersArray.append(marker)
            }
        }
    }
    
    func drawRoute()
    {
        let route = mapTasks.overviewPolyline["points"] as! String
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = myMapViewTrack
        routePolyline.strokeWidth = 2.0
        routePolyline.strokeColor = UIColor.red
        var bounds = GMSCoordinateBounds()
        for marker in markerList {
            bounds = bounds.includingCoordinate(marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
        self.myMapViewTrack.animate(with: update)
    }
    
    func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float {
        let fLat: Float = Float((fromLoc.latitude).degreesToRadians)
        let fLng: Float = Float((fromLoc.longitude).degreesToRadians)
        let tLat: Float = Float((toLoc.latitude).degreesToRadians)
        let tLng: Float = Float((toLoc.longitude).degreesToRadians)
        let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
        if degree >= 0 {
            return oldDegree
        }
        else {
            oldDegree = degree
            return 360 + degree
        }
    }
    
    @objc func getDriverLocationNew() {
        let ref1 = Database.database().reference()
        ref1.child("drivers").child("\(driverId)").observeSingleEvent(of: .value, with: { (snapshot) in
            let result = snapshot.value as? NSDictionary ?? ["latitude" : "", "longitude" : "",]
            if self.locationMarker != nil
            {
                self.locationMarker.map = nil
            }
            
            if self.currentLat == "" || self.currentLong == ""
            {
                self.currentLat = "\(result.value(forKey: "latitude")!)"
                self.currentLong = "\(result.value(forKey: "longitude")!)"
            }
            if self.currentLat != "" && self.currentLong != ""
            {
                let oldCoodinate: CLLocationCoordinate2D? = CLLocationCoordinate2DMake(CDouble(self.currentLat)!, CDouble(self.currentLong)!)
                let newCoodinate: CLLocationCoordinate2D? = CLLocationCoordinate2DMake(CDouble("\(result.value(forKey: "latitude")!)")!, CDouble("\(result.value(forKey: "longitude")!)")!)
                self.locationMarker = GMSMarker(position: oldCoodinate!)
                let markerImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                markerImg.image = UIImage(named: "ic_driver_location")
                markerImg.contentMode = .scaleAspectFit
                self.locationMarker.title = "Rider"
                self.locationMarker.iconView = markerImg
                self.locationMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
                
                //found bearing value by calculation when marker add
                //self.locationMarker.rotation = CLLocationDegrees(self.getHeadingForDirection(fromCoordinate: oldCoodinate!, toCoordinate: newCoodinate!))
                
                self.locationMarker.position = oldCoodinate!
                self.locationMarker.map = self.myMapViewTrack
                
                //marker movement animation
                CATransaction.begin()
                CATransaction.setValue(Int(2.0), forKey: kCATransactionAnimationDuration)
                CATransaction.setCompletionBlock({() -> Void in
                    self.locationMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
                    //self.locationMarker.rotation = CDouble(data.value(forKey: "bearing"))
                    //New bearing value from backend after car movement is done
                })
                self.locationMarker.position = newCoodinate!
                //this can be new position after car moved from old position to new position with animation
                self.locationMarker.map = self.myMapViewTrack
                self.locationMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
                //self.locationMarker.rotation = CLLocationDegrees(self.getHeadingForDirection(fromCoordinate: oldCoodinate!, toCoordinate: newCoodinate!))
                CATransaction.commit()
                
                self.currentLat = "\(result.value(forKey: "latitude")!)"
                self.currentLong = "\(result.value(forKey: "longitude")!)"

                if self.valSeconds == 4{
                    let camera = GMSCameraPosition.camera(withLatitude: CDouble("\(result.value(forKey: "latitude")!)")!, longitude: CDouble("\(result.value(forKey: "longitude")!)")!, zoom: 17)
                    self.myMapViewTrack?.animate(to: camera)
                    self.valSeconds = 0
                }
                self.valSeconds = self.valSeconds + 1
            }
        }){(error) in
            print(error.localizedDescription)
        }
    }
    
    //MARK: Button action
    @IBAction func clickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
