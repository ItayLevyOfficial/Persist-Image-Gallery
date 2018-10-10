//
//  Document.swift
//  Persist Image Gallery
//
//  Created by Apple Macbook on 10/10/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

