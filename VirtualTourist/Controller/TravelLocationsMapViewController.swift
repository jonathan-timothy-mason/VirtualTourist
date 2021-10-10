//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Jonathan Mason on 04/10/2021.
//

import UIKit
import MapKit

/// Displays map of travel locations.
/// Based on PinSample by Jason, Udacity.
class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var travelLocations: [TravelLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // From answer to "iOS : Swift - How to add pinpoint to map on touch and get
        // detailed address of that location?" by Peter Pohlmann:
        //https://stackoverflow.com/questions/34431459/ios-swift-how-to-add-pinpoint-to-map-on-touch-and-get-detailed-address-of-th
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load travel locations from data store and populate map.
        loadTravelLocations()
    }
    
    /// Load travel locations from data store and populate map.
    func loadTravelLocations() {
        
        let fetchRequest = TravelLocation.fetchRequest()
        do {
            travelLocations = try DataController.shared.viewContext.fetch(fetchRequest)
        }
        catch {
            fatalError(error.localizedDescription)
        }
        
        generateAnnotations();
    }
    
    /// Generate map annotations for travel locations.
    func generateAnnotations() {
        // Remove previous annotations, if any.
        self.mapView.removeAnnotations(self.mapView.annotations)
               
        // Create an array of annotations for each travel location.
        var annotations = [MKPointAnnotation]()
        for travelLocation in travelLocations {
            let latitude = CLLocationDegrees(travelLocation.latitude)
            let longitude = CLLocationDegrees(travelLocation.longitude)
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates
            annotations.append(annotation)
        }
        
        // Add array of annotations to map.
        self.mapView.addAnnotations(annotations)
        
        // Centre on last (possibly new) location.
        if annotations.count > 0 {
            self.mapView.camera.centerCoordinate = annotations[annotations.count - 1].coordinate
        }
    }
    
    static let pinReuseId = "pin"
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Provide pin view for each travel location as required.
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: TravelLocationsMapViewController.pinReuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: TravelLocationsMapViewController.pinReuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Display photo album for selected travel location.
        if let annotation = view.annotation  {
            let lat = annotation.coordinate.latitude
            let long = annotation.coordinate.longitude
            ControllerHelpers.showMessage(parent: self, caption: "Test", message: "lat=\(lat), long = \(long).")
        }
    }
    
    /// Handle long press of map to add new travel location.
    /// From answer to "iOS : Swift - How to add pinpoint to map on touch and get detailed
    /// address of that location?" by Peter Pohlmann:
    /// https://stackoverflow.com/questions/34431459/ios-swift-how-to-add-pinpoint-to-map-on-touch-and-get-detailed-address-of-th
    /// - Parameter sender: Long press gesture recogniser.
    @objc func longTap(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            // Get latitide and longitude of pressed point of map.
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            // Create new travel location.
            let newTravelLocation = TravelLocation(context: DataController.shared.viewContext)
            newTravelLocation.latitude = locationOnMap.latitude
            newTravelLocation.longitude = locationOnMap.longitude
            
            do {
                // Save to data store.
                try DataController.shared.viewContext.save()
                
                // Add to array of travel locations.
                travelLocations.append(newTravelLocation)
                
                // Display on map.
                self.mapView.addAnnotation(MKPointAnnotation(__coordinate: locationOnMap))
            }
            catch {
                fatalError(error.localizedDescription)
            }
            
            sender.state = .ended // Workaround to allow new long press straightaway.
        }
    }
}

