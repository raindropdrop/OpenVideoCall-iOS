//
//  ChatMessageCell.swift
//  OpenVideoCall
//
//  Created by GongYuhua on 16/8/15.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    func setMessage(message: Message) {
        backgroundColor = UIColor.clearColor()
        
        messageLabel.text = message.text
        colorView.backgroundColor = message.type.color()
    }
}