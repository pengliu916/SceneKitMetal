//
//  AppDelegate.swift
//  SceneKitMetalCLI
//
//  Created by Peng Liu on 11/6/18.
//  Copyright © 2018 Peng Liu. All rights reserved.
//

import Cocoa
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window : NSWindow!
    var gameViewCtrl: GameViewController!
    
    init(_ width: UInt32, _ height: UInt32) {
        window = NSWindow(contentRect: NSMakeRect(100, 100, CGFloat(width), CGFloat(height)), styleMask: .titled, backing: .buffered, defer: false, screen: nil)
        
        let viewCtrl = GameViewController()
        
        window.contentViewController = viewCtrl
        gameViewCtrl = viewCtrl
    }
    
    override init() {
        super.init()
        
        window = NSWindow(contentRect: NSMakeRect(100, 100, 200, 200),
                          styleMask: .titled, backing: .buffered, defer: false, screen: nil)
        let viewCtrl = GameViewController()
        
        window.contentViewController = viewCtrl
        gameViewCtrl = viewCtrl
        
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
       
        window.makeKeyAndOrderFront(nil)
    }
}
