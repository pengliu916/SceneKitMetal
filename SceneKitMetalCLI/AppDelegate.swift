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
    var slider: NSSlider!
    var label: NSTextField!
    
    init(_ width: UInt32, _ height: UInt32) {
        window = NSWindow(contentRect: NSMakeRect(100, 100, CGFloat(width), CGFloat(height)), styleMask: .resizable, backing: .buffered, defer: false, screen: nil)
        
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
        let button = NSButton(frame: NSMakeRect(20, 20, 80, 20))
        button.title = "Switch Show All"
        button.target = self
        button.action = #selector(onClick)
        window.contentView?.addSubview(button)
        
        slider = NSSlider(frame: NSMakeRect(120, 20, 400, 20))
        slider.minValue = 0
        slider.maxValue = 10000
        slider.isContinuous = true
        slider.target = self
        slider.action = #selector(sliderValueChanged)
        window.contentView?.addSubview(slider)
        
        label = NSTextField(frame: NSMakeRect(530, 20, 80, 20))
        label.stringValue = ""
        window.contentView?.addSubview(label)
    }
    
    @IBAction func onClick(_: Any) {
        gameViewCtrl.switchShowAll()
    }
    
    @IBAction func sliderValueChanged(_: Any) {
        let value = slider.floatValue
        gameViewCtrl.setFocusedBrightnessPQ(value)
        label.stringValue = "\(value)nits"
    }
}
