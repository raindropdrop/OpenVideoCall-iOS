//
//  MainViewController.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 16/8/17.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var roomNameTextField: UITextField!
    @IBOutlet weak var encryptionTextField: UITextField!
    @IBOutlet weak var encryptionButton: UIButton!
    
    private var videoProfile = AgoraRtcVideoProfile.defaultProfile()
    private var encryptionType = EncryptionType.xts128 {
        didSet {
            encryptionButton?.setTitle(encryptionType.description(), forState: .Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else {
            return
        }
        
        switch segueId {
        case "mainToSettings":
            let settingsVC = segue.destinationViewController as! SettingsViewController
            settingsVC.videoProfile = videoProfile
            settingsVC.delegate = self
        case "mainToRoom":
            let roomVC = segue.destinationViewController as! RoomViewController
            roomVC.roomName = (sender as! String)
            roomVC.encryptionSecret = encryptionTextField.text
            roomVC.encryptionType = encryptionType
            roomVC.videoProfile = videoProfile
            roomVC.delegate = self
        default:
            break
        }
    }
    
    @IBAction func doRoomNameTextFieldEditing(sender: UITextField) {
        if let text = sender.text where !text.isEmpty {
            let legalString = MediaCharacter.updateToLegalMediaString(text)
            sender.text = legalString
        }
    }
    
    @IBAction func doEncryptionTextFieldEditing(sender: UITextField) {
        if let text = sender.text where !text.isEmpty {
            let legalString = MediaCharacter.updateToLegalMediaString(text)
            sender.text = legalString
        }
    }
    
    @IBAction func doEncryptionTypePressed(sender: UIButton) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        for encryptionType in EncryptionType.allValue {
            let action = UIAlertAction(title: encryptionType.description(), style: .Default) { [weak self] _ in
                self?.encryptionType = encryptionType
            }
            sheet.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        sheet.addAction(cancel)
        sheet.popoverPresentationController?.sourceView = encryptionButton
        sheet.popoverPresentationController?.permittedArrowDirections = .Up
        presentViewController(sheet, animated: true, completion: nil)
    }
    
    @IBAction func doJoinPressed(sender: UIButton) {
        enterRoom(roomNameTextField.text)
    }
}

private extension MainViewController {
    func enterRoom(roomName: String?) {
        guard let roomName = roomName where !roomName.isEmpty else {
            return
        }
        performSegueWithIdentifier("mainToRoom", sender: roomName)
    }
}

extension MainViewController: SettingsVCDelegate {
    func settingsVC(settingsVC: SettingsViewController, didSelectProfile profile: AgoraRtcVideoProfile) {
        videoProfile = profile
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MainViewController: RoomVCDelegate {
    func roomVCNeedClose(roomVC: RoomViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case roomNameTextField:     enterRoom(textField.text)
        case encryptionTextField:   textField.resignFirstResponder()
        default: break
        }
        
        return true
    }
}
