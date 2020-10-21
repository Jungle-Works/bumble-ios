//
//  BroadCastTitleCell.swift
//  SDKDemo1
//
//  Created by Vishal on 25/07/18.
//  Copyright © 2018 CL-macmini-88. All rights reserved.
//

import UIKit

class BroadCastTitleCell: UITableViewCell {

    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setInitalStrings()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setInitalStrings() {
        headingLabel.text = BumbleConfig.shared.strings.broadCastTitle + " " + BumbleConfig.shared.strings.displayNameForCustomers + "."
        headingLabel.font =  BumbleConfig.shared.theme.broadcastTitleFont
        headingLabel.textColor = BumbleConfig.shared.theme.broadcastTitleColor
        
        descLabel.text = BumbleConfig.shared.strings.broadCastTitleInfo
        descLabel.font = BumbleConfig.shared.theme.broadcastTitleInfoFont
        descLabel.textColor = BumbleConfig.shared.theme.broadcastTitleInfoColor
    }
    func setupCellFor(form: FormData) {
        descLabel.text = form.desc
        headingLabel.text = form.title
    }
}
