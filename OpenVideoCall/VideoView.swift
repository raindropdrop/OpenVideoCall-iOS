//
//  VideoView.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 2/14/16.
//  Copyright © 2016 Agora. All rights reserved.
//

import UIKit

class VideoView: UIView {
    
    private(set) var videoView: UIView!
    private var screenShareImageView: UIView?
    
    private var infoView: UIView!
    private var infoLabel: UILabel!
    
    var isVideoMuted = false {
        didSet {
            videoView?.hidden = isVideoMuted || isScreenSharing
        }
    }
    private var isScreenSharing = false {
        didSet {
            removeScreenShareImageView()
            
            if isScreenSharing {
                addScreenShareImageView()
            }
            
            videoView.hidden = isVideoMuted || isScreenSharing
        }
    }
    
    override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.whiteColor()
        
        addVideoView()
        addInfoView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoView {
    func switchToScreenShare(isScreenShare: Bool) {
        isScreenSharing = isScreenShare
    }
}

extension VideoView {
    func updateInfo(info: MediaInfo) {
        infoLabel?.text = info.description()
    }
}

private extension VideoView {
    func addVideoView() {
        videoView = UIView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.backgroundColor = UIColor.clearColor()
        addSubview(videoView)
        
        let videoViewH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[video]|", options: [], metrics: nil, views: ["video": videoView])
        let videoViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[video]|", options: [], metrics: nil, views: ["video": videoView])
        NSLayoutConstraint.activateConstraints(videoViewH + videoViewV)
    }
    
    func addInfoView() {
        infoView = UIView()
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoView.hidden = true
        infoView.backgroundColor = UIColor.clearColor()
        
        addSubview(infoView)
        let infoViewH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[info]|", options: [], metrics: nil, views: ["info": infoView])
        let infoViewV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[info(==135)]", options: [], metrics: nil, views: ["info": infoView])
        NSLayoutConstraint.activateConstraints(infoViewH + infoViewV)
        
        func createInfoLabel() -> UILabel {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            
            label.text = " "
            label.shadowOffset = CGSize(width: 0, height: 1)
            label.shadowColor = UIColor.blackColor()
            label.numberOfLines = 0
            
            label.font = UIFont.systemFontOfSize(12)
            label.textColor = UIColor.whiteColor()
            
            return label
        }
        
        infoLabel = createInfoLabel()
        infoView.addSubview(infoLabel)
        
        let top: CGFloat = 20
        let left: CGFloat = 10
        
        let labelV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(\(top))-[info]", options: [], metrics: nil, views: ["info": infoLabel])
        let labelH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-(\(left))-[info]", options: [], metrics: nil, views: ["info": infoLabel])
        NSLayoutConstraint.activateConstraints(labelV)
        NSLayoutConstraint.activateConstraints(labelH)
    }
    
    //MARK: - screen share
    private func addScreenShareImageView() {
        let imageView = UIImageView(frame: CGRectMake(0, 0, 144, 144))
        imageView.image = UIImage(named: "icon_sharing_desktop")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        let avatarH = NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0)
        let avatarV = NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let avatarRatio = NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: imageView, attribute: .Height, multiplier: 1, constant: 0)
        let avatarLeft = NSLayoutConstraint(item: imageView, attribute: .Left, relatedBy: .GreaterThanOrEqual, toItem: self, attribute: .Left, multiplier: 1, constant: 10)
        let avatarTop = NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: self, attribute: .Top, multiplier: 1, constant: 10)
        NSLayoutConstraint.activateConstraints([avatarH, avatarV, avatarRatio, avatarLeft, avatarTop])
        
        screenShareImageView = imageView
    }
    
    private func removeScreenShareImageView() {
        if let imageView = screenShareImageView {
            imageView.removeFromSuperview()
            self.screenShareImageView = nil
        }
    }
}
