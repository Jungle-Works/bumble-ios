//
//  ItemTableViewCell.swift
//  AFNetworking
//
//  Created by socomo on 14/12/17.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var itemDescriptionLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.itemDescriptionLabel.font = BumbleConfig.shared.theme.actionableMessageDescriptionFont
         self.itemPriceLabel.font = BumbleConfig.shared.theme.actionableMessagePriceBoldFont
        
        self.itemPriceLabel.textColor = BumbleConfig.shared.theme.incomingMsgColor
        self.itemDescriptionLabel.textColor = BumbleConfig.shared.theme.incomingMsgColor
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
