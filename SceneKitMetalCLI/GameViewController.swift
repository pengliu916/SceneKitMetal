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
    var slider: NSSlider!
    var label: NSTextField!
    var button: NSButton!
    var uiContainer: NSView!
    
    private func setupUI() {
        button = NSButton(title: "Switch", target: self, action: #selector(onClick))
        slider = NSSlider(value: 0, minValue: 0, maxValue: 10000, target: self, action: #selector(sliderValueChanged))
        label = NSTextField(labelWithString: "\(slider.floatValue)")
        uiContainer = NSView()
        
        uiContainer.addSubview(button)
        uiContainer.addSubview(label)
        uiContainer.addSubview(slider)
        
        view.addSubview(uiContainer)
        
        uiContainer.translatesAutoresizingMaskIntoConstraints = false
        uiContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        uiContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        uiContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        uiContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalTo: uiContainer.leftAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 80).isActive = true
        button.centerYAnchor.constraint(equalTo: uiContainer.centerYAnchor).isActive = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: button.rightAnchor, constant: 10).isActive = true
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true
        label.centerYAnchor.constraint(equalTo: uiContainer.centerYAnchor).isActive = true
        
        slider.isContinuous = true
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.leftAnchor.constraint(equalTo: label.rightAnchor, constant: -10).isActive = true
        slider.rightAnchor.constraint(equalTo: uiContainer.rightAnchor).isActive = true
        slider.centerYAnchor.constraint(equalTo: uiContainer.centerYAnchor).isActive = true
    }
    
    override func loadView() {
        renderer = MetalRenderer()
        self.view = renderer.sceneView
        setupUI()
        renderer.setupMetalResource()
    }
    
    @IBAction func onClick(_: Any) {
        renderer.switchShowAll()
        renderer.sceneView.sceneTime += 1
    }
    
    @IBAction func sliderValueChanged(_: Any) {
        let value = slider.floatValue
        renderer.setFocusedBrightnessPQ(value)
        renderer.sceneView.sceneTime += 1
        label.stringValue = "\(value)nits"
    }
}
