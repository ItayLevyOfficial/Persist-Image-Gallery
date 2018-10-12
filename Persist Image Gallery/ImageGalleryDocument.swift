//
//  Document.swift
//  Persist Image Gallery
//
//  Created by Apple Macbook on 10/10/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import UIKit

class ImageGalleryDocument: UIDocument {
    var thumbnail: UIImage?  // thumbnail image for this Document
    var imageGallery: ImageGallery?
    
    override func contents(forType typeName: String) throws -> Any {
        return imageGallery?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let json = contents as? Data {
            imageGallery = ImageGallery(json: json)
        }
    }
    // overridden to add a key-value pair
    // to the dictionary of "file attributes" on the file UIDocument writes
    // the added key-value pair sets a thumbnail UIImage for the UIDocument
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
        var attributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail {
            attributes[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey:thumbnail]
        }
        return attributes
    }
}

