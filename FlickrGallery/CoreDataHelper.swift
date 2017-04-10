import Foundation
import UIKit
import CoreData

enum CoreDataHelperError: Error {
    case malformedEntityName(String)
}

class CoreDataHelper {
    let appDelegate: AppDelegate
    let context: NSManagedObjectContext
    
    init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    func save() {
        appDelegate.saveContext()
    }
    
    func create<T: NSManagedObject>() -> T {
        return NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self), into: context) as! T
    }
    
    func remove<T: NSManagedObject>(entityInstance: T) {
        context.delete(entityInstance)
    }
    
    func fetch<T: NSManagedObject>(_ completionHandler: @escaping ([T]) -> Void) throws {
        
        context.perform {

            let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
            
            do {
                let fetched = try fetchRequest.execute()
                completionHandler(fetched)
            } catch {
                fatalError("Failed to fetch entity: \(error)")
            }
            
        }
        
    }
    
    func predicatedFetch<T: NSManagedObject>(predicate: String, _ completionHandler: @escaping ([T]) -> Void) throws {
        
        context.perform {
            
            let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
            
            fetchRequest.predicate = NSPredicate(format: predicate)

            
            do {
                let fetched = try fetchRequest.execute()
                completionHandler(fetched)
            } catch {
                fatalError("Failed to fetch entity: \(error)")
            }
            
        }
        
    }
    
}
