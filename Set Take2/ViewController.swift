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
    
    @IBAction func dealNewCardsClick(_ sender: UIButton) {
    }
    
    @IBAction func hintClick(_ sender: UIButton) {
        getAHint()
    }
    
    @IBAction func newGameClick(_ sender: UIButton) {
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
    
    let game = SetGame()
    
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
            self.needToDealNewCards = false
            selectedButtons.removeAll()
        }
        if self.selectedButtons.count == 0 {
            changeButtonsToNotSelected()
        }
        changeLayoutOnClick(ofButton: button)
        if selectedButtons.contains(button) {
            removeButtonFromSelectedButtons(selectedButton: button)
        }
        else {
            self.selectedButtons.append(button)
        }
        if selectedButtons.count == 3 {
            checkIfButtonsAreSet(buttonToAdd: button)
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
                changeCardsToMatched(firstCardIndex: firstCardIndex, secondCardIndex: secondCardIndex, thirdCardIndex: thirdCardIndex)
                removeSetFromGameBoard()
                self.needToDealNewCards = true
                game.scorePlayer += 3
            }
            else {
                changeButtonsToNotSet()
                selectedButtons.removeAll()
            }
            updateLabelsUI()
        }
    }
    
    func updateLabelsUI() {
        playerScoreLabel.text = "Player's Score: \(game.scorePlayer)"
        cardsInDeckLabel.text = "Cards in Deck: \(game.deck.count)"
    }
    
    func removeSetFromGameBoard() {
        for button in selectedButtons {
            game.removeCardFromGameBoard(cardIndex: getCardIndexInGameBoardArray(fromButtonElement: button))
        }
    }
    
    func dealNewCards() {
        if game.deck.count >= 3 {
            let newCardsIdentifiers =  game.dealThreeNewCards()
            for selectedButtonIndex in 0..<self.selectedButtons.count {
                for buttonIndex in 0..<self.buttons.count {
                    if self.buttons[buttonIndex].tag == selectedButtons[selectedButtonIndex].tag {
                        connectButtonToCard(cardToConnect: game.cardsOnGameBoard[newCardsIdentifiers[selectedButtonIndex]], buttonToConnect: self.buttons[buttonIndex])
                    }
                }
            }
        }
    }
    
    func getAHint() {
        var found = false
        
        for firstCardIndex in 0..<game.cardsOnGameBoard.count where !found {
            for secondCardIndex in 0..<game.cardsOnGameBoard.count where !found {
                for thirdCardIndex in 0..<game.cardsOnGameBoard.count where !found {
                    if game.isASet(firstCard: game.cardsOnGameBoard[firstCardIndex], secondCard: game.cardsOnGameBoard[secondCardIndex], thirdCard: game.cardsOnGameBoard[thirdCardIndex]) {
                        let firstButtonIndex = getButtonIndexInButtonsArray(fromCardElement: game.cardsOnGameBoard[firstCardIndex])
                        let secondButtonIndex = getButtonIndexInButtonsArray(fromCardElement: game.cardsOnGameBoard[secondCardIndex])
                        let thirdButtonIndex = getButtonIndexInButtonsArray(fromCardElement: game.cardsOnGameBoard[thirdCardIndex])
                        changeToSetLayout(buttonToChange: self.buttons[firstButtonIndex])
                        changeToSetLayout(buttonToChange: self.buttons[secondButtonIndex])
                        changeToSetLayout(buttonToChange: self.buttons[thirdButtonIndex])
                        found = true
                    }
                }
            }
        }
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
    
    func changeCardsToMatched(firstCardIndex firstIndex: Int, secondCardIndex secondIndex: Int, thirdCardIndex thirdIndex: Int) {
        game.cardsOnGameBoard[firstIndex].isMatched = true
        game.cardsOnGameBoard[secondIndex].isMatched = true
        game.cardsOnGameBoard[thirdIndex].isMatched = true
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

