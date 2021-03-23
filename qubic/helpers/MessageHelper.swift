//
//  MessageHelper.swift
//  qubic
//
//  Created by Chris McElroy on 3/21/21.
//  Copyright © 2021 XNO LLC. All rights reserved.
//

import SwiftUI
import UIKit
import MessageUI
import Messages

// from https://medium.com/@florentmorin/messageui-swiftui-and-uikit-integration-82d91159b0bd
extension MainView {
    
    /// Delegate for view controller as `MFMessageComposeViewControllerDelegate`
    class MessageDelegate: NSObject, MFMessageComposeViewControllerDelegate {
        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true)
        }
    }

    /// Present an message compose view controller modally in UIKit environment
    func presentMessageCompose() {
        guard MFMessageComposeViewController.canSendText() else {
            return
        }
        
        let vc = screen.window?.rootViewController
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = messageComposeDelegate

        let message = MSMessage(session: MSSession())
        message.summaryText = "4Play game"
        let layout = MSMessageTemplateLayout()
        layout.image = UIImage(named: "icon1024half")
        layout.caption = "4Play"
        message.layout = layout
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        
        let first: Bool = playSelection[1] == 1 ? 0 == .random(in: 0...1) : playSelection[1] == 0
        
        var urlComponents = URLComponents()
        urlComponents.host = "qubic"
        urlComponents.queryItems = [
            URLQueryItem(name: "game", value: "."),
            URLQueryItem(name: "type", value: "default"),
            URLQueryItem(name: "me", value: uuid),
            URLQueryItem(name: "p1", value: first ? "me" : "op")
        ]
        message.url = urlComponents.url
        
        composeVC.message = message
        
        vc?.present(composeVC, animated: true)
    }
}
