//
//  ButtonCollectionCell.swift
//  AFNetworking
//
//  Created by socomo on 14/12/17.
//

import UIKit

class ButtonCollectionCell: UICollectionViewCell {

    @IBOutlet weak var leadingView: UIView!
    @IBOutlet weak var trailingView: UIView!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var xCenterConstraintOfButton: NSLayoutConstraint!
    @IBOutlet var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageButton.titleLabel?.font =  BumbleConfig.shared.theme.actionableMessageButtonFont
        self.messageButton.setTitleColor(BumbleConfig.shared.theme.actionableMessageButtonColor, for: .normal)
        self.messageButton.setTitleColor(BumbleConfig.shared.theme.actionableMessageButtonHighlightedColor, for: .highlighted)
        self.messageButton.setTitleColor(BumbleConfig.shared.theme.actionableMessageButtonHighlightedColor, for: .selected)
        // Initialization code
    }
    
    

}
