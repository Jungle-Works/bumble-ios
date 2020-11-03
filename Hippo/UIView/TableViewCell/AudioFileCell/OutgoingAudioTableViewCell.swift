//
//  OutgoingAudioTableViewCell.swift
//  OfficeChat
//
//  Created by Vishal on 21/03/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class OutgoingAudioTableViewCell: AudioTableViewCell {
   
   weak var delegate: RetryMessageUploadingDelegate?
   
   @IBOutlet weak var downloadButtonView: UIView!
   @IBOutlet weak var senderNameLabel: UILabel!
   @IBOutlet weak var messageStatusImageView: UIImageView!
   
   override func awakeFromNib() {
      super.awakeFromNib()
      
      self.activityIndicator.isHidden = true
      controlButton.isHidden = false
      setUIAccordingToTheme()
       messageStatusImageView.tintColor = BumbleConfig.shared.theme.themeTextcolor
   }
   
   func setData(message: HippoMessage) {
      
      self.message?.statusChanged = nil
      self.message = nil
      self.message = message
      self.cellIdentifier = message.fileUrl ?? message.localImagePath ?? ""
      
      setTime()
      
      senderNameLabel.text = message.senderFullName
      
      updateMessageStatus()
      
      self.message?.statusChanged = { [weak self] in
         DispatchQueue.main.async {
            self?.cellIdentifier = message.fileUrl ?? ""
            self?.updateMessageStatus()
            self?.updateUI()
         }
      }
      
      updateUI()
   }
   
   func updateMessageStatus() {
      
//      forwardButtonView.isHidden = message!.status == .none
      
      switch message!.status {
      case .none where message!.isFileUploading && !message!.wasMessageSendingFailed:
         messageStatusImageView.image = BumbleConfig.shared.theme.unsentMessageIcon_bumble
         activityIndicator.isHidden = false
         controlButton.isHidden = true
         activityIndicator.startAnimating()
      case .none where message!.wasMessageSendingFailed:
         messageStatusImageView.image = BumbleConfig.shared.theme.unsentMessageIcon_bumble
         activityIndicator.isHidden = true
         controlButton.isHidden = false
         activityIndicator.stopAnimating()
      case .none:
         activityIndicator.isHidden = true
         controlButton.isHidden = false
         messageStatusImageView.image = BumbleConfig.shared.theme.unsentMessageIcon_bumble
      case .read, .delivered:
         activityIndicator.isHidden = true
         controlButton.isHidden = false
         messageStatusImageView.image = BumbleConfig.shared.theme.readMessageTick_bumble
         
      case .sent:
         activityIndicator.isHidden = true
         controlButton.isHidden = false
         messageStatusImageView.image = BumbleConfig.shared.theme.unreadMessageTick_bumble
      }
   }
   
   @IBAction override func controlButtonAction(_ sender: Any) {
      
      if message != nil, message!.status == .none, message!.wasMessageSendingFailed {
         controlButton.setImage(BumbleConfig.shared.theme.uploadIcon_bumble, for: .normal)
         self.activityIndicator.isHidden = false
         controlButton.isHidden = true
         self.activityIndicator.startAnimating()
         self.delegate?.retryUploadFor(message: message!)
         return
      }
      
      super.controlButtonAction(sender)
   }
   
   override func updateButtonAccordingToStatus() {
      
      if message != nil, message!.status == .none {
         
         
         if message!.wasMessageSendingFailed {
            self.activityIndicator.stopAnimating()
            controlButton.setImage(BumbleConfig.shared.theme.uploadIcon_bumble, for: .normal)
         } else if message!.isFileUploading {
            
            DispatchQueue.main.async {
               self.activityIndicator.isHidden = false
               self.activityIndicator.startAnimating()
               self.controlButton.setImage(nil, for: .normal)
            }
            
         }
         return
      }
      
      super.updateButtonAccordingToStatus()
   }
   
    func setUIAccordingToTheme() {
        timeLabel.textColor = BumbleConfig.shared.theme.timeTextColor
        timeLabel.font = BumbleConfig.shared.theme.dateTimeFontSize
        
        bgView.layer.cornerRadius = BumbleConfig.shared.theme.chatBoxCornerRadius
        bgView.backgroundColor = BumbleConfig.shared.theme.outgoingChatBoxColor
        bgView.layer.borderWidth = BumbleConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = BumbleConfig.shared.theme.chatBoxBorderColor.cgColor
        
        senderNameLabel.isHidden = true
        
        fileName.font = BumbleConfig.shared.theme.inOutChatTextFont
        fileName.textColor = BumbleConfig.shared.theme.outgoingMsgColor
        
        self.backgroundColor = UIColor.clear
    }
   
}

