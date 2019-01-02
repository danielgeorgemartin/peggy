//
//  ViewController.swift
//  peggy
//
//  Created by Daniel Martin on 27/12/2018.
//  Copyright © 2018 1416394. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl : UIPageControl!
    @IBOutlet weak var scrollView : UIScrollView!
    
    var images: [String] = ["0", "1", "2"]
    var frame = CGRect(x : 0, y : 0, width : 0, height : 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageControl.numberOfPages = images.count
        
        for index in 0..<images.count {
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            
            let imgView = UIImageView(frame: frame)
            imgView.image = UIImage(named: images[index])
            self.scrollView.addSubview(imgView)
        }
        
        scrollView.contentSize = CGSize(width:(scrollView.frame.width * CGFloat(images.count)), height: scrollView.frame.size.height)
        scrollView.delegate = self

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int (pageNumber)
    }

}

