//
//  Matrix.swift
//  Vigenere
//
//  Created by Vincent PUGET on 05/08/2015.
//  Copyright (c) 2015 Vincent PUGET. All rights reserved.
//

import Foundation
import CoreData

@objc(Matrix)

class Matrix: NSManagedObject {

    @NSManaged var matrix: String
    @NSManaged var name: String

}
