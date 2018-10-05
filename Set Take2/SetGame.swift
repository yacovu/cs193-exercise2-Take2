//
//  SetGame.swift
//  Set Take2
//
//  Created by Yacov Uziel on 05/10/2018.
//  Copyright © 2018 Yacov Uziel. All rights reserved.
//

import Foundation


class SetGame {
    
    private(set) var deck = [Card]()
    var cardsOnGameBoard = [Card]()
    var selectedCards = [Card]()
    var alreadyMatchedCards = [Card]()
    private let numOfCardsOnStart = 12
    private let numOfShapes = 3
    private let numOfColors = 3
    private let numOfFillings = 3
    private let numOfShapesQuantity = 3
    lazy private var deckCapacity = numOfShapes * numOfColors * numOfFillings * numOfShapesQuantity
    
    func dealThreeNewCards() {
        
    }
    
    func tryToMatchCards(firstElement firstCard: Card, secondElement secondCard: Card, thirdElement thirdCard: Card) {
        
    }
    
    func initDeck() {
        for shapeIndex in 0..<numOfShapes {
            for colorIndex in 0..<numOfColors {
                for fillingIndex in 0..<numOfFillings {
                    for numOfShapesIndex in 0..<numOfShapesQuantity {
                        deck.append(Card(shape: shapeIndex, color: colorIndex, filling: fillingIndex, numOfShapes: numOfShapesIndex))
                    }
                }
            }
        }
        shuffleDeck()
    }
    
    func shuffleDeck() {
        for _ in 1...deckCapacity {
            let firstRandomIndex = Int(arc4random_uniform(UInt32(deck.count)))
            let secondRandomIndex = Int(arc4random_uniform(UInt32(deck.count)))
            deck.swapAt(firstRandomIndex, secondRandomIndex)
        }
    }
    
    func initGameBoard () {
        for _ in 1...numOfCardsOnStart {
            cardsOnGameBoard.append(deck.popLast()!)
        }
    }
    
    init() {
        initDeck()
        shuffleDeck()
        initGameBoard()
    }
    
    
    
}
