//
//  AppSingleton.swift
//  Vigenere
//
//  Created by Vincent PUGET on 20/08/2014.
//  Copyright (c) 2014 JPM & Associes. All rights reserved.
//

import Cocoa
import CoreData

class DataSingleton: NSObject
{
    
    class var instance : DataSingleton
    {
        struct Static
        {
            static let instance : DataSingleton = DataSingleton()
        }
        
        return Static.instance
    }
    
    func dropAllMatrix()
    {
        let fetchRequestMatrix = NSFetchRequest<NSFetchRequestResult>(entityName: "Matrix")
        if let fetchResultMatrix = (try? self.managedObjectContext!.fetch(fetchRequestMatrix)) as? [Matrix]
        {
            for data:AnyObject in fetchResultMatrix
            {
                self.managedObjectContext!.delete(data as! Matrix)
            }
        }
        
        var error: NSError?
        
        do {
            try self.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let err = error
        {
            L.v(err.localizedFailureReason as AnyObject!);
        }
        else
        {
            L.v("DROP Matrix OK" as AnyObject!)
        }
    }
    
    func createDefaultMatrix() -> Bool
    {
        return DataSingleton.instance.saveNewMatrix("Matrice1", matrix: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz@&é\"'(§è!çà)-_°0987654321#$ù%=+:/;.,?\\âêûîôäëüïöÂÊÛÎÔÄËÜÏÖ£`’ €÷*|~⇒…{}[]")
    }
    
    func setDefaultMatrix(_ matrixObj:Matrix!) -> Bool
    {
        return DataSingleton.instance.saveThisMatrix(matrixObj, name: matrixObj.name, matrix: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz@&é\"'(§è!çà)-_°0987654321#$ù%=+:/;.,?\\âêûîôäëüïöÂÊÛÎÔÄËÜÏÖ£`’ €÷*|~⇒…{}[]")
    }
    
    func getMatrixObject() -> Matrix?
    {
        var matrix:Matrix?;
      
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Matrix")
        
        if let fetchResults = (try? self.managedObjectContext!.fetch(fetchRequest)) as? [Matrix]
        {
            if(fetchResults.count > 0)
            {
                matrix = fetchResults[0];
            }
        }
        return matrix;
    }
    
    func saveNewMatrix(_ name:String! , matrix:String!) -> Bool
    {
        var result:Bool! = false;
        
        let newMatrixObj:Matrix! = NSEntityDescription.insertNewObject(forEntityName: "Matrix", into: self.managedObjectContext!) as! Matrix
        newMatrixObj.name = name;
        newMatrixObj.matrix = matrix;
        
        var error: NSError?
        
        do {
            try self.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let err = error
        {
            L.v(err.localizedFailureReason as AnyObject!);
        }
        else
        {
            L.v("Save new matrix OK" as AnyObject!)
            
            result = true;
        }
        
        return result
    }
    
    func saveThisMatrix(_ matrixObj:Matrix! , name:String! , matrix:String!) -> Bool
    {
        var result:Bool! = false;
        
        matrixObj.name = name;
        matrixObj.matrix = matrix;
        
        var error: NSError?
        
        do {
            try self.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let err = error
        {
            L.v(err.localizedFailureReason as AnyObject!);
        }
        else
        {
            L.v("Save this matrix OK" as AnyObject!)
            
            result = true;
        }
        
        return result
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "mao.macos.Vigenere" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1] 
        return appSupportURL.appendingPathComponent("mao.macos.Vigenere")
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Vigenere", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = FileManager.default
        var shouldFail = false
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // Make sure the application files directory is there
        let propertiesOpt: [AnyHashable: Any]?
        do {
            propertiesOpt = try (self.applicationDocumentsDirectory as NSURL).resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
        } catch var error1 as NSError {
            error = error1
            propertiesOpt = nil
        } catch {
            fatalError()
        }
        if let properties = propertiesOpt {
            if !(properties[URLResourceKey.isDirectoryKey]! as AnyObject).boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } else if error!.code == NSFileReadNoSuchFileError {
            error = nil
            do {
                try fileManager.createDirectory(atPath: self.applicationDocumentsDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch var error1 as NSError {
                error = error1
            } catch {
                fatalError()
            }
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator?
        if !shouldFail && (error == nil) {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.appendingPathComponent("Vigenere.storedata")
            do {
                try coordinator!.addPersistentStore(ofType: NSXMLStoreType, configurationName: nil, at: url, options: nil)
            } catch var error1 as NSError {
                error = error1
                coordinator = nil
            } catch {
                fatalError()
            }
        }
        
        if shouldFail || (error != nil) {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            if error != nil {
                dict[NSUnderlyingErrorKey] = error
            }
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSApplication.shared().presentError(error!)
            return nil
        } else {
            return coordinator
        }
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving and Undo support
    
    @IBAction func saveAction(_ sender: AnyObject!) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if let moc = self.managedObjectContext {
            if !moc.commitEditing() {
                NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
            }
            var error: NSError? = nil
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                    NSApplication.shared().presentError(error!)
                }
            }
        }
    }
    
    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        if let moc = self.managedObjectContext {
            return moc.undoManager
        } else {
            return nil
        }
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        if let moc = managedObjectContext {
            if !moc.commitEditing() {
                NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
                return .terminateCancel
            }
            
            if !moc.hasChanges {
                return .terminateNow
            }
            
            var error: NSError? = nil
            do {
                try moc.save()
            } catch let error1 as NSError {
                error = error1
                // Customize this code block to include application-specific recovery steps.
                let result = sender.presentError(error!)
                if (result) {
                    return .terminateCancel
                }
                
                let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
                let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
                let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
                let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
                let alert = NSAlert()
                alert.messageText = question
                alert.informativeText = info
                alert.addButton(withTitle: quitButton)
                alert.addButton(withTitle: cancelButton)
                
                let answer = alert.runModal()
                if answer == NSAlertFirstButtonReturn {
                    return .terminateCancel
                }
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
    
}
