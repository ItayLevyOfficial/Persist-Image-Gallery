//
//  ViewController.swift
//  Image Gallery
//
//  Created by Apple Macbook on 16/09/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    var image: UIImage = UIImage()
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = Consts.scrollViewMinimumZoomScale
            scrollView.maximumZoomScale = Consts.scrollViewMaximumZoomScale
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        adjustScrollViewWidthAndHeightToContentSize()
    }
    fileprivate func adjustScrollViewWidthAndHeightToContentSize() {
        scrollView.contentSize = imageView.image!.size
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant = scrollView.contentSize.width
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant = scrollView.contentSize.width
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.layoutIfNeeded()
    }
}

