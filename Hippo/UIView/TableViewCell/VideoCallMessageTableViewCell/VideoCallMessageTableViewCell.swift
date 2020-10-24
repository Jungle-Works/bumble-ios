//
//  VideoCallMessageTableViewCell.swift
//  Hippo
//
//  Created by Vishal on 11/09/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit

protocol VideoCallMessageTableViewCellDelegate: class {
    func callAgainButtonPressed(callType: CallType)
}

private var dateComponentFormatter: DateComponentsFormatter = {
   let formatter = DateComponentsFormatter()
   formatter.allowedUnits = [.hour, .minute, .second]
   formatter.unitsStyle = .short
   return formatter
}()

class VideoCallMessageTableViewCell: MessageTableViewCell {
   
   // MARK: - Properties
   @IBOutlet weak var dateTimeLabel: UILabel!
   @IBOutlet weak var messageLabel: UILabel!
   
    @IBOutlet weak var centerLineView: UIView!
    @IBOutlet weak var retryButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var callAgainButton: UIButton!
    @IBOutlet weak var messageBackgroundView: UIView!
    @IBOutlet weak var callDurationLabel: UILabel!
   
    @IBOutlet weak var phoneIcon: UIImageView!
    
   weak var delegate: VideoCallMessageTableViewCellDelegate?
   
   // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.font = BumbleConfig.shared.theme.incomingMsgFont
        dateTimeLabel.font = BumbleConfig.shared.theme.dateTimeFontSize
        dateTimeLabel.textColor = BumbleConfig.shared.theme.dateTimeTextColor
        callDurationLabel.font = BumbleConfig.shared.theme.dateTimeFontSize
        callDurationLabel.textColor = BumbleConfig.shared.theme.dateTimeTextColor
        callAgainButton.setTitleColor(BumbleConfig.shared.theme.themeColor, for: .normal)

        messageBackgroundView.layer.masksToBounds = true
        messageBackgroundView.layer.cornerRadius = 5
        
        messageBackgroundView.layer.borderWidth = BumbleConfig.shared.theme.chatBoxBorderWidth
        messageBackgroundView.layer.borderColor = BumbleConfig.shared.theme.chatBoxBorderColor.cgColor
    }
   
   // MARK: - IBAction
   @IBAction func callAgainButtonPressed(_ sender: UIButton) {
    delegate?.callAgainButtonPressed(callType: message?.callType ?? .video)
   }
   
   func setDuration() {
      callDurationLabel.text = message?.getFormattedVideoCallDuration()
   }
}

class IncomingVideoCallMessageTableViewCell: VideoCallMessageTableViewCell {
   
   override func awakeFromNib() {
      super.awakeFromNib()
    
      messageBackgroundView.layer.cornerRadius = 10
      messageBackgroundView.backgroundColor = BumbleConfig.shared.theme.callAgainColor
    
    if #available(iOS 11.0, *) {
        messageBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
    } else {
        // Fallback on earlier versions
    }
   }

   
    func setCellWith(message: HippoMessage, isCallingEnabled: Bool) {
        super.intalizeCell(with: message, isIncomingView: true)
        
        if message.isMissedCall {
            
            messageBackgroundView.backgroundColor = BumbleConfig.shared.theme.missedCallColor
            callAgainButton.setTitle(BumbleStrings.callback, for: .normal)
            phoneIcon.image = UIImage(named: "missed")
            phoneIcon.tintColor = UIColor.white
            
            
        } else {
           // messageLabel.textColor =  HippoConfig.shared.theme.incomingMsgColor
            
            messageBackgroundView.backgroundColor = BumbleConfig.shared.theme.callAgainColor
            
            callAgainButton.setTitle(BumbleStrings.callAgain, for: .normal)
            
            phoneIcon.image = UIImage(named: "incomming")
        }
        
        messageLabel.textColor = UIColor.white
        messageLabel.text = message.getVideoCallMessage(otherUserName: "🎥")
        callAgainButton.setTitleColor(UIColor.white, for: .normal)
        
        retryButtonHeight.constant = isCallingEnabled ? 35 : 0
        callAgainButton.isEnabled = isCallingEnabled
        callAgainButton.isHidden = !isCallingEnabled
        centerLineView.isHidden = !isCallingEnabled
        
        dateTimeLabel.text = getTimeString()
        setDuration()
    }
   
}

class OutgoingVideoCallMessageTableViewCell: VideoCallMessageTableViewCell {
   override func awakeFromNib() {
      super.awakeFromNib()
      
      messageBackgroundView.backgroundColor = BumbleConfig.shared.theme.outgoingChatBoxColor
    
    messageBackgroundView.layer.cornerRadius = 10
    
    if #available(iOS 11.0, *) {
        messageBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
    } else {
        // Fallback on earlier versions
    }
    
   }
   
   
    func setCellWith(message: HippoMessage, otherUserName: String, isCallingEnabled: Bool) {
        self.message = message
        
        if message.isMissedCall {
           
            callAgainButton.setTitle(BumbleStrings.callback, for: .normal)
            phoneIcon.image = UIImage(named: "missed")
            phoneIcon.tintColor = UIColor.black
            
            
        } else {
           // messageLabel.textColor = HippoConfig.shared.theme.outgoingMsgColor
            callAgainButton.setTitle(BumbleStrings.callAgain, for: .normal)
            
            phoneIcon.image = UIImage(named: "outgoing")
            phoneIcon.tintColor = UIColor.black
        }
        
       //  messageLabel.textColor = UIColor.white
        messageLabel.text = message.getVideoCallMessage(otherUserName: otherUserName)
        callAgainButton.setTitleColor(UIColor.black, for: .normal)
        centerLineView.backgroundColor = UIColor.black
        
        retryButtonHeight.constant = isCallingEnabled ? 35 : 0
        callAgainButton.isEnabled = isCallingEnabled
        callAgainButton.isHidden = !isCallingEnabled
        centerLineView.isHidden = !isCallingEnabled
        
        dateTimeLabel.text = getTimeString()
        setDuration()
        
    }
}

extension HippoMessage {
    func getVideoCallMessage(otherUserName: String) -> String {
        let callTypeString = getCallTypeString()
        
        if let activeVideoCallID = CallManager.shared.findActiveCallUUID(), messageUniqueID == activeVideoCallID {
            return "\(BumbleStrings.ongoing_call) \(callTypeString) \(BumbleStrings.call)"
        }
       // let tempOtherUser = otherUserName.isEmpty ? "Other user" : otherUserName
        
        if isMissedCall {
            if isSentByMe() {
                return "\(BumbleStrings.missed) \(callTypeString) \(BumbleStrings.call)"//"\(tempOtherUser) missed a \(callTypeString) call with you"
            } else {
                return "\(BumbleStrings.missed) \(callTypeString) \(BumbleStrings.call)"//"You missed a \(callTypeString) call with \(senderFullName)"
            }
        } else {
            return "\(BumbleStrings.the) \(callTypeString) \(BumbleStrings.callEnded)."
        }
    }
    
    fileprivate func getFormattedVideoCallDuration() -> String? {
        guard let duration = callDurationInSeconds else {
            return nil
        }
        
        return (dateComponentFormatter.string(from: duration) ?? "") + " \(BumbleStrings.at)"
    }
    func getCallTypeString() -> String {
        switch callType {
        case .video:
            return BumbleStrings.video
        case .audio:
            return BumbleStrings.voice
        }
    }
    
}


