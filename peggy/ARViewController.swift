//
//  ARViewController.swift
//  peggy
//
//  Created by Daniel Martin on 05/01/2019.
//  Copyright © 2019 1416394. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    
    private var hud : MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        
        // load in textures for 3D model
        self.sceneView.autoenablesDefaultLighting = true
        
        self.hud = MBProgressHUD.showAdded(to: self.sceneView, animated: true)
        self.hud.label.text = "Detecting Plane"
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        registerGestureRecognisers()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResults = results.first {
                
                let peggyScene = SCNScene(named: "peggy.scn")!
                
                if let peggyNode = peggyScene.rootNode.childNode(withName: "peggy", recursively: true) {
                    
                    peggyNode.position = SCNVector3(x: hitResults.worldTransform.columns.3.x, y: hitResults.worldTransform.columns.3.y, z: hitResults.worldTransform.columns.3.z)
                    
                    sceneView.scene.rootNode.addChildNode(peggyNode)
                    
                }

            }
        }
    }
    
    func restartSession() {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (peggyNode, _) in
            peggyNode.removeFromParentNode()
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    
    
    // declare function that recognises that the users taps to drop Peggy onto plane
    private func registerGestureRecognisers(){
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinched))
        
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        
    }
    
    // implement pinch function
    @objc func pinched(recognizer : UIPinchGestureRecognizer) {
        
        // check if state is being changed i.e. pinched
        if recognizer.state == .changed {
            
            guard let sceneView = recognizer.view as? ARSCNView else {
                return
            }
            
            let touch = recognizer.location(in: sceneView)
            
            let hitTestResults = self.sceneView.hitTest(touch, options: nil)
            
            if let hitTest = hitTestResults.first {
                
                let peggyNode = hitTest.node
                
                let pinchScaleX = Float(recognizer.scale) * peggyNode.scale.x
                let pinchScaleY = Float(recognizer.scale) * peggyNode.scale.y
                let pinchScaleZ = Float(recognizer.scale) * peggyNode.scale.z
                
                peggyNode.scale = SCNVector3(pinchScaleX, pinchScaleY, pinchScaleZ)
                
                recognizer.scale = 1
                
            }
            
        }
        
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // check that the correct plane is detected
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            // tip vertical plane to be horizontal
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            
            gridMaterial.diffuse.contents = #imageLiteral(resourceName: "grid.png")
            plane.materials = [gridMaterial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
            DispatchQueue.main.sync {
                self.hud.label.text = "Plane Detected"
                self.hud.hide(animated: true, afterDelay: 0.5)
            }
            
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Detect floor or horizontal surface as a plane
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
}
