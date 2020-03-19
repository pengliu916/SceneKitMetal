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
    var edrFactor:Float
}

class MetalRenderer: NSObject, SCNSceneRendererDelegate, SCNNodeRendererDelegate {
    
    let sceneView: SCNView
    let renderer: SCNRenderer
    
    var dev: MTLDevice!
    var pixFormat:MTLPixelFormat!
    var vertexBuf: MTLBuffer!
    var gfxPSO: MTLRenderPipelineState!
    var depthState: MTLDepthStencilState!
    var library: MTLLibrary!
    var vsShader: MTLFunction!
    var psShader: MTLFunction!
    var mtlVertDesc: MTLVertexDescriptor!
    
    var showAll: Bool = true
    
    var focusedBrightnessPQ: Float = 100
    
    public func switchShowAll() {
        showAll = !showAll
    }
    
    public func setFocusedBrightnessPQ(_ val: Float) {
        focusedBrightnessPQ = val
    }
    
    override init() {
        dev = MTLCreateSystemDefaultDevice()
        renderer = SCNRenderer(device: dev, options: nil)
        renderer.scene = SCNScene()
        sceneView = SCNView(frame: NSApplication.shared.windows[0].frame)
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = .darkGray
        sceneView.rendersContinuously = false
        let caMTLLayer = sceneView.layer as! CAMetalLayer
        caMTLLayer.wantsExtendedDynamicRangeContent = true
        caMTLLayer.colorspace = CGColorSpace.init(name: CGColorSpace.displayP3)
        //sceneView.showsStatistics = true
        
        let camera = SCNCamera ()
        let cameraNode = SCNNode ()
        camera.zNear = 0.001
        camera.fieldOfView = 45
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(0, 0, 1) // set your camera position
        renderer.scene!.rootNode.addChildNode(cameraNode)
        
//        let origin = SCNSphere(radius: 0.05)
//        let originNode = SCNNode(geometry: origin)
//        originNode.position = SCNVector3Make(0, 0, 0)
//        renderer.scene!.rootNode.addChildNode(originNode)
        
        sceneView.scene = renderer.scene
        pixFormat = sceneView.colorPixelFormat
        
        // Creating shader
        library = dev.makeDefaultLibrary()
        vsShader = library.makeFunction(name: "vsRender")
        psShader = library.makeFunction(name: "fsRender")
        
        super.init()
        
        
        let dummyNode = SCNNode()
        dummyNode.rendererDelegate = self
        renderer.scene?.rootNode.addChildNode(dummyNode)
    }
    
    func setupMetalResource() {
        // Create vertex resource
        let fishMeshVertex: [Float] = [-0.5, -0.5, -0.5,
                                       +0.5, -0.5, -0.5,
                                       +0.5, -0.5, +0.5,
                                       -0.5, -0.5, +0.5,
                                       -0.5, -0.5, -0.5,
                                       -0.5, +0.5, -0.5,
                                       +0.5, +0.5, -0.5,
                                       +0.5, +0.5, +0.5,
                                       -0.5, +0.5, +0.5,
                                       -0.5, +0.5, -0.5,
                                       -0.5, +0.5, +0.5,
                                       -0.5, -0.5, +0.5,
                                       +0.5, -0.5, +0.5,
                                       +0.5, +0.5, +0.5,
                                       +0.5, +0.5, -0.5,
                                       +0.5, -0.5, -0.5]
        vertexBuf = dev.makeBuffer(bytes: fishMeshVertex, length: MemoryLayout<Float>.size * 16*3, options: MTLResourceOptions.storageModeManaged)
        // Create graphics pipeline obj
        mtlVertDesc = MetalRenderer.buildMetalVertexDescriptor()
        
        let depthStateDesciptor = MTLDepthStencilDescriptor()
        depthStateDesciptor.depthCompareFunction = MTLCompareFunction.greater
        depthStateDesciptor.isDepthWriteEnabled = true
        guard let state = dev.makeDepthStencilState(descriptor:depthStateDesciptor) else { return }
        depthState = state
        
        sceneView.delegate = self
    }
    
    private func createPSO(pixelformat: MTLPixelFormat, sampleCnt: Int) {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "RenderPipeline"
        pipelineDescriptor.sampleCount = sampleCnt
        pipelineDescriptor.vertexFunction = vsShader
        pipelineDescriptor.fragmentFunction = psShader
        pipelineDescriptor.vertexDescriptor = mtlVertDesc
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = pixelformat
        pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormat.depth32Float
        
        gfxPSO = try? dev.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        if gfxPSO == nil {print("Failed to get PSO")}
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
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
//        if gfxPSO == nil || pixFormat != sceneView.colorPixelFormat {
//            createPSO(pixelformat: sceneView.colorPixelFormat, sampleCnt: 4)
//        }
//        guard let gfxEncoder = renderer.currentRenderCommandEncoder else {return}
//        let x = UInt32(32)
//        let y = UInt32(32)
//        let z = UInt32(32)
//        gfxEncoder.setCullMode(.none)
//        gfxEncoder.setFrontFacing(.counterClockwise)
//        gfxEncoder.setRenderPipelineState(gfxPSO)
//        gfxEncoder.setDepthStencilState(depthState)
//        gfxEncoder.setVertexBuffer(vertexBuf, offset: 0, index: 0)
//        var matrixs = Uniforms(projectionMatrix: float4x4.init((sceneView.pointOfView?.camera?.projectionTransform)!), modelViewMatrix: float4x4.init((sceneView.pointOfView?.worldTransform)!).inverse)
//        var bufSize = MemoryLayout<Float>.size * (2 * 16)
//        gfxEncoder.setVertexBytes(&matrixs, length: bufSize, index: 1)
//        var quantile = vector_uint3(x, y, z)
//        bufSize = MemoryLayout<vector_uint3>.size
//        gfxEncoder.setVertexBytes(&quantile, length: bufSize, index: 2)
//        gfxEncoder.setVertexBytes(&showAll, length:MemoryLayout<Bool>.size, index: 3)
//        gfxEncoder.setVertexBytes(&focusedBrightnessPQ, length: MemoryLayout<Float>.size, index: 4)
//        gfxEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: 16, instanceCount: Int(x*y*z))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
    
    // SCNNodeRendererDelegate
    func renderNode(_ node: SCNNode, renderer: SCNRenderer, arguments: [String : Any]) {
        if gfxPSO == nil || pixFormat != sceneView.colorPixelFormat {
            createPSO(pixelformat: sceneView.colorPixelFormat, sampleCnt: 4)
        }
        guard let gfxEncoder = renderer.currentRenderCommandEncoder else {return}
        let x = UInt32(48)
        let y = UInt32(48)
        let z = UInt32(48)
        gfxEncoder.setRenderPipelineState(gfxPSO)
        gfxEncoder.setDepthStencilState(depthState)
        gfxEncoder.setVertexBuffer(vertexBuf, offset: 0, index: 0)
        var matrixs = Uniforms(projectionMatrix: float4x4(arguments[SCNProjectionTransform] as! SCNMatrix4), modelViewMatrix: float4x4.init((sceneView.pointOfView?.worldTransform)!).inverse, edrFactor: Float(NSScreen.main!.maximumExtendedDynamicRangeColorComponentValue))
        var bufSize = MemoryLayout<Float>.size * (2 * 16 + 4)
        gfxEncoder.setVertexBytes(&matrixs, length: bufSize, index: 1)
        var quantile = vector_uint3(x, y, z)
        bufSize = MemoryLayout<vector_uint3>.size
        gfxEncoder.setVertexBytes(&quantile, length: bufSize, index: 2)
        gfxEncoder.setVertexBytes(&showAll, length:MemoryLayout<Bool>.size, index: 3)
        gfxEncoder.setVertexBytes(&focusedBrightnessPQ, length: MemoryLayout<Float>.size, index: 4)
        gfxEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: 16, instanceCount: Int(x*y*z))
    }
}
