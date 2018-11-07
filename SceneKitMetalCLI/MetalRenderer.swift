//
//  MetalRenderer.swift
//  SceneKitMetalCLI
//
//  Created by Peng Liu on 11/6/18.
//  Copyright © 2018 Peng Liu. All rights reserved.
//

import MetalKit
import SceneKit

struct Uniforms {
    var projectionMatrix:matrix_float4x4
    var modelViewMatrix:matrix_float4x4
}

class MetalRenderer: NSObject, SCNSceneRendererDelegate {
    
    let sceneView: SCNView
    let renderer: SCNRenderer
    
    var dev: MTLDevice!
    var pixFormat:MTLPixelFormat!
    var vertexBuf: MTLBuffer!
    var gfxPSO: MTLRenderPipelineState!
    var depthState: MTLDepthStencilState!
    
    override init() {
        dev = MTLCreateSystemDefaultDevice()
        renderer = SCNRenderer(device: dev, options: nil)
        renderer.scene = SCNScene()
        sceneView = SCNView(frame: NSApplication.shared.windows[0].frame)
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
        var torus = SCNTorus(ringRadius: 1, pipeRadius: 0.35)
        var torusNode = SCNNode(geometry: torus)
        renderer.scene!.rootNode.addChildNode(torusNode)
        let camera = SCNCamera ()
        let cameraNode = SCNNode ()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0, 0, 10) // set your camera position
        renderer.scene!.rootNode.addChildNode(cameraNode)
        
        sceneView.scene = renderer.scene
        pixFormat = .rgba16Float
        //pixFormat = (sceneView.layer as! CAMetalLayer).pixelFormat
        super.init()
    }
    
    func setupMetalResource() {
        // Create vertex resource
        let fishMeshVertex: [Float] = [ -0.3,  0.0, -0.3, 1.0,  0.0,  0.0, -0.3,  0.0, -0.3, -1.0,  1.0,  0.0, -0.3,  0.0,  0.3, 1.0,  0.0,  0.0, -0.3,  0.0,  0.3, -1.0, -1.0,  0.0, -0.3,  0.0, -0.3, 1.0,  0.0,  0.0]
        vertexBuf = dev.makeBuffer(bytes: fishMeshVertex, length: MemoryLayout<Float>.size * 30, options: MTLResourceOptions.storageModeManaged)
        // Create graphics pipeline obj
        let mtlVertDesc = MetalRenderer.buildMetalVertexDescriptor()
        guard let PSO = self.buildRenderPipelineWithDevice(device: dev, mtlVertexDescriptor: mtlVertDesc) else {return}
        gfxPSO = PSO
        let depthStateDesciptor = MTLDepthStencilDescriptor()
        depthStateDesciptor.depthCompareFunction = MTLCompareFunction.less
        depthStateDesciptor.isDepthWriteEnabled = true
        guard let state = dev.makeDepthStencilState(descriptor:depthStateDesciptor) else { return }
        depthState = state
        
        sceneView.delegate = self
    }
    class func buildMetalVertexDescriptor() -> MTLVertexDescriptor {
        // Creete a Metal vertex descriptor specifying how vertices will by laid out for input into our render
        //   pipeline and how we'll layout our Model IO vertices
        
        let mtlVertexDescriptor = MTLVertexDescriptor()
        
        mtlVertexDescriptor.attributes[0].format = MTLVertexFormat.float3
        mtlVertexDescriptor.attributes[0].offset = 0
        mtlVertexDescriptor.attributes[0].bufferIndex = 0
        
        mtlVertexDescriptor.layouts[0].stride = 12
        mtlVertexDescriptor.layouts[0].stepRate = 1
        mtlVertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunction.perVertex
        
        return mtlVertexDescriptor
    }
    func buildRenderPipelineWithDevice(device: MTLDevice, mtlVertexDescriptor: MTLVertexDescriptor) -> MTLRenderPipelineState? {
        /// Build a render state pipeline object
        // Creating shader
        guard let library = device.makeDefaultLibrary() else {print("Failed get library");return nil}
        guard let vertexFunction = library.makeFunction(name: "vsRender") else {print("Failed get vs");return nil}
        guard let fragmentFunction = library.makeFunction(name: "fsRender") else {print("Failed get fs");return nil}
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "RenderPipeline"
        pipelineDescriptor.sampleCount = 4
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = mtlVertexDescriptor
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixFormat
        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.depth32Float
        
        guard let pos = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor) else {print("Failed get PSO");return nil}
        return pos
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard let gfxEncoder = renderer.currentRenderCommandEncoder else {return}
        gfxEncoder.setCullMode(.none)
        gfxEncoder.setFrontFacing(.counterClockwise)
        gfxEncoder.setRenderPipelineState(gfxPSO)
        gfxEncoder.setDepthStencilState(depthState)
        gfxEncoder.setVertexBuffer(vertexBuf, offset: 0, index: 0)
        var matrixs = Uniforms(projectionMatrix: float4x4.init((sceneView.pointOfView?.camera?.projectionTransform)!), modelViewMatrix: float4x4.init((sceneView.pointOfView?.worldTransform)!).inverse)
        let bufSize = MemoryLayout<Float>.size * (2 * 16)
        gfxEncoder.setVertexBytes(&matrixs, length: bufSize, index: 1)
        gfxEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 10, instanceCount: 2)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
}
