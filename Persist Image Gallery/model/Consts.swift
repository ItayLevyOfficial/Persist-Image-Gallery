//
//  Consts.swift
//  Image Gallery
//
//  Created by Apple Macbook on 30/09/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import Foundation
import UIKit
struct Consts {
    static let imageCellIdentifier = "Image Cell"
    static let placeHolderCellIdentifier = "Place Holder Cell"
    static let segueIdentifier = "Show Image"
    static let imageDocCell = "Image Doc Cell"
    static let cellMinWidth: CGFloat = 80
    static let showImageGallerySegueIdentifier = "Show Image Gallery"
    static var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(30))
    }
}
