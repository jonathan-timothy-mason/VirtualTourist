//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Jonathan Mason on 10/10/2021.
//

import UIKit
import MapKit

/// Displays photos of travel location.
class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var travelLocation: TravelLocation?
    
    var testImages: [UIImage] = [UIImage(named: "big")!, UIImage(named: "blofeld")!, UIImage(named: "drax")!]
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell

        // Set image.
        cell.imageView?.image = testImages[indexPath.row]

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
 
    }
}
