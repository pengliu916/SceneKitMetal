//
//  GameViewController.swift
//  SceneKitMetalCLI
//
//  Created by Peng Liu on 11/6/18.
//  Copyright © 2018 Peng Liu. All rights reserved.
//

import Cocoa
import SceneKit
import MetalKit

// Our macOS specific view controller
class GameViewController: NSViewController {
    var renderer: MetalRenderer!
    override func loadView() {
        renderer = MetalRenderer()
        self.view = renderer.sceneView
        
        renderer.setupMetalResource()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderer.setupMetalResource()
      
    }
    
    override func viewWillAppear() {
//        self.view.window?.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
//        self.view.window?.toolbar?.isVisible = true
//        self.view.window?.titleVisibility = .hidden
//        self.view.window?.titlebarAppearsTransparent = true
//        self.view.window?.isMovableByWindowBackground = false
//        self.view.window?.standardWindowButton(NSWindow.ButtonType.closeButton)?.isHidden = true
//        self.view.window?.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isHidden = true
//        self.view.window?.standardWindowButton(NSWindow.ButtonType.zoomButton)?.isHidden = true
    }
}
