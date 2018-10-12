//
//  Document.swift
//  Persist Image Gallery
//
//  Created by Apple Macbook on 10/10/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import UIKit

class ImageGalleryDocument: UIDocument {
    
    var imageGallery: ImageGallery?
    
    override func contents(forType typeName: String) throws -> Any {
        return imageGallery?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data {
            imageGallery = ImageGallery(json: json)
        }
    }
}

