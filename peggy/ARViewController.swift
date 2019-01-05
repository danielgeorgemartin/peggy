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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load in textures for 3D model
        self.sceneView.autoenablesDefaultLighting = true
        
        
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
    
    
    // declare function that recognises that the users taps to drop Peggy onto plane
    private func registerGestureRecognisers(){
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
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
    
    // implement tap function
    @objc func tapped(recogniser : UITapGestureRecognizer) {
        
        // get coordinates of where the user has tapped
        guard let sceneView = recogniser.view as? ARSCNView else {
            return
        }
        
        // recognise where user has touched in sceneView
        let touch = recogniser.location(in: sceneView)
        
        // check whether location of touch intersects with horizontal scene plane
        let hitTestResults = sceneView.hitTest(touch, types: .existingPlane)
        
        // takes first item of hit test array to check whether touch has occurred and is valid
        if let hitTest = hitTestResults.first {
            
            let peggyScene = SCNScene(named: "peggy.scn")!
            
            guard let peggyNode = peggyScene.rootNode.childNode(withName: "peggy", recursively: true) else {
                return
            }
            
            // use 3D coordinates that user has touched on the plane
            peggyNode.position = SCNVector3(hitTest.worldTransform.columns.3.x, hitTest.worldTransform.columns.3.y, hitTest.worldTransform.columns.3.z)
            
            self.sceneView.scene.rootNode.addChildNode(peggyNode)
            
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // check that the correct plane is detected
        if anchor is ARPlaneAnchor {
            

            
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
