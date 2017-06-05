//
//  Candlestick.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/8/29.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

open class GraphData {
    open var candlesticks: [Candlestick]
    open var lines: [(key: String, values: [CGFloat])]
    
    var count: Int {
        return candlesticks.count
    }
    
    public init(candlesticks: [Candlestick], lines: [(key: String, values: [CGFloat])]) {
        self.candlesticks = candlesticks
        self.lines = lines
    }
    
    convenience init() {
        self.init(candlesticks: [], lines: [])
    }
}

open class Candlestick: Model {
    // Protocol Values
    public var date: Date = Date()
    public var open: CGFloat = 0
    public var close: CGFloat = 0
    public var high: CGFloat = 0
    public var low: CGFloat = 0
    public var volume: CGFloat = 0
    
    public var price: CGFloat {
        return close
    }
    
    public init(date: Date) {
        self.date = date
    }
    
    public init() {
        
    }
}
