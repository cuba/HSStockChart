//
//  BaseModel.swift
//  HSStockChart
//
//  Created by Jacob Sikorski on 2017-05-30.
//  Copyright © 2017 Jacob Sikorski. All rights reserved.
//

import Foundation

public protocol Model {
    var date: Date { get }
    var price: CGFloat { get }
    var volume: CGFloat { get }
}
