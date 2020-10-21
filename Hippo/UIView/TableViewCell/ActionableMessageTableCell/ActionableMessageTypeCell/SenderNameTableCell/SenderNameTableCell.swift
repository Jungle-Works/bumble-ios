//
//  SenderNameTableCell.swift
//  SDKDemo1
//
//  Created by socomo on 29/12/17.
//  Copyright © 2017 CL-macmini-88. All rights reserved.
//

import UIKit

class SenderNameTableCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var senderNameLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let senderNameFont = BumbleConfig.shared.theme.senderNameFont
        senderNameLabel.font = senderNameFont
        senderNameLabel.textColor = BumbleConfig.shared.theme.senderNameColor
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
