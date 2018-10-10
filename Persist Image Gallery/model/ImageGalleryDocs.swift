//
//  ImageGalleryDocs.swift
//  Image Gallery
//
//  Created by Apple Macbook on 25/09/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import Foundation

struct ImageGalleryDocs {
    subscript(section: Int) -> [ImageGallery] {
        switch section {
        case 0:
            return imageGallerys
        case 1:
            return recentlyDeleted
        default:
            return []
        }
    }
    var imageGallerys: [ImageGallery] = []
    var recentlyDeleted: [ImageGallery] = []
}
