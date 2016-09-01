//
//  ChatMessageViewController.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 16/8/15.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit

class ChatMessageViewController: UIViewController {
    
    @IBOutlet weak var messageTableView: UITableView!
    
    private var messageList = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 24
    }
    
    func appendChat(text: String, fromUid uid: Int64) {
        let message = Message(text: text, type: .Chat)
        appendMessage(message)
    }
    
    func appendAlert(text: String) {
        let message = Message(text: text, type: .Alert)
        appendMessage(message)
    }
}

private extension ChatMessageViewController {
    func appendMessage(message: Message) {
        messageList.append(message)
        
        var deleted: Message?
        if messageList.count > 20 {
            deleted = messageList.removeFirst()
        }
        
        updateMessageTableWithDeletedMesage(deleted)
    }
    
    func updateMessageTableWithDeletedMesage(deleted: Message?) {
        guard let tableView = messageTableView else {
            return
        }
        
        let insertIndexPath = NSIndexPath(forRow: messageList.count - 1, inSection: 0)
        
        tableView.beginUpdates()
        if deleted != nil {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
        }
        tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: .None)
        tableView.endUpdates()
        
        tableView.scrollToRowAtIndexPath(insertIndexPath, atScrollPosition: .Bottom, animated: false)
    }
}

extension ChatMessageViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as! ChatMessageCell
        let message = messageList[indexPath.row]
        cell.setMessage(message)
        return cell
    }
}
