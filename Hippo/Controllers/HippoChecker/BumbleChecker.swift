//
//  HippoChecker.swift
//  Hippo
//
//  Created by Vishal on 14/02/19.
//

import UIKit

class BumbleChecker {
    
    enum BumbleCheckerRequest {
        case presentChat
    }
    
    var config: BumbleConfig {
        return BumbleConfig.shared
    }
    
    var request: BumbleCheckerRequest?
    
    func presentChatsViewController() {
        AgentDetail.setAgentStoredData_bumble()
//        switch config.appUserType {
//        case .customer:
//            FuguFlowManager.shared.presentCustomerConversations()
//        case .agent:
//            FuguFlowManager.shared.presentAgentConversations()
//        }
    }
    func presentChatsViewController(on viewController: UIViewController) {
//           AgentDetail.setAgentStoredData()
//           switch config.appUserType {
//           case .customer:
//            FuguFlowManager.shared.presentCustomerConversations(on: viewController)
//           case .agent:
//               FuguFlowManager.shared.presentAgentConversations()
//           }
       }
    
    func presentPromotionalPushController()
    {
        BumbleFlowManager.shared.presentPromotionalpushController()
    }
    
    
    
    func shouldCollectDataFromUser() -> Bool {
        let form = HippoProperty.current.forms
        guard !form.isEmpty else {
            return false
        }
        return true
    }
    
    class func checkForAgentIntialization(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        if let fuguUserId = BumbleConfig.shared.agentDetail?.id, fuguUserId > 0 {
            completion(true, nil)
            return
        }
        AgentDetail.loginViaAuth { (result) in
            completion(result.isSuccessful, result.error)
        }
    }
}
extension BumbleChecker {
    
}
