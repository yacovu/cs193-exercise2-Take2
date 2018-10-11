//
//  PlayingCardView.swift
//  Set Take2
//
//  Created by Yacov Uziel on 11/10/2018.
//  Copyright © 2018 Yacov Uziel. All rights reserved.
//

import UIKit

class PlayingCardView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var cardLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        myInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        myInit()
    }
    
    private func myInit() {
        Bundle.main.loadNibNamed("PlayingCardView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
