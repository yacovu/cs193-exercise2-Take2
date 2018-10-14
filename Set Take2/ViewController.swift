//
//  ViewController.swift
//  Set Take2
//
//  Created by Yacov Uziel on 05/10/2018.
//  Copyright © 2018 Yacov Uziel. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DynamicLayout {
    
    private(set) var colors = ["red", "green", "blue"]
    private(set) var shading = ["blank","semiFilled","fullyFilled"]
    private(set) var numberOfShapes = [1,2,3]
    lazy private(set) var shapes = ["diamond", "square", "circle"]
//    private var selectedButtons = [UIButton]()
    private var selectedPlayingCardViews = [PlayingCardView]()
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
    
    private var cardViews = [PlayingCardView]()
    
    @IBOutlet weak var boardView: UIView! {
        didSet {
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dealNewCardsAndAddToGrid))
            swipe.direction = .down
            boardView.addGestureRecognizer(swipe)
            
            let rotation = UIRotationGestureRecognizer(target: self, action: #selector(shuffleGameBoardCards))
            boardView.addGestureRecognizer(rotation)
        }
    }
    
    @IBOutlet weak var dealNewCardsButton: UIButton!
    
    @IBOutlet weak var playerScoreLabel: UILabel!
    
    @IBOutlet weak var cardsInDeckLabel: UILabel!
    
//    @IBOutlet var buttons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initBoard()
    }
    
    @IBAction func dealNewCardsClick(_ sender: UIButton) {
        dealNewCards()
//        changeButtonsLayoutToNotSelected()
//        addNewCardsToUI()
//        self.boardView.backgroundColor = UIColor.white
         updateGrid()
        updateLabelsInUI()
    }
    
    @IBAction func hintClick(_ sender: UIButton) {
        self.selectedPlayingCardViews.removeAll()
        showHintOnGameBoard()
        updateGrid()
    }
    
    @IBAction func newGameClick(_ sender: UIButton) {
        startNewGame()
    }
    
    @objc func dealNewCardsAndAddToGrid() {
        dealNewCards()
        updateGrid()
    }
    
    @objc func shuffleGameBoardCards() {
        game.shuffleGameBoard()
        updateGrid()
    }
    
    //TODO
    func reformUp() {
        
    }
    
    @objc func touchCard(sender cardView: UITapGestureRecognizer) {
        
        if self.needToDealNewCards { // in case a match was found in the previous turn
            dealNewCardsAndAddToGrid()
        }
        if self.selectedPlayingCardViews.count == 0 {
            changeCardsLayoutToNotSelected()
        }
        
        changeLayout(ofCard: (cardView.view! as? PlayingCardView)!)
        
        //TODO: check why doesn't work
//        if self.selectedPlayingCardViews.contains((cardView.view! as? PlayingCardView)!) { // deselect cards
//            removeCardFromSelectedCards(selecteCard: (cardView.view! as? PlayingCardView)!)
//        }
        if let viewIndex = containsCardView(selectedCardView: (cardView.view! as? PlayingCardView)!) {
            self.selectedPlayingCardViews.remove(at: viewIndex)
        }
        else { // select card
            self.selectedPlayingCardViews.append((cardView.view! as? PlayingCardView)!)
        }
        if self.selectedPlayingCardViews.count == 3 {
            handleThreeCardsSelected()
            updateLabelsInUI()
        }
        updateGrid()
    }
    
    func containsCardView(selectedCardView: PlayingCardView) -> Int? {
        for cardViewIndex in 0..<self.selectedPlayingCardViews.count {
            if self.selectedPlayingCardViews[cardViewIndex].tag == selectedCardView.tag {
                return cardViewIndex
            }
        }
        return nil
    }
    
    func changeCardsLayoutToNotSelected() {
        for cardView in self.cardViews {
            cardView.contentView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func removeCardFromSelectedCards(selecteCard card: PlayingCardView) {
        var found = false
        
        for cardIndex in 0..<self.selectedPlayingCardViews.count where !found {
            if self.selectedPlayingCardViews[cardIndex].tag == card.tag {
                self.selectedPlayingCardViews.remove(at: cardIndex)
                found = true
            }
        }
    }
    
    func changeLayout(ofCard card : PlayingCardView) {
        for cardView in self.cardViews {
            if cardView.tag == card.tag {
                let borderColor = cardView.contentView.layer.borderColor
                if borderColor == UIColor.white.cgColor || borderColor == UIColor.orange.cgColor || borderColor == UIColor.red.cgColor {
                    cardView.contentView.layer.borderWidth = 3.0
                    cardView.contentView.layer.borderColor = UIColor.blue.cgColor
                    cardView.contentView.layer.cornerRadius = 8.0
                }
                else if borderColor == UIColor.blue.cgColor {
                    cardView.contentView.layer.borderWidth = 0
                    cardView.contentView.layer.borderColor = UIColor.white.cgColor
                    cardView.contentView.layer.cornerRadius = 0
                }
            }
        }
    }
    
    func handleThreeCardsSelected() {
        checkIfSelectedCardsAreSet()
        self.selectedPlayingCardViews.removeAll()
        checkIfNeedToEndGame()
    }
    
    func startNewGame(){
        game = SetGame()
        resetCardViews()
        self.selectedPlayingCardViews.removeAll()
        needToDealNewCards = false
        self.dealNewCardsButton.isEnabled = true
        initBoard()
        updateLabelsInUI()
        
    }
    
    func resetCardViews() {
        for cardView in self.cardViews {
            cardView.contentView.layer.borderWidth = 0
            cardView.contentView.layer.borderColor = UIColor.white.cgColor
            cardView.contentView.layer.cornerRadius = 0
        }
    }
    
    func initBoard() {
        updateGrid()
    }
    
    func updateGrid() {
        let cardsOnGameBoard = game.getCardsOnGameBoard()
        let cardsGrid = Grid(layout: Grid.Layout.dimensions(rowCount: cardsOnGameBoard.count / 3, columnCount: 3), frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.boardView.frame.size))
        
        for subView in self.boardView.subviews {
            subView.removeFromSuperview()
        }
        
        for cardOnGameBoardIndex in 0..<cardsOnGameBoard.count {
            let x_coordinates = cardsGrid[cardOnGameBoardIndex]!.origin.x
            let y_coordinates = cardsGrid[cardOnGameBoardIndex]!.origin.y
            let cardWidth = cardsGrid[cardOnGameBoardIndex]!.size.width
            let cardHight = cardsGrid[cardOnGameBoardIndex]!.size.height
            let newCardView = PlayingCardView(frame: CGRect(x: x_coordinates, y: y_coordinates, width: cardWidth, height: cardHight))
            let cardOnCardsViewIndex = cardAlreadyExistsInCardsView(cardsOnGameBoard[cardOnGameBoardIndex])
            if cardOnCardsViewIndex >= 0 {
                newCardView.cardLabel.text = self.cardViews[cardOnCardsViewIndex].cardLabel.text
                newCardView.cardLabel.textColor = self.cardViews[cardOnCardsViewIndex].cardLabel.textColor
                newCardView.contentView.layer.borderColor = self.cardViews[cardOnCardsViewIndex].contentView.layer.borderColor
                newCardView.contentView.layer.borderWidth = self.cardViews[cardOnCardsViewIndex].contentView.layer.borderWidth
                newCardView.contentView.layer.cornerRadius = self.cardViews[cardOnCardsViewIndex].contentView.layer.cornerRadius
            }
            else {
                connectViewToCard(cardToConnect: cardsOnGameBoard[cardOnGameBoardIndex], viewToConnect: newCardView)
                //TOOD: remove views from cardviews after removing them
                self.cardViews.append(newCardView)
                newCardView.contentView.layer.borderColor = UIColor.white.cgColor
            }
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchCard(sender:)))
            newCardView.addGestureRecognizer(tapGesture)
            newCardView.tag = cardsOnGameBoard[cardOnGameBoardIndex].identifier
            self.boardView.addSubview(newCardView)
        }
    }
    
    func cardAlreadyExistsInCardsView(_ card: Card) -> Int {
        for cellIndex in 0..<self.cardViews.count {
            if self.cardViews[cellIndex].tag == card.identifier {
                return cellIndex
            }
        }
        return -1
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
    
    func connectViewToCard(cardToConnect card: Card, viewToConnect cardView: PlayingCardView) {
        let cardAttributedString = concatenateShapeAccordingToCardProperty(cardToGetShapeFrom: card)
        cardView.cardLabel.text = cardAttributedString.string
        cardView.cardLabel.textColor = cardAttributedString.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
    }
    
    func checkIfNeedToEndGame() {
        if game.needToEndGame() {
            gameOver()
        }
    }
    
    func removeCardsFromGameBoard() {
        for cardView in self.selectedPlayingCardViews {
            game.removeCardFromGameBoard(cardToBeRemoved: getCardInGameBoard(fromCardViewElement: cardView)!)
        }
    }
    
    func removeSelectedCardViewsFromUI() {
        for selectedCardView in self.selectedPlayingCardViews {
            for cardViewIndex in 0..<self.cardViews.count {
                if selectedCardView.tag == self.cardViews[cardViewIndex].tag {
                    self.cardViews[cardViewIndex].layer.backgroundColor = UIColor.clear.cgColor
                }
            }
        }
        
    }
    
//    func removeButtonFromSelectedButtons(selectedButton buttonToRemove: UIButton) {
//        var found = false
//        for buttonIndex in 0..<self.selectedButtons.count where !found{
//            if self.selectedButtons[buttonIndex] == buttonToRemove {
//                self.selectedButtons.remove(at: buttonIndex)
//                found = true
//            }
//        }
//    }
    
    func getButtonLayoutOnClick(ofButton button: UIButton) -> CGColor? {
        return button.layer.borderColor
    }
    
    func checkIfSelectedCardsAreSet() {
        if self.selectedPlayingCardViews.count == 3 {
            let firstCard = getCardInGameBoard(fromCardViewElement: selectedPlayingCardViews[0])!
            let secondCard = getCardInGameBoard(fromCardViewElement: selectedPlayingCardViews[1])!
            let thirdCard = getCardInGameBoard(fromCardViewElement: selectedPlayingCardViews[2])!
            if game.isASet(firstCard: firstCard, secondCard: secondCard, thirdCard: thirdCard) {
                changeCardViewsLayoutToLegalSet()
                game.changeCardsToMatched(firstCard: firstCard, secondCard: secondCard, thirdCard: thirdCard)
                self.needToDealNewCards = true
                dealNewCardsButton.isEnabled = true
                game.scorePlayer += 3
                if game.deck.count == 0 {
                    removeSelectedCardViewsFromUI()
                    removeCardsFromGameBoard()
                    dealNewCardsButton.isEnabled = false
                }
            }
            else {
                changeCardViewsLayoutToNotSet()
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
    
    @objc func dealNewCards() {
        if game.deck.count >= 3 {
            let newCards =  game.dealThreeNewCards()
            let matchedCards = getMatchedCards()
            
            if matchedCards.count == 3 {
                replaceSelectedCards(matchedCards: matchedCards, withNewCards: newCards)
            }
            else {
//                dealCardsToNewButtons(newCardsToDeal: newCards)
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
//        if freeButtonIndex < 24 {
//            for index in 0..<3 {
//                connectButtonToCard(cardToConnect: newCards[index], buttonToConnect: self.buttons[self.freeButtonIndex])
//                freeButtonIndex += 1
//            }
//            if game.cardsOnGameBoard.count == game.maxNumOfCards {
//                self.dealNewCardsButton.isEnabled = false
//            }
//        }
//        else {
//            self.dealNewCardsButton.isEnabled = false
//        }
    }
    
    func replaceSelectedCards(matchedCards matched: [Card], withNewCards newCards: [Card]) {
        for cardIndex in 0..<matched.count {
            for cardViewIndex in 0..<self.cardViews.count {
                if self.cardViews[cardViewIndex].tag == matched[cardIndex].identifier {
                    connectViewToCard(cardToConnect: newCards[cardIndex], viewToConnect: self.cardViews[cardViewIndex])
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
            let firstCardViewIndex = getCardViewIndexInCardsArray(fromCardElement: legalSetCards[0])
            let secondCardViewIndex = getCardViewIndexInCardsArray(fromCardElement: legalSetCards[1])
            let thirdCardViewIndex = getCardViewIndexInCardsArray(fromCardElement: legalSetCards[2])
            changeToSetLayout(cardViewToChange: self.cardViews[firstCardViewIndex])
            changeToSetLayout(cardViewToChange: self.cardViews[secondCardViewIndex])
            changeToSetLayout(cardViewToChange: self.cardViews[thirdCardViewIndex])
        }
    }
    
    func gameOver() {
        let alert = UIAlertController(title: "Game Over", message: "No Further Moves!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.default, handler: {action in self.game.exitGame()}))
        alert.addAction(UIAlertAction(title: "New Game", style: UIAlertActionStyle.default, handler: {action in self.startNewGame()}))
        self.present(alert, animated: true, completion: nil)
    }
        
    func changeToSetLayout(cardViewToChange cardView: PlayingCardView) {
        cardView.contentView.layer.borderWidth = 3.0
        cardView.contentView.layer.borderColor = UIColor.orange.cgColor
        cardView.contentView.layer.cornerRadius = 8.0
    }
    
    func changeCardViewsLayoutToLegalSet() {
        for selectedCard in self.selectedPlayingCardViews {
            for cardView in self.cardViews {
                if cardView.tag == selectedCard.tag {
                    cardView.contentView.layer.borderWidth = 3.0
                    cardView.contentView.layer.borderColor = UIColor.green.cgColor
                    cardView.contentView.layer.cornerRadius = 8.0
                }
            }
        }
//        updateGrid()
    }
    
    func changeCardViewsLayoutToNotSet() {
        for selectedCard in self.selectedPlayingCardViews {
            for cardView in self.cardViews {
                if cardView.tag == selectedCard.tag {
                    cardView.contentView.layer.borderWidth = 3.0
                    cardView.contentView.layer.borderColor = UIColor.red.cgColor
                    cardView.contentView.layer.cornerRadius = 8.0
                }
            }
        }
    }
    
    func changeButtonsLayoutToNotSelected() {
//        for button in buttons {
//            button.layer.borderWidth = 0
//            button.layer.borderColor = UIColor.white.cgColor
//            button.layer.cornerRadius = 0
//        }
    }
    
    func getCardInGameBoard(fromCardViewElement cardView: PlayingCardView) -> Card? {
        let cardsInGameBoard = game.getCardsOnGameBoard()
        
        for card in cardsInGameBoard {
            if card.identifier == cardView.tag {
                return card
            }
        }
        return nil
    }
    
    func getCardViewIndexInCardsArray(fromCardElement card: Card) -> Int {
        for cardViewIndex in 0..<self.cardViews.count {
            if self.cardViews[cardViewIndex].tag == card.identifier {
                return cardViewIndex
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

