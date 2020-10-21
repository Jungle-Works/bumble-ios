//
//  DocumentRecivedTableViewCell.swift
//  OfficeChat
//
//  Created by Asim on 22/03/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit

class IncomingDocumentTableViewCell: DocumentTableViewCell {
    
    override func awakeFromNib() {
      super.awakeFromNib()
      
//      addTapGestureInNameLabel()
   }
    
    func setCellWith(message: HippoMessage) {
        
        setUIAccordingToTheme()
        intalizeCell(with: message, isIncomingView: true)
        self.message = message
        
        
        updateUI()
    }
    
    func setUIAccordingToTheme() {
        timeLabel.text = ""
        timeLabel.font = BumbleConfig.shared.theme.dateTimeFontSize
        timeLabel.textAlignment = .left
        timeLabel.textColor = BumbleConfig.shared.theme.dateTimeTextColor
        
        bgView.layer.cornerRadius = BumbleConfig.shared.theme.chatBoxCornerRadius
        bgView.backgroundColor = BumbleConfig.shared.theme.recievingBubbleColor
        bgView.layer.borderWidth = BumbleConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = BumbleConfig.shared.theme.chatBoxBorderColor.cgColor
        
        nameLabel.font = BumbleConfig.shared.theme.senderNameFont
        nameLabel.textColor = BumbleConfig.shared.theme.senderNameColor
        
        fileSizeLabel.font = BumbleConfig.shared.theme.dateTimeFontSize
        fileSizeLabel.textColor = BumbleConfig.shared.theme.dateTimeTextColor
        
        docName.font = BumbleConfig.shared.theme.incomingMsgFont
        docName.textColor = BumbleConfig.shared.theme.incomingMsgColor
        
        
        retryButton.tintColor = BumbleConfig.shared.theme.incomingMsgColor
        docImage.tintColor = BumbleConfig.shared.theme.incomingMsgColor
        activityIndicator.tintColor = BumbleConfig.shared.theme.incomingMsgColor
        activityIndicator.color = BumbleConfig.shared.theme.incomingMsgColor
    }
   
   func addTapGestureInNameLabel() {
      let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
      nameLabel.addGestureRecognizer(tapGesture)
   }
   
   @objc func nameTapped() {
//      if let msg = message {
//         interactionDelegate?.nameOnMessageTapped(msg)
//      }
   }
    
    
}
