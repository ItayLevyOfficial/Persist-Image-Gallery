//
//  URLItem.swift
//  Image Gallery
//
//  Created by Apple Macbook on 17/09/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import Foundation
struct Address: Equatable, Codable {
    let aspectRatio: Double
    let url: URL
    
    static func == (lhs: Address, rhs: Address) -> Bool {
        return lhs.aspectRatio == rhs.aspectRatio && lhs.url == rhs.url
    }
}
