//
//  DataController.swift
//  VirtualTourist
//
//  Created by Jonathan Mason on 04/10/2021.
//

import Foundation
import CoreData

///
/// Based on "What Is a Singleton and How To Create One In Swift" by Bart Jacobs:
/// https://cocoacasts.com/what-is-a-singleton-and-how-to-create-one-in-swift/
class DataController {
    
    static let shared = DataController()
    
    let persistentContainer = NSPersistentContainer(name: "TravelLocations")
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
           
    func load() {
        persistentContainer.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
    }
}
