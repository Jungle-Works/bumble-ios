//
//  DocumentTableViewCell.swift
//  OfficeChat
//
//  Created by Asim on 21/03/18.
//  Copyright © 2018 Fugu-Click Labs Pvt. Ltd. All rights reserved.
//

import UIKit

class OutgoingDocumentTableViewCell: DocumentTableViewCell {
    
    @IBOutlet weak var tickImage: UIImageView!
    
    weak var delegate: RetryMessageUploadingDelegate?
    
    func setCellWith(message: HippoMessage) {
        
        self.message?.statusChanged = nil
        self.message = nil
        
        intalizeCell(with: message, isIncomingView: false)
        self.message = message
        
        message.statusChanged = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUIAccordingToStatus()
                self?.updateUIAccordingToFileDownloadStatus()
            }
        }
        
        setUIAccordingToTheme()
        updateUIAccordingToStatus()
        updateUI()
    }
    
    override func updateUIAccordingToFileDownloadStatus() {
        updateUIAccordingToStatus()
        if message!.status != .none && message?.wasMessageSendingFailed == false {
            super.updateUIAccordingToFileDownloadStatus()
        }
    }
    
    func updateUIAccordingToStatus() {
        retryButton.setTitleColor(.themeColor, for: .normal)
        retryButton.isHidden = true
        
        //      forwardButtonView.isHidden = message!.status == .none
        
        switch message!.status {
        case .none where message!.isFileUploading && !message!.wasMessageSendingFailed:
            tickImage.image = BumbleConfig.shared.theme.unsentMessageIcon
            activityIndicator.startAnimating()
        case .none where message!.wasMessageSendingFailed:
            tickImage.image = BumbleConfig.shared.theme.unsentMessageIcon
            activityIndicator.stopAnimating()
            retryButton.setTitle("", for: .normal)
            retryButton.setImage(BumbleConfig.shared.theme.uploadIcon, for: .normal)
            retryButton.isHidden = false
        case .none:
            tickImage.image = BumbleConfig.shared.theme.unsentMessageIcon
        case .read, .delivered:
            tickImage.image = BumbleConfig.shared.theme.readMessageTick
        case .sent:
            tickImage.image = BumbleConfig.shared.theme.unreadMessageTick
        }
    }
    
    func setUIAccordingToTheme() {
        timeLabel.textColor = BumbleConfig.shared.theme.dateTimeTextColor
        timeLabel.font = BumbleConfig.shared.theme.dateTimeFontSize
        
        bgView.layer.cornerRadius = BumbleConfig.shared.theme.chatBoxCornerRadius
        bgView.backgroundColor = BumbleConfig.shared.theme.outgoingChatBoxColor
        bgView.layer.borderWidth = BumbleConfig.shared.theme.chatBoxBorderWidth
        bgView.layer.borderColor = BumbleConfig.shared.theme.chatBoxBorderColor.cgColor
        
        fileSizeLabel.font = BumbleConfig.shared.theme.dateTimeFontSize
        fileSizeLabel.textColor = BumbleConfig.shared.theme.dateTimeTextColor
        
        docName.font = BumbleConfig.shared.theme.inOutChatTextFont
        docName.textColor = BumbleConfig.shared.theme.outgoingMsgColor
                
        nameLabel.font = BumbleConfig.shared.theme.senderNameFont
        nameLabel.textColor = BumbleConfig.shared.theme.senderNameColor
        
        retryButton.tintColor = BumbleConfig.shared.theme.outgoingMsgColor
        docImage.tintColor = BumbleConfig.shared.theme.outgoingMsgColor
        activityIndicator.tintColor = BumbleConfig.shared.theme.outgoingMsgColor
        activityIndicator.color = BumbleConfig.shared.theme.outgoingMsgColor
    }
    override func bgViewTaped() {
        guard !retryButton.isHidden else {
            return
        }
        switch message!.status {
        case .none:
            delegate?.retryUploadFor(message: message!)
        default:
            super.bgViewTaped()
        }
        setCellWith(message: message!)
    }
    
}


class DocumentTableViewCell: MessageTableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var docName: UILabel!
    @IBOutlet weak var docImage: UIImageView!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var actionDelegate: DocumentTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addNotificationObservers()
    }
    
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(fileDownloadCompleted(_:)), name: Notification.Name.fileDownloadCompleted, object: nil)
    }
    
    @objc func fileDownloadCompleted(_ notification: Notification) {
        guard let url = notification.userInfo?[DownloadManager.urlUserInfoKey] as? String else {
            return
        }
        
        if message?.fileUrl == url {
            updateUIAccordingToFileDownloadStatus()
        }
    }
    
    func updateUI() {
        updateDataInView()
        updateUIAccordingToFileDownloadStatus()
        setDocIconAccordingToFileType()
    }
    
    func addGestureToContainer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bgViewTaped))
        self.bgView.addGestureRecognizer(tapGesture)
    }
    
    @objc func bgViewTaped() {
        actionDelegate?.performActionAccordingToStatusOf(message: message!, inCell: self)
        updateUI()
    }
    func updateDataInView() {
        let fileExtension = getFileExtension()
        let size = message?.fileSize ?? ""
        var displaySize = size
        
        if !fileExtension.isEmpty {
            displaySize += displaySize.isEmpty ? "" : " - "
            displaySize += fileExtension
        }
        
        fileSizeLabel.text = displaySize
        docName.text = message?.fileName
        nameLabel.text = message?.senderFullName
        setTime()
    }
    override func intalizeCell(with message: HippoMessage, isIncomingView: Bool) {
        self.addGestureToContainer()
        super.intalizeCell(with: message, isIncomingView: isIncomingView)
    }
    
    func updateUIAccordingToFileDownloadStatus() {
        guard message!.fileUrl != nil else {
            return
        }
        
        let isFileBeingDownloaded = DownloadManager.shared.isFileBeingDownloadedWith(url: message!.fileUrl!)
        let isFileDownLoaded = DownloadManager.shared.isFileDownloadedWith(url: message!.fileUrl!)
        
        retryButton.setTitle("", for: .normal)
        retryButton.setImage(nil, for: .normal)
        retryButton.setTitleColor(.themeColor, for: .normal)
        //      retryButton.isEnabled = false
        
        retryButton.isHidden = false
        switch (isFileDownLoaded, isFileBeingDownloaded) {
        case (true, _):
            retryButton.setTitle("", for: .normal)
            activityIndicator.stopAnimating()
        case (false, true):
            retryButton.setTitle("", for: .normal)
            activityIndicator.startAnimating()
        case (false, false):
            retryButton.setImage(BumbleConfig.shared.theme.downloadIcon, for: .normal)
            activityIndicator.stopAnimating()
        }
    }
    
    func setDocIconAccordingToFileType() {
        let fileExtension: String = getFileExtension()
        
        
        switch fileExtension {
        case "pdf":
            docImage.image = BumbleConfig.shared.theme.pdfIcon
        case "excel", "xlsx", "xls":
            docImage.image = BumbleConfig.shared.theme.excelIcon
        case "doc", "docx":
            docImage.image = BumbleConfig.shared.theme.docIcon
        case "csv":
            docImage.image = BumbleConfig.shared.theme.csvIcon
        case "ppt":
            docImage.image = BumbleConfig.shared.theme.pptIcon
        case "txt":
            docImage.image = BumbleConfig.shared.theme.txtIcon
        default:
            docImage.image = BumbleConfig.shared.theme.defaultDocIcon
        }
    }
    
    @IBAction func retryButtonPressed(_ sender: UIButton) {
        self.bgViewTaped()
    }
    func getFileExtension() -> String {
        let fileExtension: String
        
        if let fileName = message?.fileName, let tempFileExtension = fileName.components(separatedBy: ".").last {
            fileExtension = tempFileExtension
        } else if let tempFileExtension = message?.localImagePath?.components(separatedBy: ".").last {
            fileExtension = tempFileExtension
        } else {
            fileExtension = ""
        }
        return fileExtension.uppercased()
    }
}
