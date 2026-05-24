//
//  Item.swift
//  submil
//
//  Created by 渡邊光 on 2026/05/25.
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
