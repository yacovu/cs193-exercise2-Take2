//
//  Card.swift
//  Set Take2
//
//  Created by Yacov Uziel on 05/10/2018.
//  Copyright © 2018 Yacov Uziel. All rights reserved.
//

import Foundation

struct Card {
    var isMatched: Bool
    private(set) var identifier: Int
    var shape: Int
    var color: Int
    var filling: Int
    var numOfShapes: Int
    
    static var uniqueIdentifier = -1
    
    static func getNextUniqueIdentifier() -> Int {
        uniqueIdentifier += 1
        return uniqueIdentifier
    }
    
    public init(shape: Int, color: Int, filling: Int, numOfShapes: Int) {
        self.identifier = Card.getNextUniqueIdentifier()
        self.isMatched = false
        self.shape = shape
        self.color = color
        self.filling = filling
        self.numOfShapes = numOfShapes
    }
    
    static func ==(leftElement: Card, rightElement: Card) -> Bool {
        return leftElement.identifier == rightElement.identifier
    }
}
