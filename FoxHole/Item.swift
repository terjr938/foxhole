//
//  Item.swift
//  FoxHole
//
//  Created by Tom Rogers on 3/11/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
