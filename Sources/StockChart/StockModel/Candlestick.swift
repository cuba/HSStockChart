//
//  Candlestick.swift
//  StockChartExample
//
//  Created by Hanson on 16/8/29.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

public struct Candlestick {
    public var date: Date = Date()
    public var open: CGFloat = 0
    public var close: CGFloat = 0
    public var high: CGFloat = 0
    public var low: CGFloat = 0
    public var volume: CGFloat = 0
    
    public init() {}
}

public struct Line {
    public var values: [CGFloat] = []
    
    public init(values: [CGFloat]) {
        self.values = values
    }
}
