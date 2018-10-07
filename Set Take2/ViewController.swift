//
//  ViewController.swift
//  Set Take2
//
//  Created by Yacov Uziel on 05/10/2018.
//  Copyright © 2018 Yacov Uziel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private(set) var colors = ["red", "green", "blue"]
    private(set) var shading = ["blank","semiFilled","fullyFilled"]
    private(set) var numberOfShapes = [1,2,3]
    lazy private(set) var shapes = ["diamond", "square", "circle"]
    private var selectedButtons = [UIButton]()
    private var needToDealNewCards = false
    private var freeButtonIndex = 12
    let blankDiamond = NSAttributedString(string: "\u{25CA}")
    private let blankSquare = NSAttributedString(string: "\u{25A2}")
    private let blankCircle = NSAttributedString(string: "\u{25EF}")
    
    private let semiFilledDiamond = NSAttributedString(string: "\u{25C8}")
    private let semiFilledSquare = NSAttributedString(string: "\u{25A3}")
    private let semiFilledCircle = NSAttributedString(string: "\u{25C9}")
    
    private let fullyDiamond = NSAttributedString(string: "\u{25C6}")
    private let fullySquare = NSAttributedString(string: "\u{25A0}")
    private let fullyCircle = NSAttributedString(string: "\u{25CF}")
    
    lazy var shapeToFilling = ["diamond":[blankDiamond, semiFilledDiamond, fullyDiamond],
                               "square": [blankSquare, semiFilledSquare, fullySquare],
                               "circle": [blankCircle, semiFilledCircle, fullyCircle]]
    
    lazy var colornameToUIColor = ["red": UIColor.red, "green": UIColor.green, "blue": UIColor.blue]
    
    enum colorType: Int {
        case red
        case green
        case blue
    }
    
    var game = SetGame()
    
    @IBOutlet weak var dealNewCardsButton: UIButton!
    
    @IBOutlet weak var playerScoreLabel: UILabel!
    
    @IBOutlet weak var cardsInDeckLabel: UILabel!
    
    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initBoard()
    }
    
    @IBAction func dealNewCardsClick(_ sender: UIButton) {
        dealNewCards()
        changeButtonsLayoutToNotSelected()
    }
    
    @IBAction func hintClick(_ sender: UIButton) {
        selectedButtons.removeAll()
        showHintOnGameBoard()
    }
    
    @IBAction func newGameClick(_ sender: UIButton) {
        startNewGame()
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        touchButton(touchedButton: sender)
    }    
    
    func startNewGame(){
        game = SetGame()
        resetButtons()
        selectedButtons.removeAll()
        needToDealNewCards = false
        self.dealNewCardsButton.isEnabled = true
        freeButtonIndex = 12
        initBoard()
        updateLabelsInUI()
    }
    
    func resetButtons() {
        for buttonIndex in 0..<self.buttons.count {
            self.buttons[buttonIndex].layer.borderWidth = 0
            self.buttons[buttonIndex].setAttributedTitle(NSAttributedString(string: ""), for: UIControlState.normal)
            self.buttons[buttonIndex].layer.backgroundColor = UIColor.white.cgColor
            self.buttons[buttonIndex].layer.cornerRadius = 0
        }
    }
    
    func initBoard() {
        self.buttons.disableAllElements()
        let cardsOnGameBoard = game.getCardsOnGameBoard()
        
        for cardIndex in 0..<cardsOnGameBoard.count {
            connectButtonToCard(cardToConnect: cardsOnGameBoard[cardIndex], buttonToConnect: self.buttons[cardIndex])
        }
        for buttonIndex in 0..<game.maxNumOfCards {
            buttons[buttonIndex].layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func concatenateShapeAccordingToCardProperty(cardToGetShapeFrom card: Card) -> NSAttributedString {
        let shape = self.shapeToFilling[self.shapes[card.shape]]![card.filling].string
        let colorName = self.colors[colorType(rawValue: card.color)!.rawValue]
        var fixedShape = shape
        
        for _ in 0..<card.numOfShapes {
            fixedShape += shape
        }
        return NSAttributedString(string: fixedShape, attributes: [NSAttributedStringKey.foregroundColor : self.colornameToUIColor[colorName]!])
    }
    
    func connectButtonToCard(cardToConnect card: Card, buttonToConnect button: UIButton) {
        button.setAttributedTitle(concatenateShapeAccordingToCardProperty(cardToGetShapeFrom: card), for: UIControlState.normal)
        button.tag = card.identifier
        button.isEnabled = true
    }
    
    func touchButton(touchedButton button: UIButton) {
        if self.needToDealNewCards { // in case a match was found in the previous turn
            dealNewCards()
        }
        if self.selectedButtons.count == 0 {
            changeButtonsLayoutToNotSelected()
        }
        button.changeLayout(to: getButtonLayoutOnClick)
        if selectedButtons.contains(button) { // deselect button
            removeButtonFromSelectedButtons(selectedButton: button)
        }
        else { // select button
            self.selectedButtons.append(button)
        }
        if selectedButtons.count == 3 {
           handleThreeButtonsSelected(touchedButton: button)
        }
        updateLabelsInUI()
    }
    
    func handleThreeButtonsSelected(touchedButton button: UIButton) {
        checkIfSelectedButtonsAreSet()
        selectedButtons.removeAll()
        checkIfNeedToEndGame()
    }
    
    func checkIfNeedToEndGame() {
        if game.needToEndGame() {
            gameOver()
        }
    }
    
    func removeCardsFromGameBoard() {
        for button in self.selectedButtons {
            game.removeCardFromGameBoard(cardToBeRemoved: getCardInGameBoard(fromButtonElement: button)!)
        }
    }
    
    func removeSelectedButtonsFromUI() {
        for button in self.selectedButtons {
            button.setAttributedTitle(NSAttributedString(string: ""), for: UIControlState.normal)
            button.layer.borderWidth = 0
            button.layer.backgroundColor = UIColor.clear.cgColor
            button.layer.cornerRadius = 0
            button.isEnabled = false
        }
    }
    
    func removeButtonFromSelectedButtons(selectedButton buttonToRemove: UIButton) {
        var found = false
        for buttonIndex in 0..<self.selectedButtons.count where !found{
            if self.selectedButtons[buttonIndex] == buttonToRemove {
                self.selectedButtons.remove(at: buttonIndex)
                found = true
            }
        }
    }
        
    func getButtonLayoutOnClick(ofButton button: UIButton) -> CGColor? {
        return button.layer.borderColor
    }
    
    func checkIfSelectedButtonsAreSet() {
        if selectedButtons.count == 3 {
            let firstCard = getCardInGameBoard(fromButtonElement: selectedButtons[0])!
            let secondCard = getCardInGameBoard(fromButtonElement: selectedButtons[1])!
            let thirdCard = getCardInGameBoard(fromButtonElement: selectedButtons[2])!
            if game.isASet(firstCard: firstCard, secondCard: secondCard, thirdCard: thirdCard) {
//                dealNewCardsButton.isEnabled = true
                changeButtonsLayoutToLegalSet()
                game.changeCardsToMatched(firstCard: firstCard, secondCard: secondCard, thirdCard: thirdCard)
                self.needToDealNewCards = true
                dealNewCardsButton.isEnabled = true
                game.scorePlayer += 3
                if game.deck.count == 0 {
                    removeSelectedButtonsFromUI()
                    removeCardsFromGameBoard()
                    dealNewCardsButton.isEnabled = false
                }
            }
            else {
                changeButtonsLayoutToNotSet()
                game.scorePlayer -= 5
            }
        }
    }
    
    func updateLabelsInUI() {
        playerScoreLabel.text = "Player's Score: \(game.scorePlayer)"
        cardsInDeckLabel.text = "Cards in Deck: \(game.deck.count)"
    }
    
    func removeSetFromGameBoard() {
        var cardsToBeRemoved = [Card]()
        let cardsOnGameBoard = game.getCardsOnGameBoard()
        
        for card in cardsOnGameBoard {
            if card.isMatched {
                cardsToBeRemoved.append(card)
            }
        }
        game.removeCardFromGameBoard(cardToBeRemoved: cardsToBeRemoved[0])
        game.removeCardFromGameBoard(cardToBeRemoved: cardsToBeRemoved[1])
        game.removeCardFromGameBoard(cardToBeRemoved: cardsToBeRemoved[2])
    }
    
    func dealNewCards() {
        if game.deck.count >= 3 {
            let newCards =  game.dealThreeNewCards()
            let matchedCards = getMatchedCards()
            
            if matchedCards.count == 3 {
                replaceSelectedCards(matchedCards: matchedCards, withNewCards: newCards)
            }
            else {
                dealCardsToNewButtons(newCardsToDeal: newCards)
            }
        }
        else {
            self.dealNewCardsButton.isEnabled = false
        }
    }
    
    func getMatchedCards() -> [Card] {
        var matchedCards = [Card]()
        let cardsOnGameBoard = game.getCardsOnGameBoard()
        
        for card in cardsOnGameBoard {
            if card.isMatched {
                matchedCards.append(card)
            }
        }
        return matchedCards
    }
    
    func dealCardsToNewButtons(newCardsToDeal newCards: [Card]) {
        if freeButtonIndex < 24 {
            for index in 0..<3 {
                connectButtonToCard(cardToConnect: newCards[index], buttonToConnect: self.buttons[self.freeButtonIndex])
                freeButtonIndex += 1
            }
            if game.cardsOnGameBoard.count == game.maxNumOfCards {
                self.dealNewCardsButton.isEnabled = false
            }
        }
        else {
            self.dealNewCardsButton.isEnabled = false
        }
    }
    
    func replaceSelectedCards(matchedCards matched: [Card], withNewCards newCards: [Card]) {
        for cardIndex in 0..<matched.count {
            for buttonIndex in 0..<self.buttons.count {
                if self.buttons[buttonIndex].tag == matched[cardIndex].identifier {
                    connectButtonToCard(cardToConnect: newCards[cardIndex], buttonToConnect: self.buttons[buttonIndex])
                }
            }
        }
        if game.cardsOnGameBoard.count >= game.maxNumOfCards {
            self.dealNewCardsButton.isEnabled = false
        }
        self.needToDealNewCards = false
        removeSetFromGameBoard()
    }
    
    func showHintOnGameBoard() {
        var legalSetCards = game.getALegalSet()
        if legalSetCards.count == 3 {
            let firstButtonIndex = getButtonIndexInButtonsArray(fromCardElement: legalSetCards[0])
            let secondButtonIndex = getButtonIndexInButtonsArray(fromCardElement: legalSetCards[1])
            let thirdButtonIndex = getButtonIndexInButtonsArray(fromCardElement: legalSetCards[2])

            changeToSetLayout(buttonToChange: self.buttons[firstButtonIndex])
            changeToSetLayout(buttonToChange: self.buttons[secondButtonIndex])
            changeToSetLayout(buttonToChange: self.buttons[thirdButtonIndex])
        }
    }
    
    func gameOver() {
        let alert = UIAlertController(title: "Game Over", message: "No Further Moves!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.default, handler: {action in self.game.exitGame()}))
        alert.addAction(UIAlertAction(title: "New Game", style: UIAlertActionStyle.default, handler: {action in self.startNewGame()}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func changeToSetLayout(buttonToChange button: UIButton) {
        button.layer.borderWidth = 3.0
        button.layer.borderColor = UIColor.orange.cgColor
        button.layer.cornerRadius = 8.0
    }
    
    func changeButtonsLayoutToLegalSet() {
        for button in selectedButtons {
            button.layer.borderWidth = 3.0
            button.layer.borderColor = UIColor.green.cgColor
            button.layer.cornerRadius = 8.0
        }
    }
    
    func changeButtonsLayoutToNotSet() {
        for button in selectedButtons {
            button.layer.borderWidth = 3.0
            button.layer.borderColor = UIColor.red.cgColor
            button.layer.cornerRadius = 8.0
        }
    }
    
    func changeButtonsLayoutToNotSelected() {
        for button in buttons {
            button.layer.borderWidth = 0
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.cornerRadius = 0
        }
    }
    
    func getCardInGameBoard(fromButtonElement button: UIButton) -> Card? {
        let cardsInGameBoard = game.getCardsOnGameBoard()
        
        for card in cardsInGameBoard {
            if card.identifier == button.tag {
                return card
            }
        }
        return nil
    }
    
    func getButtonIndexInButtonsArray(fromCardElement card: Card) -> Int {
        for buttonIndex in 0..<self.buttons.count {
            if self.buttons[buttonIndex].tag == card.identifier {
                return buttonIndex
            }
        }
        return -1
    }
}

extension UIButton {
    func changeLayout(to closureRef: (UIButton) -> CGColor?) {
        if closureRef(self) == UIColor.white.cgColor || self.layer.borderColor == UIColor.orange.cgColor || self.layer.borderColor == UIColor.red.cgColor {
            self.layer.borderWidth = 3.0
            self.layer.borderColor = UIColor.blue.cgColor
            self.layer.cornerRadius = 8.0
        }
        else if closureRef(self) == UIColor.blue.cgColor {
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.cornerRadius = 0
        }
    }
}

extension Array where Element:UIButton {
    func disableAllElements() {
        for element in self {
            element.isEnabled = false
            element.tag = -1
        }
    }
}

