//
//  DynamicLayout.swift
//  Set Take2
//
//  Created by Yacov Uziel on 10/10/2018.
//  Copyright © 2018 Yacov Uziel. All rights reserved.
//

import Foundation

protocol DynamicLayout {
    
    //adds 3 new cards to the board so they will fit
    func addNewCardsToGameBoard()
    
    //changes the location of the cards on the game board randomly
    func shuffleGameBoardCards()
    
    //Changes the location of the remaining cards after matching cards were removed from the screen and there are no more cards in the deck
    func reformUp()

}
