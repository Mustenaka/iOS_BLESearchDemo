//
//  Item.swift
//  BLESearchDemo
//
//  Created by Andrew Wang on 2024/10/21.
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
