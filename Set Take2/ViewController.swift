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
        initBord()
        
    }
    
    @IBAction func dealNewCardsClick(_ sender: UIButton) {
    }
    
    @IBAction func hintClick(_ sender: UIButton) {
    }
    
    @IBAction func newGameClick(_ sender: UIButton) {
    }
    
    @IBOutlet weak var playerScoreLabel: UILabel!
    
    @IBOutlet weak var cardsInDeckLabel: UILabel!
    
    @IBOutlet var buttons: [UIButton]!
    
    private(set) var colors = ["red", "green", "blue"]
    private(set) var shading = ["blank","semiFilled","fullyFilled"]
    private(set) var numberOfShapes = [1,2,3]
    lazy private(set) var shapes = ["diamond", "square", "circle"]
    
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
    
    func initBord() {
        disableAllButtons()
        for buttonIndex in 0..<game.cardsOnGameBoard.count {
            connectButtonToCard(cardToConnect: game.cardsOnGameBoard[buttonIndex], buttonToConnect: self.buttons[buttonIndex])
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
}

