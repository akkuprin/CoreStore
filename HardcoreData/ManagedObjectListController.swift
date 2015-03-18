//
//  ManagedObjectListController.swift
//  HardcoreData
//
//  Copyright (c) 2015 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import CoreData
import GCDKit


// MARK: - ManagedObjectListController

public final class ManagedObjectListController<T: NSManagedObject>: NSFetchedResultsControllerDelegate {
    
    // MARK: Public
    
    public typealias EntityType = T
    
    public func addObserver<U: ManagedObjectListObserver where U.EntityType == EntityType>(observer: U) {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to add a <\(U.self)> outside the main queue.")
        
        self.observers.addObject(observer)
    }
    
    public func removeObserver<U: ManagedObjectListObserver where U.EntityType == EntityType>(observer: U) {
        
        HardcoreData.assert(GCDQueue.Main.isCurrentExecutionContext(), "Attempted to remove a <\(U.self)> outside the main queue.")
        
        self.observers.removeObject(observer)
    }
    
    
    // MARK: NSFetchedResultsControllerDelegate
    
    private func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
    }
    
    private func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
    }
    
    private func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    private func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
    }
    
    private func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String?) -> String? {
        
        return nil
    }
    
    
    // MARK: Internal
    
    internal init(dataStack: DataStack, entity: T.Type, sectionNameKeyPath: KeyPath?, cacheResults: Bool, queryClauses: [FetchClause]) {
        
        let context = dataStack.mainContext
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = context.entityDescriptionForEntityClass(entity)
        fetchRequest.fetchLimit = 0
        fetchRequest.resultType = .ManagedObjectResultType
        
        for clause in queryClauses {
            
            clause.applyToFetchRequest(fetchRequest)
        }
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: (cacheResults
                ? "\(ManagedObjectListController<T>.self).\(NSUUID())"
                : nil)
        )
        
        
        self.fetchedResultsController = fetchedResultsController
        self.parentStack = dataStack
        self.observers = NSHashTable.weakObjectsHashTable()
        
        fetchedResultsController.delegate = self
        
        var error: NSError?
        if !fetchedResultsController.performFetch(&error) {
            
            HardcoreData.handleError(
                error ?? NSError(hardcoreDataErrorCode: .UnknownError),
                "Failed to perform fetch on \(NSFetchedResultsController.self)")
        }
    }
    
    
    // MARK: Private
    
    private let fetchedResultsController: NSFetchedResultsController
    private weak var parentStack: DataStack?
    private let observers: NSHashTable
}