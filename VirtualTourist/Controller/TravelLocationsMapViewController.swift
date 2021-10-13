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
class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var pins: [Pin] = []
    
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
        
        let fetchRequest = Pin.fetchRequest()
        do {
            pins = try DataController.shared.viewContext.fetch(fetchRequest)
        }
        catch {
            fatalError(error.localizedDescription)
        }
        
        generateAnnotations();
    }
    
    /// Generate map annotations for travel locations.
    func generateAnnotations() {
        // Remove previous annotations, if any.
        mapView.removeAnnotations(self.mapView.annotations)
               
        // Create annotation for each travel location.
        var annotations = [MKTravelLocationAnnotation]()
        for pin in pins {
            let latitude = CLLocationDegrees(pin.latitude)
            let longitude = CLLocationDegrees(pin.longitude)
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKTravelLocationAnnotation(pin)
            annotation.coordinate = coordinates
            annotations.append(annotation)
        }
        
        // Add array of annotations to map.
        mapView.addAnnotations(annotations)
        
        // Centre on last (possibly new) location.
        if annotations.count > 0 {
            mapView.camera.centerCoordinate = annotations[annotations.count - 1].coordinate
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
        if let annotation = view.annotation as? MKTravelLocationAnnotation {
            // Show photo album of travel location.
            let photoAlbumViewController = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            photoAlbumViewController.pin = annotation.pin
            navigationController!.pushViewController(photoAlbumViewController, animated: true)
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
            let newPin = Pin(context: DataController.shared.viewContext)
            newPin.latitude = locationOnMap.latitude
            newPin.longitude = locationOnMap.longitude
            
            do {
                // Save to data store.
                try DataController.shared.viewContext.save()
                
                // Add to array of travel locations.
                pins.append(newPin)
                
                // Display on map.
                let annotation = MKTravelLocationAnnotation(newPin)
                annotation.coordinate = locationOnMap
                mapView.addAnnotation(annotation)
            }
            catch {
                fatalError(error.localizedDescription)
            }
            
            sender.state = .ended // Workaround to allow new long press straightaway.
        }
    }
}

