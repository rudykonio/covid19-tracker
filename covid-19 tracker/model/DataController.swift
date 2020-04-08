//
//  DataController.swift
//  covid-19 tracker
//
//  Created by Rodion Konioshko on 05/04/2020.
//  Copyright © 2020 Rodion Konioshko. All rights reserved.
//

import Foundation
import CoreData
class DataController{
    let persistenContainer:NSPersistentContainer

    var viewContext:NSManagedObjectContext{
        return persistenContainer.viewContext
    }

    init(modelName:String) {
        persistenContainer = NSPersistentContainer(name: modelName)
    }

    func load(completionHandler:(()->Void)? = nil){
        persistenContainer.loadPersistentStores(completionHandler: {nsPersistentStoreDescription,error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completionHandler?()
            
        })
    }
}
