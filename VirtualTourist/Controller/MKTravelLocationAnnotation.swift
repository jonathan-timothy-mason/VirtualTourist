//
//  MKTravelLocationAnnotation.swift
//  VirtualTourist
//
//  Created by Jonathan Mason on 10/10/2021.
//

import MapKit

/// Map annotation including TravelLocation.
/// Inspired by  Gamaliel Tellez Ortiz's question "How to create a custom class that conforms to MKAnnotation
/// protocol.":
/// https://stackoverflow.com/questions/32323080/how-to-create-a-custom-class-that-conforms-to-mkannotation-protocol
class MKTravelLocationAnnotation: MKPointAnnotation {
    /// Travel location associated with annotation.
    var TravelLocation: TravelLocation
    
    /// Initialiser.
    /// - Parameter travelLocation: Travel location associated with annotation.
    init(_ travelLocation: TravelLocation) {
        TravelLocation = travelLocation
    }
}
