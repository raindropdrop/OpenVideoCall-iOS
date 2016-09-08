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
    
    fileprivate var messageList = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 24
    }
    
    func appendChat(_ text: String, fromUid uid: Int64) {
        let message = Message(text: text, type: .chat)
        appendMessage(message)
    }
    
    func appendAlert(_ text: String) {
        let message = Message(text: text, type: .alert)
        appendMessage(message)
    }
}

private extension ChatMessageViewController {
    func appendMessage(_ message: Message) {
        messageList.append(message)
        
        var deleted: Message?
        if messageList.count > 20 {
            deleted = messageList.removeFirst()
        }
        
        updateMessageTableWithDeletedMesage(deleted)
    }
    
    func updateMessageTableWithDeletedMesage(_ deleted: Message?) {
        guard let tableView = messageTableView else {
            return
        }
        
        let insertIndexPath = IndexPath(row: messageList.count - 1, section: 0)
        
        tableView.beginUpdates()
        if deleted != nil {
            tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
        tableView.insertRows(at: [insertIndexPath], with: .none)
        tableView.endUpdates()
        
        tableView.scrollToRow(at: insertIndexPath, at: .bottom, animated: false)
    }
}

extension ChatMessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! ChatMessageCell
        let message = messageList[(indexPath as NSIndexPath).row]
        cell.setMessage(message)
        return cell
    }
}
