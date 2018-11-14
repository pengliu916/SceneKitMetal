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
        window = NSWindow(contentRect: NSMakeRect(100, 100, CGFloat(width), CGFloat(height)),
                          styleMask: [.titled, .fullSizeContentView ,.resizable], backing: .buffered, defer: false)
        gameViewCtrl = GameViewController()
        
        window.contentViewController = gameViewCtrl
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let menubar = NSMenu(title: "MenuBar")
        let appMenu = NSMenu(title: "")
        appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: "q")
        menubar.addItem(withTitle: "AppNameWillBeChangedAutomatically", action: nil, keyEquivalent: "")
        menubar.setSubmenu(appMenu, for: menubar.item(at: 0)!)
        app.mainMenu = menubar;
        window.contentView = gameViewCtrl.view
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.standardWindowButton(.miniaturizeButton)!.isHidden = true
        window.standardWindowButton(.zoomButton)!.isHidden = true
        window.standardWindowButton(.closeButton)!.isEnabled = true
        
        window.makeKeyAndOrderFront(nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
