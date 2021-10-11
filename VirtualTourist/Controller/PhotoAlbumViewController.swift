//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Jonathan Mason on 10/10/2021.
//

import UIKit
import MapKit
import CoreData

/// Displays photos of travel location.
class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var travelLocation: TravelLocation!
    var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if travelLocation == nil {
            fatalError("Travel location not set whilst attempting to displaying photo album.")
        }
        
        // Size cell according to screen size.
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        generateAnnotation();
        
        loadPhotosForTravelLocation();
        
    }
    
    func addPlacholderPhoto() {
        // Create placeholder photo.
        let newPhoto = Photo(context: DataController.shared.viewContext)
        newPhoto.photo = UIImage(systemName: "doc.text.image")!.pngData()
        newPhoto.travelLocation = travelLocation
        photos.append(newPhoto)
    }

    func addPlacholderPhoto2() {
        // Create new travel location.
        let newPhoto = Photo(context: DataController.shared.viewContext)
        var image = UIImage(named: "big")!
        newPhoto.photo = image.pngData()
        newPhoto.travelLocation = travelLocation
    }
    
    func addPlacholderPhoto3() {
        // Create new travel location.
        let newPhoto = Photo(context: DataController.shared.viewContext)
        var image = UIImage(named: "EmilioLargo")!
        newPhoto.photo = image.pngData()
        newPhoto.travelLocation = travelLocation
    }
    
    

    
    
    
    /// Create annotation for travel location.
    func generateAnnotation() {
        let latitude = CLLocationDegrees(travelLocation.latitude)
        let longitude = CLLocationDegrees(travelLocation.longitude)
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
    
    /// Load photos for travel location from data store, if any, otherwise, Flickr.
    func loadPhotosForTravelLocation() {
        
        let fetchRequest = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "travelLocation == %@", travelLocation)
        do {
            
            photos = try DataController.shared.viewContext.fetch(fetchRequest)
            if photos.count > 0 {
                collectionView.reloadData()
            }
            else {
                loadPhotosForTravelLocationFromFlickr();
            }
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Load photos for travel location from Flickr and save to data store.
    func loadPhotosForTravelLocationFromFlickr() {
        
        activityIndicator.startAnimating()
        
        FlickrClient.getPhotoURLsForLocation(latitude: travelLocation.latitude, longitude: travelLocation.longitude) { urls, error in
            guard error == nil else {
                ControllerHelpers.showMessage(parent: self, caption: "Flckr Error", introMessage: "There was a problem downloading photo URLs from Flickr.", error: error)
                return
            }
            
            for _ in 0...urls.count {
                self.addPlacholderPhoto()
            }
            
            self.activityIndicator.stopAnimating()
            
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell

        // Set image.
        FlickrClient.getPhoto(url: <#T##URL#>, completion: <#T##(UIImage?, Error?) -> Void#>)
        cell.imageView?.image = UIImage(data: photos[indexPath.row].photo!)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
 
    }
}

public extension UIImage {
    func copy(newSize: CGSize, retina: Bool = true) -> UIImage? {
        // In next line, pass 0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1 to force exact pixel size.
        UIGraphicsBeginImageContextWithOptions(
            /* size: */ newSize,
            /* opaque: */ false,
            /* scale: */ retina ? 0 : 1
        )
        defer { UIGraphicsEndImageContext() }

        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

