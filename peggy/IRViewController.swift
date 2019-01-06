//
//  IRViewController.swift
//  peggy
//
//  Created by Daniel Martin on 06/01/2019.
//  Copyright © 2019 1416394. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
class IRViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Enable lighting within the scene
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration, use Image Recognition instead of Plane Recognition
        let configuration = ARImageTrackingConfiguration()
        
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Peggy-Platform" , bundle: Bundle.main) {
            
            configuration.trackingImages = imageToTrack 
            
            configuration.maximumNumberOfTrackedImages = 1
            
        }
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor {
            
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
            
            let planeNode = SCNNode(geometry: plane)
            
            planeNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(planeNode)
            
            if let peggyScene = SCNScene(named: "peggy.scn") {
                
                if let peggyNode = peggyScene.rootNode.childNodes.first {
                    
                    peggyNode.eulerAngles.x = .pi / 2
                    peggyNode.eulerAngles.z = .pi / 2

                    
                    planeNode.addChildNode(peggyNode)
                    
                }
            }
            
        }
        
        return node
        
    }
}
