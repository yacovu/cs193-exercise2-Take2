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
    private let numOfCardsOnStart = 12
    private(set) var maxNumOfCards = 24
    private let numOfShapes = 3
    private let numOfColors = 3
    private let numOfFillings = 3
    private let numOfShapesQuantity = 3
    var scorePlayer = 0
    lazy private var deckCapacity = numOfShapes * numOfColors * numOfFillings * numOfShapesQuantity
    
    func dealThreeNewCards() -> [Int] {
        var indexesOfnewCards = [Int]()
        
        for _ in 1...3 {
            self.cardsOnGameBoard.append(deck.popLast()!)
            indexesOfnewCards.append(self.cardsOnGameBoard.count - 1) //check if it adds always to the end of the array
        }
        return indexesOfnewCards
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
    
    func isASet(firstCard firstcard: Card, secondCard secondcard: Card, thirdCard thirdcard: Card) -> Bool {
        return !(firstcard.isMatched && secondcard.isMatched && thirdcard.isMatched)
            && (firstcard.identifier != secondcard.identifier && secondcard.identifier != thirdcard.identifier && firstcard.identifier != thirdcard.identifier)
            && (haveSameNumberOfShapes(firstCard: firstcard, secondCard: secondcard, thirdCard: thirdcard) || haveThreeDifferentNumberOfShapes(firstCard: firstcard, secondCard: secondcard, thirdCard: thirdcard))
            && (haveSameShape(firstCard: firstcard, secondCard: secondcard, thirdCard: thirdcard) || haveThreeDifferentShapes(firstCard: firstcard, secondCard: secondcard, thirdCard: thirdcard))
            && (haveSameFilling(firstCard: firstcard, secondCard: secondcard, thirdCard: thirdcard) || haveThreeDifferentFillings(firstCard: firstcard, secondCard: secondcard, thirdCard: thirdcard))
            && (haveSameColor(firstCard: firstcard, secondCard: secondcard, thirdCard: thirdcard) || haveThreeDifferentColors(firstCard: firstcard, secondCard: secondcard, thirdCard: thirdcard))
    }
    
    func haveSameNumberOfShapes(firstCard firstcard: Card, secondCard secondcard: Card, thirdCard thirdcard: Card) -> Bool {
        return firstcard.numOfShapes == secondcard.numOfShapes && secondcard.numOfShapes == thirdcard.numOfShapes
    }
    
    func haveThreeDifferentNumberOfShapes(firstCard firstcard: Card, secondCard secondcard: Card, thirdCard thirdcard: Card) -> Bool {
        return firstcard.numOfShapes != secondcard.numOfShapes && secondcard.numOfShapes != thirdcard.numOfShapes && firstcard.numOfShapes != thirdcard.numOfShapes
    }
    
    func haveSameShape(firstCard firstcard: Card, secondCard secondcard: Card, thirdCard thirdcard: Card) -> Bool {
        return firstcard.shape == secondcard.shape && secondcard.shape == thirdcard.shape
    }
    
    func haveThreeDifferentShapes(firstCard firstcard: Card, secondCard secondcard: Card, thirdCard thirdcard: Card) -> Bool {
        return firstcard.shape != secondcard.shape && secondcard.shape != thirdcard.shape && firstcard.shape != thirdcard.shape
    }
    
    func haveSameFilling(firstCard firstcard: Card, secondCard secondcard: Card, thirdCard thirdcard: Card) -> Bool {
        return firstcard.filling == secondcard.filling && secondcard.filling == thirdcard.filling
    }
    
    func haveThreeDifferentFillings(firstCard firstcard: Card, secondCard secondcard: Card, thirdCard thirdcard: Card) -> Bool {
        return firstcard.filling != secondcard.filling && secondcard.filling != thirdcard.filling && firstcard.filling != thirdcard.filling
    }
    
    func haveSameColor(firstCard firstcard: Card, secondCard secondcard: Card, thirdCard thirdcard: Card) -> Bool {
        return firstcard.color == secondcard.color && secondcard.color == thirdcard.color
    }
    
    func haveThreeDifferentColors(firstCard firstcard: Card, secondCard secondcard: Card, thirdCard thirdcard: Card) -> Bool {
        return firstcard.color != secondcard.color && secondcard.color != thirdcard.color && firstcard.color != thirdcard.color
    }
    
    func removeCardFromGameBoard(cardIndex index: Int) {
        self.cardsOnGameBoard.remove(at: index)
    }
    
    func exitGame() {
        exit(0)
    }
    
    func getALegalSet() -> [Int] {
        var found = false
        var setIndexes = [Int]()
        
        for firstCardIndex in 0..<cardsOnGameBoard.count where !found {
            for secondCardIndex in 0..<cardsOnGameBoard.count where !found {
                for thirdCardIndex in 0..<cardsOnGameBoard.count where !found {
                    if isASet(firstCard: cardsOnGameBoard[firstCardIndex], secondCard: cardsOnGameBoard[secondCardIndex], thirdCard: cardsOnGameBoard[thirdCardIndex]) {
                        setIndexes = [firstCardIndex, secondCardIndex, thirdCardIndex]
                        found = true
                    }
                }
            }
        }
        return setIndexes
    }
    
    func changeCardsToMatched(firstCardIndex firstIndex: Int, secondCardIndex secondIndex: Int, thirdCardIndex thirdIndex: Int) {
        cardsOnGameBoard[firstIndex].isMatched = true
        cardsOnGameBoard[secondIndex].isMatched = true
        cardsOnGameBoard[thirdIndex].isMatched = true
    }
    
    func needToEndGame() -> Bool {
        return cardsOnGameBoard.count == 0 || (getALegalSet().count == 0 && deck.count == 0)
    }
    
    init() {
        initDeck()
        shuffleDeck()
        initGameBoard()
    }    
}
