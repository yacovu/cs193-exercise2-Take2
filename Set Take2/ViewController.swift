//
//  ViewController.swift
//  Set Take2
//
//  Created by Yacov Uziel on 05/10/2018.
//  Copyright © 2018 Yacov Uziel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initBoard()
        
    }
    
    @IBOutlet weak var dealNewCardsButton: UIButton!
    
    @IBAction func dealNewCardsClick(_ sender: UIButton) {
        dealNewCards()
        changeButtonsToNotSelected()
    }
    
    @IBAction func hintClick(_ sender: UIButton) {
        selectedButtons.removeAll()
        showHintOnGameBoard()
    }
    
    @IBAction func newGameClick(_ sender: UIButton) {
        startNewGame()
    }
    
    @IBOutlet weak var playerScoreLabel: UILabel!
    
    @IBOutlet weak var cardsInDeckLabel: UILabel!
    
    @IBOutlet var buttons: [UIButton]!
    
    @IBAction func buttonClick(_ sender: UIButton) {
        touchButton(touchedButton: sender)
    }
    
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
    
    var game = SetGame()
    
    func startNewGame(){
        game = SetGame()
        resetButtons()
        selectedButtons.removeAll()
        needToDealNewCards = false
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
            if buttonIndex >= self.freeButtonIndex {
                self.buttons[buttonIndex].isEnabled = false
            }
        }
    }
    
    func initBoard() {
        disableAllButtons()
        for buttonIndex in 0..<game.cardsOnGameBoard.count {
            connectButtonToCard(cardToConnect: game.cardsOnGameBoard[buttonIndex], buttonToConnect: self.buttons[buttonIndex])
        }
        for buttonIndex in 0..<game.maxNumOfCards {
            buttons[buttonIndex].layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func disableAllButtons() {
        for button in buttons {
            button.isEnabled = false
        }
    }
    
    func concatenateShapeAccordingToCardProperty(cardToGetShapeFrom card: Card) -> NSAttributedString {
        let shape = self.shapeToFilling[self.shapes[card.shape]]![card.filling].string
        var fixedShape = shape
        
        for _ in 0..<card.numOfShapes {
            fixedShape += shape
        }
        return NSAttributedString(string: fixedShape, attributes: [NSAttributedStringKey.foregroundColor : self.colornameToUIColor[self.colors[card.color]]!])
    }
    
    func connectButtonToCard(cardToConnect card: Card, buttonToConnect button: UIButton) {
        button.setAttributedTitle(concatenateShapeAccordingToCardProperty(cardToGetShapeFrom: card), for: UIControlState.normal)
        button.tag = card.identifier
        button.isEnabled = true
    }
    
    func touchButton(touchedButton button: UIButton) {
        if self.needToDealNewCards {
            dealNewCards()
        }
        if self.selectedButtons.count == 0 {
            changeButtonsToNotSelected()
        }
        changeLayoutOnClick(ofButton: button)
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
        if game.deck.count >= 3 {
            dealNewCardsButton.isEnabled = true
            checkIfButtonsAreSet(buttonToAdd: button)
        }
        else {
            removeSelectedButtonsFromUI()
            removeCardsFromGameBoard()
        }
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
            game.cardsOnGameBoard.remove(at: getCardIndexInGameBoardArray(fromButtonElement: button))
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
        
    func changeLayoutOnClick(ofButton button: UIButton) {
        if button.layer.borderColor == UIColor.white.cgColor || button.layer.borderColor == UIColor.orange.cgColor || button.layer.borderColor == UIColor.red.cgColor {
            button.layer.borderWidth = 3.0
            button.layer.borderColor = UIColor.blue.cgColor
            button.layer.cornerRadius = 8.0
        }
        else if button.layer.borderColor == UIColor.blue.cgColor {
            button.layer.borderWidth = 0
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.cornerRadius = 0
        }
    }
    
    func checkIfButtonsAreSet(buttonToAdd button: UIButton) {
        if selectedButtons.count == 3 {
            let firstCardIndex = getCardIndexInGameBoardArray(fromButtonElement: selectedButtons[0])
            let secondCardIndex = getCardIndexInGameBoardArray(fromButtonElement: selectedButtons[1])
            let thirdCardIndex = getCardIndexInGameBoardArray(fromButtonElement: selectedButtons[2])
            if game.isASet(firstCard: game.cardsOnGameBoard[firstCardIndex], secondCard: game.cardsOnGameBoard[secondCardIndex], thirdCard: game.cardsOnGameBoard[thirdCardIndex]) {
                
                changeButtonsToLegalSet()
                game.changeCardsToMatched(firstCardIndex: firstCardIndex, secondCardIndex: secondCardIndex, thirdCardIndex: thirdCardIndex)
                self.needToDealNewCards = true
                dealNewCardsButton.isEnabled = true
                game.scorePlayer += 3
            }
            else {
                changeButtonsToNotSet()
                game.scorePlayer -= 5
            }
        }
    }
    
    func updateLabelsInUI() {
        playerScoreLabel.text = "Player's Score: \(game.scorePlayer)"
        cardsInDeckLabel.text = "Cards in Deck: \(game.deck.count)"
    }
    
    func removeSetFromGameBoard() {
        var indexesToRemove = [Int]()
        for cardIndex in 0..<game.cardsOnGameBoard.count {
            if game.cardsOnGameBoard[cardIndex].isMatched {
                indexesToRemove.append(cardIndex)
            }
        }
        game.removeCardFromGameBoard(cardIndex: indexesToRemove[0])
        game.removeCardFromGameBoard(cardIndex: indexesToRemove[1] - 1)
        game.removeCardFromGameBoard(cardIndex: indexesToRemove[2] - 2)
    }
    
    func dealNewCards() {
        if game.deck.count >= 3 {
            let newCardsIndexesInGameBoard =  game.dealThreeNewCards()
            if getMatchedButtonsFromMatchedCards().count == 3 {
                replaceSelectedCards(newCardsIndex: newCardsIndexesInGameBoard, matchedCards: getMatchedButtonsFromMatchedCards())
            }
            else {
                dealCardsToNewButtons(newCardsIndex: newCardsIndexesInGameBoard)
            }
        }
        else {
            self.dealNewCardsButton.isEnabled = false
        }
    }
    
    func getMatchedButtonsFromMatchedCards() -> [Int] {
        var matchedCardsIndexes = [Int]()
        for cardIndex in 0..<game.cardsOnGameBoard.count {
            if game.cardsOnGameBoard[cardIndex].isMatched {
                matchedCardsIndexes.append(cardIndex)
            }
        }
        return matchedCardsIndexes
    }
    
    func dealCardsToNewButtons(newCardsIndex newCardsIndexesInGameBoard: [Int]) {
        if freeButtonIndex < 24 {
            for index in 0..<3 {
                connectButtonToCard(cardToConnect: game.cardsOnGameBoard[newCardsIndexesInGameBoard[index]], buttonToConnect: self.buttons[self.freeButtonIndex])
                freeButtonIndex += 1
            }
        }
    }
    
    func replaceSelectedCards(newCardsIndex newCardsIndexesInGameBoard: [Int], matchedCards matchIndexes: [Int]) {
        for cardIndex in 0..<matchIndexes.count {
            for buttonIndex in 0..<self.buttons.count {
                if self.buttons[buttonIndex].tag == game.cardsOnGameBoard[matchIndexes[cardIndex]].identifier {
                    connectButtonToCard(cardToConnect: game.cardsOnGameBoard[newCardsIndexesInGameBoard[cardIndex]], buttonToConnect: self.buttons[buttonIndex])
                }
            }
        }
        self.needToDealNewCards = false
        removeSetFromGameBoard()
    }
    
    func showHintOnGameBoard() {
        var setIndexes = game.getALegalSet()
        
        if setIndexes.count == 3 {
            let firstButtonIndex = getButtonIndexInButtonsArray(fromCardElement: game.cardsOnGameBoard[setIndexes[0]])
            let secondButtonIndex = getButtonIndexInButtonsArray(fromCardElement: game.cardsOnGameBoard[setIndexes[1]])
            let thirdButtonIndex = getButtonIndexInButtonsArray(fromCardElement: game.cardsOnGameBoard[setIndexes[2]])
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
    
    func changeButtonsToLegalSet() {
        for button in selectedButtons {
            button.layer.borderWidth = 3.0
            button.layer.borderColor = UIColor.green.cgColor
            button.layer.cornerRadius = 8.0
        }
    }
    
    func changeButtonsToNotSet() {
        for button in selectedButtons {
            button.layer.borderWidth = 3.0
            button.layer.borderColor = UIColor.red.cgColor
            button.layer.cornerRadius = 8.0
        }
    }
    
    func changeButtonsToNotSelected() {
        for button in buttons {
            button.layer.borderWidth = 0
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.cornerRadius = 0
        }
    }
    
    func getCardIndexInGameBoardArray(fromButtonElement button: UIButton) -> Int {
        for cardIndex in 0..<game.cardsOnGameBoard.count {
            if game.cardsOnGameBoard[cardIndex].identifier == button.tag {
                return cardIndex
            }
        }
        return -1
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

