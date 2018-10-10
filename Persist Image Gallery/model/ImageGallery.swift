//
//  ImageGallery.swift
//  Image Gallery
//
//  Created by Apple Macbook on 25/09/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import Foundation

class ImageGallery {
    var name: String
    var addresses: [Address]
    init(name: String, addresses: [Address]) {
        self.name = name
        self.addresses = addresses
    }
}
