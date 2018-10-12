//
//  ImageGallery.swift
//  Image Gallery
//
//  Created by Apple Macbook on 25/09/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import Foundation

struct ImageGallery: Codable {
    var addresses: [Address]
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    init() {
        addresses = []
    }
    init?(json: Data) // take some JSON and try to init an ImageGallery from it
    {
        if let newValue = try? JSONDecoder().decode(ImageGallery.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
}
