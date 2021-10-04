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
        // Do any additional setup after loading the view.
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        longTapGesture.delegate = self
        mapView.addGestureRecognizer(longTapGesture)
    }
    
    @objc func longTap(sender: UILongPressGestureRecognizer){
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            //addAnnotation(location: locationOnMap)
            
            
            let newTravelLocation = TravelLocation(context: DataController.shared.viewContext)
            newTravelLocation.latitude = locationOnMap.latitude
            newTravelLocation.longitude = locationOnMap.longitude
            
            do {
                try DataController.shared.viewContext.save()
                travelLocations.append(newTravelLocation)
            }
            catch {
                
            }
            
            sender.state = .ended
        }
    }

    func addAnnotation(location: CLLocationCoordinate2D){
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "Some Title"
            annotation.subtitle = "Some Subtitle"
            self.mapView.addAnnotation(annotation)
    }
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTravelLocations()
    }
    
    func loadTravelLocations() {
        
        let fetchRequest = TravelLocation.fetchRequest()
        if let data = try? DataController.shared.viewContext.fetch(fetchRequest) {
            travelLocations = data
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
        
        // Centre on first (possibly new) location.
        if annotations.count > 0 {
            self.mapView.camera.centerCoordinate = annotations[0].coordinate
        }
    }
    
    static let pinReuseId = "pin"
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Handle press of pin to display photo album of travel location.
        if control == view.rightCalloutAccessoryView {
            if let annotation = view.annotation, let nameProperty = annotation.title, let mediaURLProperty = annotation.subtitle, let name = nameProperty, let mediaURL = mediaURLProperty  {
                
                
                
                
            }
        }
    }
}

