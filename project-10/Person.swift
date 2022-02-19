//
//  Person.swift
//  project-10
//
//  Created by Bruno Guirra on 19/02/22.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String) {
        self.name = name
        self.image = image
    }
}
