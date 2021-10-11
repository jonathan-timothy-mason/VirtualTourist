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
    
    /// Load photos for travel location from Flickr.
    func loadPhotosForTravelLocationFromFlickr() {
        
        // Indicate activity while photo URLs are being downloaded, before
        // number of placeholders is known.
        activityIndicator.startAnimating()
        
        FlickrClient.getPhotoURLsForLocation(latitude: travelLocation.latitude, longitude: travelLocation.longitude) { urls, error in
            
            // Stop indicating activity.
            self.activityIndicator.stopAnimating()
            
            guard error == nil else {
                ControllerHelpers.showMessage(parent: self, caption: "Flckr Error", introMessage: "There was a problem downloading photo URLs from Flickr.", error: error)
                return
            }
            
            // Create empty photos, to be downloaded as collection view draws its cells.
            for url in urls {
                self.addEmptyPhotos(url: url)
            }

            self.collectionView.reloadData()
        }
    }
    
    /// Create placeholder photo with URL, leaving image data empty, to be loaded by collection view.
    /// - Parameter url: URL of photo to be downloaded.
    func addEmptyPhotos(url: String) {
        let newPhoto = Photo(context: DataController.shared.viewContext)
        newPhoto.url = url
        newPhoto.travelLocation = travelLocation
        photos.append(newPhoto)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell

        let photo = photos[indexPath.row]
        if let photo = photo.photo {
            // Image has been downloaded, so set it.
            cell.imageView?.image = UIImage(data: photo)
        }
        else {
            // Image has not been downloaded, so set placeholder image...
            cell.imageView?.image = UIImage(systemName: "doc.text.image")
            
            // ... and download actual one.
            if let urlString = photo.url, let url = URL(string: urlString) {
                FlickrClient.getPhoto(url: url) { image, error in
                    if let image = image {
                        photo.photo = image.pngData()
                        cell.imageView?.image = image
                        try! DataController.shared.viewContext.save()
                    }
                }
            }
            
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
 
    }
}
