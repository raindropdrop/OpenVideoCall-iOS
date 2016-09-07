//
//  RoomViewController.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 16/8/22.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit

protocol RoomVCDelegate: class {
    func roomVCNeedClose(roomVC: RoomViewController)
}

class RoomViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var flowViews: [UIView]!
    @IBOutlet weak var roomNameLabel: UILabel!
    
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var messageTableContainerView: UIView!
    
    @IBOutlet weak var messageButton: UIButton!
    
    @IBOutlet weak var muteVideoButton: UIButton!
    @IBOutlet weak var muteAudioButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var messageInputerView: UIView!
    @IBOutlet weak var messageInputerBottom: NSLayoutConstraint!
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet var backgroundTap: UITapGestureRecognizer!
    @IBOutlet var backgroundDoubleTap: UITapGestureRecognizer!
    
    //MARK: public var
    var roomName: String!
    var encryptionSecret: String?
    var encryptionType: EncryptionType!
    var videoProfile: AgoraRtcVideoProfile!
    weak var delegate: RoomVCDelegate?
    
    //MARK: hide & show
    private var shouldHideFlowViews = false {
        didSet {
            if let flowViews = flowViews {
                for view in flowViews {
                    view.hidden = shouldHideFlowViews
                }
            }
        }
    }
    
    //MARK: engine & session
    var agoraKit: AgoraRtcEngineKit!
    private var videoSessions = [VideoSession]() {
        didSet {
            updateInterfaceWithSessions(self.videoSessions, targetSize: containerView.frame.size, animation: true)
        }
    }
    private var doubleClickFullSession: VideoSession? {
        didSet {
            if videoSessions.count >= 3 && doubleClickFullSession != oldValue {
                updateInterfaceWithSessions(videoSessions, targetSize: containerView.frame.size, animation: true)
            }
        }
    }
    private let videoViewLayout = VideoViewLayout()
    private var dataChannelId: Int = -1
    
    //MARK: alert
    private weak var currentAlert: UIAlertController?
    
    //MARK: mute
    private var audioMuted = false {
        didSet {
            muteAudioButton?.setImage(UIImage(named: audioMuted ? "btn_mute_blue" : "btn_mute"), forState: .Normal)
            agoraKit.muteLocalAudioStream(audioMuted)
        }
    }
    private var videoMuted = false {
        didSet {
            muteVideoButton?.setImage(UIImage(named: videoMuted ? "btn_video" : "btn_voice"), forState: .Normal)
            cameraButton?.hidden = videoMuted
            speakerButton?.hidden = !videoMuted
            
            agoraKit.muteLocalVideoStream(videoMuted)
            setVideoMuted(videoMuted, forUid: 0)
            
            updateSelfViewVisiable()
        }
    }
    
    //MARK: speaker
    private var speakerEnabled = true {
        didSet {
            speakerButton?.setImage(UIImage(named: speakerEnabled ? "btn_speaker_blue" : "btn_speaker"), forState: .Normal)
            speakerButton?.setImage(UIImage(named: speakerEnabled ? "btn_speaker" : "btn_speaker_blue"), forState: .Highlighted)
            
            agoraKit.setEnableSpeakerphone(speakerEnabled)
        }
    }
    
    //MARK: filter
    private var isFiltering = false {
        didSet {
            guard let agoraKit = agoraKit else {
                return
            }
            
            if isFiltering {
                AGVideoPreProcessing.registerVideoPreprocessing(agoraKit)
                filterButton?.setImage(UIImage(named: "btn_filter_blue"), forState: .Normal)
            } else {
                AGVideoPreProcessing.deregisterVideoPreprocessing(agoraKit)
                filterButton?.setImage(UIImage(named: "btn_filter"), forState: .Normal)
            }
        }
    }
    
    //MARK: text message
    private var chatMessageVC: ChatMessageViewController?
    private var isInputing = false {
        didSet {
            if isInputing {
                messageTextField?.becomeFirstResponder()
            } else {
                messageTextField?.resignFirstResponder()
            }
            messageInputerView?.hidden = !isInputing
            messageButton?.setImage(UIImage(named: isInputing ? "btn_message_blue" : "btn_message"), forState: .Normal)
        }
    }
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomNameLabel.text = "\(roomName)"
        backgroundTap.requireGestureRecognizerToFail(backgroundDoubleTap)
        addKeyboardObserver()
        
        loadAgoraKit()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier else {
            return
        }
        
        switch segueId {
        case "VideoVCEmbedChatMessageVC":
            chatMessageVC = segue.destinationViewController as? ChatMessageViewController
        default:
            break
        }
    }
    
    //MARK: - user action
    @IBAction func doMessagePressed(sender: UIButton) {
        isInputing = !isInputing
    }
    
    @IBAction func doCloseMessagePressed(sender: UIButton) {
        isInputing = false
    }
    
    @IBAction func doMuteVideoPressed(sender: UIButton) {
        videoMuted = !videoMuted
    }
    
    @IBAction func doMuteAudioPressed(sender: UIButton) {
        audioMuted = !audioMuted
    }
    
    @IBAction func doCameraPressed(sender: UIButton) {
        agoraKit.switchCamera()
    }
    
    @IBAction func doSpeakerPressed(sender: UIButton) {
        speakerEnabled = !speakerEnabled
    }
    
    @IBAction func doFilterPressed(sender: UIButton) {
        isFiltering = !isFiltering
    }
    
    @IBAction func doClosePressed(sender: UIButton) {
        leaveChannel()
    }
    
    @IBAction func doBackTapped(sender: UITapGestureRecognizer) {
        if !isInputing {
            shouldHideFlowViews = !shouldHideFlowViews
        }
    }
    
    @IBAction func doBackDoubleTapped(sender: UITapGestureRecognizer) {
        if doubleClickFullSession == nil {
            //将双击到的session全屏
            if let tappedIndex = videoViewLayout.reponseViewIndexOfLocation(sender.locationInView(containerView)) {
                doubleClickFullSession = videoSessions[tappedIndex]
            }
        } else {
            doubleClickFullSession = nil
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .All
    }
}

//MARK: - textFiled
extension RoomViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let text = textField.text where !text.isEmpty {
            sendText(text)
            textField.text = nil
        }
        return true
    }
}

//MARK: - private
private extension RoomViewController {
    func addKeyboardObserver() {
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: nil) { [weak self] notify in
            guard let strongSelf = self, let userInfo = notify.userInfo,
                let keyBoardBoundsValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
                let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
                    return
            }
            
            let keyBoardBounds = keyBoardBoundsValue.CGRectValue()
            let duration = durationValue.doubleValue
            let deltaY = keyBoardBounds.size.height
            
            if duration > 0 {
                var optionsInt: UInt = 0
                if let optionsValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                    optionsInt = optionsValue.unsignedIntegerValue
                }
                let options = UIViewAnimationOptions(rawValue: optionsInt)
                
                UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
                    strongSelf.messageInputerBottom.constant = deltaY
                    strongSelf.view?.layoutIfNeeded()
                    }, completion: nil)
                
            } else {
                strongSelf.messageInputerBottom.constant = deltaY
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: nil) { [weak self] notify in
            guard let strongSelf = self else {
                return
            }
            
            let duration: Double
            if let userInfo = notify.userInfo, let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber {
                duration = durationValue.doubleValue
            } else {
                duration = 0
            }
            
            if duration > 0 {
                var optionsInt: UInt = 0
                if let userInfo = notify.userInfo, let optionsValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber {
                    optionsInt = optionsValue.unsignedIntegerValue
                }
                let options = UIViewAnimationOptions(rawValue: optionsInt)
                
                UIView.animateWithDuration(duration, delay: 0, options: options, animations: {
                    strongSelf.messageInputerBottom.constant = 0
                    strongSelf.view?.layoutIfNeeded()
                    }, completion: nil)
                
            } else {
                strongSelf.messageInputerBottom.constant = 0
            }
        }
    }
    
    func updateInterfaceWithSessions(sessions: [VideoSession], targetSize: CGSize, animation: Bool) {
        if animation {
            UIView.animateWithDuration(0.3, delay: 0, options: .BeginFromCurrentState, animations: {[weak self] () -> Void in
                self?.updateInterfaceWithSessions(sessions, targetSize: targetSize)
                self?.view.layoutIfNeeded()
                }, completion: nil)
        } else {
            updateInterfaceWithSessions(sessions, targetSize: targetSize)
        }
    }
    
    func updateInterfaceWithSessions(sessions: [VideoSession], targetSize: CGSize) {
        guard !sessions.isEmpty else {
            return
        }
        
        let selfSession = sessions.first!
        videoViewLayout.selfView = selfSession.hostingView
        videoViewLayout.selfSize = selfSession.size
        videoViewLayout.targetSize = targetSize
        var peerVideoViews = [VideoView]()
        for i in 1..<sessions.count {
            peerVideoViews.append(sessions[i].hostingView)
        }
        videoViewLayout.videoViews = peerVideoViews
        videoViewLayout.fullView = doubleClickFullSession?.hostingView
        videoViewLayout.containerView = containerView
        
        videoViewLayout.layoutVideoViews()
        
        updateSelfViewVisiable()
        
        //只有三人及以上时才能切换布局形式
        if sessions.count >= 3 {
            backgroundDoubleTap.enabled = true
        } else {
            backgroundDoubleTap.enabled = false
            doubleClickFullSession = nil
        }
    }
    
    func setIdleTimerActive(active: Bool) {
        UIApplication.sharedApplication().idleTimerDisabled = !active
    }
    
    func fetchSessionOfUid(uid: UInt) -> VideoSession? {
        for session in videoSessions {
            if session.uid == uid {
                return session
            }
        }
        
        return nil
    }
    
    func videoSessionOfUid(uid: UInt) -> VideoSession {
        if let fetchedSession = fetchSessionOfUid(uid) {
            return fetchedSession
        } else {
            let newSession = VideoSession(uid: uid)
            videoSessions.append(newSession)
            return newSession
        }
    }
    
    func setVideoMuted(muted: Bool, forUid uid: UInt) {
        fetchSessionOfUid(uid)?.isVideoMuted = muted
    }
    
    func updateSelfViewVisiable() {
        guard let selfView = videoSessions.first?.hostingView else {
            return
        }
        
        if videoSessions.count == 2 {
            selfView.hidden = videoMuted
        } else {
            selfView.hidden = false
        }
    }
    
    func alertEngineString(string: String) {
        alertString("Engine: \(string)")
    }
    
    func alertAppString(string: String) {
        alertString("App: \(string)")
    }
    
    func alertString(string: String) {
        guard !string.isEmpty else {
            return
        }
        chatMessageVC?.appendAlert(string)
    }
}

//MARK: - engine
private extension RoomViewController {
    func loadAgoraKit() {
        agoraKit = AgoraRtcEngineKit.sharedEngineWithAppId(KeyCenter.AppId, delegate: self)
        
        agoraKit.enableVideo()
        agoraKit.setChannelProfile(.ChannelProfile_Free)
        agoraKit.setVideoProfile(videoProfile)
        
        addLocalSession()
        agoraKit.startPreview()
        if let encryptionType = encryptionType, let encryptionSecret = encryptionSecret where !encryptionSecret.isEmpty {
            agoraKit.setEncryptionMode(encryptionType.modeString())
            agoraKit.setEncryptionSecret(encryptionSecret)
        }
        
        let code = agoraKit.joinChannelByKey(nil, channelName: roomName, info: nil, uid: 0, joinSuccess: nil)
        
        if code == 0 {
            setIdleTimerActive(false)
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.alertEngineString("Join channel failed: \(code)")
            })
        }
        
        agoraKit.createDataStream(&dataChannelId, reliable: true, ordered: true)
    }
    
    private func addLocalSession() {
        let localSession = VideoSession.localSession()
        videoSessions.append(localSession)
        agoraKit.setupLocalVideo(localSession.canvas)
        
        if let mediaInfo = MediaInfo(videoProfile: videoProfile) {
            localSession.mediaInfo = mediaInfo
        }
    }
    
    func leaveChannel() {
        agoraKit.setupLocalVideo(nil)
        agoraKit.leaveChannel(nil)
        agoraKit.stopPreview()
        isFiltering = false
        
        for session in videoSessions {
            session.hostingView.removeFromSuperview()
        }
        videoSessions.removeAll()
        
        setIdleTimerActive(true)
        delegate?.roomVCNeedClose(self)
    }
    
    func sendText(text: String) {
        if dataChannelId > 0, let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            agoraKit.sendStreamMessage(dataChannelId, data: data)
            chatMessageVC?.appendChat(text, fromUid: 0)
        }
    }
}

//MARK: - engine delegate
extension RoomViewController: AgoraRtcEngineDelegate {
    func rtcEngineConnectionDidInterrupted(engine: AgoraRtcEngineKit!) {
        alertEngineString("Connection Interrupted")
    }
    
    func rtcEngineConnectionDidLost(engine: AgoraRtcEngineKit!) {
        alertEngineString("Connection Lost")
    }
    
    func rtcEngine(engine: AgoraRtcEngineKit!, didOccurError errorCode: AgoraRtcErrorCode) {
        //
    }
    
    func rtcEngine(engine: AgoraRtcEngineKit!, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
        let userSession = videoSessionOfUid(uid)
        let sie = size.fixedSizeWithReference(containerView.bounds.size)
        userSession.size = sie
        userSession.updateMediaInfo(resolution: size)
        agoraKit.setupRemoteVideo(userSession.canvas)
    }
    
    //first local video frame
    func rtcEngine(engine: AgoraRtcEngineKit!, firstLocalVideoFrameWithSize size: CGSize, elapsed: Int) {
        if let selfSession = videoSessions.first {
            let fixedSize = size.fixedSizeWithReference(containerView.bounds.size)
            selfSession.size = fixedSize
            updateInterfaceWithSessions(videoSessions, targetSize: containerView.frame.size, animation: false)
        }
    }
    
    //user offline
    func rtcEngine(engine: AgoraRtcEngineKit!, didOfflineOfUid uid: UInt, reason: AgoraRtcUserOfflineReason) {
        var indexToDelete: Int?
        for (index, session) in videoSessions.enumerate() {
            if session.uid == uid {
                indexToDelete = index
            }
        }
        
        if let indexToDelete = indexToDelete {
            let deletedSession = videoSessions.removeAtIndex(indexToDelete)
            deletedSession.hostingView.removeFromSuperview()
            if let doubleClickFullSession = doubleClickFullSession where doubleClickFullSession == deletedSession {
                self.doubleClickFullSession = nil
            }
        }
    }
    
    //video muted
    func rtcEngine(engine: AgoraRtcEngineKit!, didVideoMuted muted: Bool, byUid uid: UInt) {
        setVideoMuted(muted, forUid: uid)
    }
    
    //remote stat
    func rtcEngine(engine: AgoraRtcEngineKit!, remoteVideoStats stats: AgoraRtcRemoteVideoStats!) {
        if let stats = stats, let session = fetchSessionOfUid(stats.uid) {
            session.updateMediaInfo(resolution: CGSizeMake(CGFloat(stats.width), CGFloat(stats.height)), bitRate: Int(stats.receivedBitrate), fps: Int(stats.receivedFrameRate))
        }
    }
    
    //data channel
    func rtcEngine(engine: AgoraRtcEngineKit!, receiveStreamMessageFromUid uid: UInt, streamId: Int, data: NSData!) {
        guard let data = data, let string = String(data: data, encoding: NSUTF8StringEncoding) where !string.isEmpty else {
            return
        }
        chatMessageVC?.appendChat(string, fromUid: Int64(uid))
    }
    
    func rtcEngine(engine: AgoraRtcEngineKit!, didOccurStreamMessageErrorFromUid uid: UInt, streamId: Int, error: Int, missed: Int, cached: Int) {
        print("Data channel error: \(error), missed: \(missed), cached: \(cached)\n")
    }
}

//MARK: - rotation
extension RoomViewController {
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        for session in videoSessions {
            if let sessionSize = session.size {
                session.size = sessionSize.fixedSizeWithReference(size)
            }
        }
        updateInterfaceWithSessions(videoSessions, targetSize: size, animation: true)
    }
}
