//
//  ConversationState.swift
//  Branch
//
//  Created by Vishal on 25/09/18.
//

import UIKit

struct ConversationState {
    var labelString: String?
    var image: UIImage?
    var transitionBckgroundColor: UIColor?
    var channelId: Int?
    var isAssigned: Bool?
    
    init(labelString: String, image: UIImage?, transitionBckgroundColor: UIColor, channelId: Int? = nil, isAssigned: Bool = false) {
        self.labelString = labelString
        self.image = image
        self.transitionBckgroundColor = transitionBckgroundColor
        self.channelId = channelId
        self.isAssigned = isAssigned
    }
    
    static func getReassignedState() -> ConversationState {
        let obj = ConversationState(labelString: BumbleStrings.conversationAssigned, image: BumbleConfig.shared.theme.chatAssignIcon, transitionBckgroundColor: UIColor.pumpkinOrange.withAlphaComponent(0.95))
        return obj
    }
    static func getNewConversationState() -> ConversationState {
        let obj = ConversationState(labelString: BumbleStrings.newConversation, image: BumbleConfig.shared.theme.chatReOpenIcon, transitionBckgroundColor: UIColor.greenApple.withAlphaComponent(0.95))
        return obj
    }
    static func getClosedState() -> ConversationState {
        let obj = ConversationState(labelString: BumbleStrings.coversationClosed, image: BumbleConfig.shared.theme.chatCloseIcon, transitionBckgroundColor: UIColor.dirtyPurple.withAlphaComponent(0.95))
        return obj
    }
    static func getReopenState() -> ConversationState {
        let obj = ConversationState(labelString: BumbleStrings.conversationReopened, image: BumbleConfig.shared.theme.chatReOpenIcon, transitionBckgroundColor: UIColor.greenApple.withAlphaComponent(0.95))
        return obj
    }
}
