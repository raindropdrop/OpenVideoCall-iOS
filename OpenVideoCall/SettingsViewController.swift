//
//  SettingsViewController.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 6/25/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import UIKit

protocol SettingsVCDelegate: NSObjectProtocol {
    func settingsVC(settingsVC: SettingsViewController, didSelectProfile profile: AgoraRtcVideoProfile)
}

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var profileTableView: UITableView!

    var videoProfile: AgoraRtcVideoProfile! {
        didSet {
            profileTableView?.reloadData()
        }
    }
    weak var delegate: SettingsVCDelegate?
    
    private let profiles: [AgoraRtcVideoProfile] = AgoraRtcVideoProfile.list()
    
    @IBAction func doConfirmPressed(sender: UIButton) {
        delegate?.settingsVC(self, didSelectProfile: videoProfile)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell", forIndexPath: indexPath) as! ProfileCell
        let selectedProfile = profiles[indexPath.row]
        cell.updateWithProfile(selectedProfile, isSelected: (selectedProfile == videoProfile))
        
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedProfile = profiles[indexPath.row]
        videoProfile = selectedProfile
    }
}

private extension AgoraRtcVideoProfile {
    static func list() -> [AgoraRtcVideoProfile] {
        return AgoraRtcVideoProfile.validProfileList()
    }
}
