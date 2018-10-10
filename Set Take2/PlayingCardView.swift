//
//  PlayingCardView.swift
//  Set Take2
//
//  Created by Yacov Uziel on 10/10/2018.
//  Copyright © 2018 Yacov Uziel. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        myInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        myInit()
    }
    
    private func myInit() {
        Bundle.main.loadNibNamed("PlayingCardLayout", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @IBOutlet weak var contentView: PlayingCardView!
    
    @IBOutlet weak var cardLabel: UILabel!
    
}
