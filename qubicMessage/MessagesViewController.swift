//
//  MessagesViewController.swift
//  qubicMessage
//
//  Created by 4 on 1/9/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    var selected: MSMessage?
    var loadButton = UIButton()
    var gameView = UIView()
    var test = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadButton.frame = CGRect(x: view.center.x-40, y: 100, width: 80, height: 40)
        loadButton.setTitle("load", for: .normal)
        loadButton.setTitleColor(.label, for: .normal)
        loadButton.addTarget(self, action: #selector(pressedStart), for: .touchUpInside)
        view.addSubview(loadButton)
        
        gameView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        
        test.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        test.setTitle("test", for: .normal)
        test.setTitleColor(.label, for: .normal)
        test.addTarget(self, action: #selector(pressedTest), for: .touchUpInside)
        gameView.addSubview(test)
        
        view.addSubview(gameView)
    }
    
    // MARK: - Conversation Handling
    
    override func willSelect(_ message: MSMessage, conversation: MSConversation) {
        selected = message
        loadButton.isHidden = true
        gameView.isHidden = false
    }
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        
        if let newMessage = conversation.selectedMessage {
            selected = newMessage
            loadButton.isHidden = true
            gameView.isHidden = false
        } else {
            loadButton.isHidden = false
            gameView.isHidden = true
        }
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dismisses the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
   
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
    
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
    
        // Use this method to prepare for the change in presentation style.
        if selected != nil && presentationStyle == .compact {
            selected = nil
            loadButton.isHidden = false
            print("should hide game")
        }
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
    
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
    @objc func pressedTest() {
        let message = MSMessage(session: selected?.session ?? MSSession())
        message.summaryText = "4Play game"
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: "blueCube")
        layout.caption = "4Play"
        message.layout = layout
        activeConversation?.send(message)
    }
    
    @objc func pressedStart() {
        let message = MSMessage(session: selected?.session ?? MSSession())
        message.summaryText = "4Play game"
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: "blueCube")
        layout.caption = "4Play"
        message.layout = layout
        activeConversation?.insert(message)
    }

}
