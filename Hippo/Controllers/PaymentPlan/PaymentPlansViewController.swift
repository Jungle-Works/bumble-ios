//
//  PaymentPlansViewController.swift
//  HippoAgent
//
//  Created by Vishal on 05/12/19.
//  Copyright © 2019 Socomo Technologies Private Limited. All rights reserved.
//

import UIKit

protocol PaymentPlansViewDelegate: class {
    func plansUpdated()
//    func startLoaderAnimation()
//    func stopLoaderAnimation()
}

protocol paymentCardPaymentOfCreatePaymentDelegate: AnyObject {
    func paymentCardPaymentOfCreatePayment(isSuccessful: Bool)
}

class PaymentPlansViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loaderView: So_UIImageView!
    @IBOutlet var view_Navigation : NavigationBar!
    
    var datasource = PaymentPlansDataSource()
    let store = PaymentPlanStore()
    var channelId: UInt?
    weak var sendNewPaymentDelegate: paymentCardPaymentOfCreatePaymentDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTheme()
        setTableView()
        self.startLoaderAnimation()
    }

    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    internal func setTheme() {
        store.delegate = self
//        setupCustomThemeOnNavigationBar(hideNavigationBar: false)

        view_Navigation.setupNavigationBar = {[weak self]() in
            DispatchQueue.main.async {
                self?.view_Navigation.image_back.tintColor = BumbleConfig.shared.theme.headerTextColor
                self?.view_Navigation.image_back.image = BumbleConfig.shared.theme.crossBarButtonImage_bumble
                self?.view_Navigation.title = BumbleStrings.savedPlans
                self?.view_Navigation.leftButton.addTarget(self, action: #selector(self?.cancelButtonClicked(_:)), for: .touchUpInside)
                self?.setaddIcon()
            }
        }
    
//        self.view.backgroundColor = HippoTheme.theme.systemBackgroundColor.secondary
        loaderView.tintColor = BumbleConfig.shared.theme.headerTextColor
    }
    
    internal func setTableView() {
        registerCell()
        tableView.tableFooterView = UIView()
        datasource.plans = store.plans
        datasource.deletePlanClicked = {[weak self](plan) in
            DispatchQueue.main.async {
                self?.showOptionAlert(title: "", message: BumbleStrings.deletePaymentPlan, successButtonName: BumbleStrings.yes, successComplete: { (_) in
                self?.DeletePaymentPlan(plan: plan, completion: { (success, error) in
                    if success{
                        self?.store.plans.removeAll(where: {$0.planId == plan.planId})
                        self?.datasource.plans = self?.store.plans ?? [PaymentPlan]()
                        self?.tableView.dataSource = self?.datasource
                        self?.tableView.reloadData()
                    }else{
                        self?.showAlert(title: "Error", message: error.debugDescription, actionComplete: nil)
                    }
                })
            }, failureButtonName: BumbleStrings.no.capitalized, failureComplete: nil)
            }
        }
        
        datasource.editPlanClicked = {[weak self](plan) in
            DispatchQueue.main.async {
               self?.pushCreatePayment(with: plan,isFromEditPlan: true, animated: true)
            }
        }
        
        datasource.sendPlanClicked = {[weak self](plan) in
            DispatchQueue.main.async {
                self?.sendPlan(plan)
            }
        }
        
        datasource.viewPlanClicked = {[weak self](plan) in
            DispatchQueue.main.async {
                let paymentStore = PaymentStore(plan: plan, channelId: self?.channelId, isEditing: false, isSending: self?.channelId != nil)
                let vc = CreatePaymentViewController.get(store: paymentStore, shouldSavePlan: false)
                vc.delegate = self
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        tableView.dataSource = datasource
        tableView.delegate = self
        
    }
    
    internal func setaddIcon() {
        view_Navigation.rightButton.tintColor = BumbleConfig.shared.theme.headerTextColor
//        view_Navigation.rightButton.setImage(BumbleConfig.shared.theme.AddFileIcon, for: .normal)
        view_Navigation.rightButton.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
    }
    @objc internal func addButtonClicked() {
        pushCreatePayment(with: nil,isForAddPlan: true, animated: true)
    }
    
    internal func registerCell() {
//        tableView.register(UINib(nibName: "PaymentPlanHomeCell", bundle: nil), forCellReuseIdentifier: "PaymentPlanHomeCell")
        let bundle = BumbleFlowManager.bundle
        tableView.register(UINib(nibName: "PaymentPlanHomeCell", bundle: bundle), forCellReuseIdentifier: "PaymentPlanHomeCell")
        
    }
    
    class func get(channelId: UInt?) -> PaymentPlansViewController {
        let vc = generateView()
        vc.channelId = channelId
        return vc
    }
    
    class func generateView() -> PaymentPlansViewController {
        let array = BumbleFlowManager.bundle?.loadNibNamed("PaymentPlansViewController", owner: self, options: nil)
        let view: PaymentPlansViewController? = array?.first as? PaymentPlansViewController
//        let storyboard = UIStoryboard(name: "FuguUnique", bundle: FuguFlowManager.bundle)
//        let view = storyboard.instantiateViewController(withIdentifier: "PaymentPlansViewController") as! PaymentPlansViewController
        
        guard let customView = view else {
            let vc = PaymentPlansViewController()
            return vc
        }
//        return view
        return customView
    }
    internal func pushCreatePayment(with plan: PaymentPlan?,isForAddPlan : Bool = false, isFromEditPlan : Bool = false, animated: Bool) {
        let paymentStore = PaymentStore(plan: plan, channelId: channelId, isEditing: (plan == nil || channelId != nil), isSending: channelId != nil, shouldSavePaymentPlan: isForAddPlan, canEditPlan: isFromEditPlan)
        let vc = CreatePaymentViewController.get(store: paymentStore, shouldSavePlan: isForAddPlan)
        vc.isEditScreen = isFromEditPlan
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: animated)
    }
    
    func startLoaderAnimation() {
        DispatchQueue.main.async {
            self.loaderView?.startRotationAnimation()
        }
    }
    
    func stopLoaderAnimation() {
        DispatchQueue.main.async {
            self.loaderView?.stopRotationAnimation()
        }
    }
    
}
extension PaymentPlansViewController: PaymentPlansViewDelegate {
    
    func plansUpdated() {
        let plans = store.plans
        
        self.stopLoaderAnimation()
        
        if plans.isEmpty, channelId != nil {
            pushCreatePayment(with: nil,isForAddPlan: true, animated: false)
        }
        datasource.plans = plans
        tableView.reloadData()
    }
    
}
extension PaymentPlansViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    
    }
    
    func sendPlan(_ plan : PaymentPlan){
        showOptionAlert(title: "", message: BumbleStrings.sendPaymentRequestPopup, successButtonName: BumbleStrings.yes, successComplete: { (_) in
            let paymentStore = PaymentStore(plan: plan, channelId: self.channelId, isEditing: false, isSending: self.channelId != nil)
            paymentStore.takeAction { (success, error) in
                guard success else {
                    showAlertWith(message: error?.localizedDescription ?? "", action: nil)
                    return
                }
                if paymentStore.isSending{
                    self.sendNewPaymentDelegate?.paymentCardPaymentOfCreatePayment(isSuccessful: true)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }, failureButtonName: BumbleStrings.no.capitalized, failureComplete: nil)
    }
    
}
extension PaymentPlansViewController: CreatePaymentDelegate {
    func sendMessage(for store: PaymentStore) {
        //code
        print("")
    }
    func backButtonPressed(shouldUpdate: Bool) {
        if channelId != nil, store.plans.isEmpty {
            self.dismiss(animated: true, completion: nil)
            return
        }
        if shouldUpdate {
            store.getPlans()
        }
    }
    func paymentCardPayment(isSuccessful: Bool){
        if isSuccessful == true{
            self.sendNewPaymentDelegate?.paymentCardPaymentOfCreatePayment(isSuccessful: true)
        }
    }
}
extension PaymentPlansViewController{
    
    //MARK:- Delete Plan
    
    
    func DeletePaymentPlan(plan : PaymentPlan, completion: @escaping ((_ success: Bool, _ error: Error?) -> ())) {
        
        guard let accessToken = BumbleConfig.shared.agentDetail?.fuguToken else {
            completion(false, nil)
            return
        }
        var param: [String: Any] = ["access_token": accessToken]
        param["plan_id"] = plan.planId
        param["operation_type"] = 2
        //        }
        HTTPClient.makeConcurrentConnectionWith(method: .POST, para: param, extendedUrl: AgentEndPoints.editPaymentPlans.rawValue) { (response, error, _, statusCode) in
            guard let responseDict = response as? [String: Any],
                let statusCode = responseDict["statusCode"] as? Int, statusCode == 200 else {
                    BumbleConfig.shared.log.debug("API_EditPaymentPlans ERROR.....\(error?.localizedDescription ?? "")", level: .error)
                    completion(false, error)
                    return
            }
            completion(true, nil)
        }
    }
    
}
