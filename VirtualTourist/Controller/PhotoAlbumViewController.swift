//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Jonathan Mason on 10/10/2021.
//

import UIKit
import MapKit

/// Displays photos of travel location.
class PhotoAlbumViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var travelLocation: TravelLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if travelLocation == nil {
            fatalError("Travel location not set whilst attempting to displaying photo album.")
        }
                     
        generateAnnotation();
    }
    
    /// Create annotation for travel location.
    func generateAnnotation() {
        let latitude = CLLocationDegrees(travelLocation!.latitude)
        let longitude = CLLocationDegrees(travelLocation!.longitude)
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        // Add annotation to map.
        mapView.addAnnotation(annotation)
        
        // Centre on travel location.
        mapView.camera.centerCoordinate = annotation.coordinate
    }
    
    static let pinReuseId = "pin"
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Provide pin view for travel location.
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
}
