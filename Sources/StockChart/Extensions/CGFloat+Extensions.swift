//
//  CGFloat+Extensions.swift
//  HSStockChart
//
//  Created by Jacob Sikorski on 2017-05-28.
//  Copyright © 2017 Jacob Sikorski. All rights reserved.
//

import Foundation
import UIKit

extension CGFloat {
    func toString(withFormat format: String) -> String {
        return String(format: "%\(format)f", self)
    }
    
    func toPercentString(withFormat format: String)-> String {
        return String(format: "%\(format)f%%", self)
    }
}
