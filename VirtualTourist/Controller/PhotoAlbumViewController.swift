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
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var travelLocation: TravelLocation!
    var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if travelLocation == nil {
            fatalError("Travel location not set whilst attempting to displaying photo album.")
        }
        
        // From "Code for Collection View Flow Layout" of "Lesson 8: Complete
        // the MemeMe App".
        // Size cells according to screen size.
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        // Create annotation for travel location.
        generateAnnotation();
        
        // Load photos for travel location from data store, if any, otherwise, Flickr.
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
        
        // Prevent attempt to load new collection of photos.
        button.isEnabled = false
        
        FlickrClient.getPhotoURLsForLocation(latitude: travelLocation.latitude, longitude: travelLocation.longitude) { urls, error in
            
            // Stop indicating activity.
            self.activityIndicator.stopAnimating()
            
            guard error == nil else {
                ControllerHelpers.showMessage(parent: self, caption: "Flckr Error", introMessage: "There was a problem downloading photo URLs from Flickr.", error: error)
                return
            }
            
            if urls.count <= 0 {
                // Show message that there are no photos.
                self.label.isHidden = false;
            }
            else {
                // Allow new photo collection of photos to be loaded.
                self.button.isEnabled = true
                
                // Create empty photos, to be downloaded as collection view draws its cells.
                for url in urls {
                    self.addEmptyPhotos(url: url)
                }
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

        // Retrieve cell.
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
                        // Update image in cell...
                        cell.imageView?.image = image
                        
                        // ...and data store.
                        photo.photo = image.pngData()
                        DataController.shared.save()
                    }
                }
            }
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        let photo = photos[indexPath.row]
        
        // Remove from local array.
        photos.remove(at: indexPath.row)
        
        // From answer to "How to delete a Cell from Collection View?" by Anbu.Karthik :
        // https://stackoverflow.com/questions/39763968/how-to-delete-a-cell-from-collection-view
        // Remove from collection view.
        collectionView.deleteItems(at: [indexPath])
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        
        // From answer to "Reactive CollectionView on Delete" by Francisco G:
        // https://knowledge.udacity.com/questions/437853
        // Remove from data store.
        DataController.shared.viewContext.delete(photo)
        DataController.shared.save()
    }
    
    /// Handle press of button to delete all photos and download more.
    @IBAction func newCollectionPressed() {
        // From answer to "Reactive CollectionView on Delete" by Francisco G:
        // https://knowledge.udacity.com/questions/437853
        // Remove from data store.
        for photo in photos {
            DataController.shared.viewContext.delete(photo)
        }
        DataController.shared.save()
        
        // Remove from local array.
        photos.removeAll()
        
        // Make collection view reflect empty array.
        collectionView.reloadData()
        
        // Load photos for travel location from Flickr.
        loadPhotosForTravelLocationFromFlickr();
    }
}
