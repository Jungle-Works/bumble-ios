//
//  HeaderTableViewCell.swift
//  AFNetworking
//
//  Created by socomo on 14/12/17.
//

import UIKit

class HeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var messageTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.messageTitleLabel.font = BumbleConfig.shared.theme.actionableMessageHeaderTextFont
        self.itemDescriptionLabel.font = BumbleConfig.shared.theme.actionableMessageDescriptionFont
        self.messageTitleLabel.textColor = BumbleConfig.shared.theme.incomingMsgColor
        self.itemDescriptionLabel.textColor = BumbleConfig.shared.theme.incomingMsgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
