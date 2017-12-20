//
//  Extension.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/17.
//  Copyright © 2016年 hanson. All rights reserved.
//

import Foundation
import UIKit
import StockChart
import SwiftyJSON

struct GraphData {
    var candlesticks: [Candlestick]
    var lines: [(key: String, values: [CGFloat])]
    
    var count: Int {
        return candlesticks.count
    }
    
    init(candlesticks: [Candlestick], lines: [(key: String, values: [CGFloat])]) {
        self.candlesticks = candlesticks
        self.lines = lines
    }
    
    init() {
        self.init(candlesticks: [], lines: [])
    }
}

extension Candlestick {
    class func getKLineModelArray(_ json: JSON) -> GraphData {
        var candlesticks: [Candlestick] = []
        
        var lines: [String: [CGFloat]] = [
            "ma5": [],
            "ma10": [],
            "ma20": [],
            // "ma30": []
        ]
        
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let candlestick = Candlestick()
            candlestick.date = jsonData["time"].stringValue.toDate(withFormat: "EEE MMM d HH:mm:ss z yyyy")!
            candlestick.open = CGFloat(jsonData["open"].doubleValue)
            candlestick.close = CGFloat(jsonData["close"].doubleValue)
            candlestick.high = CGFloat(jsonData["high"].doubleValue)
            candlestick.low = CGFloat(jsonData["low"].doubleValue)
            candlestick.volume = CGFloat(jsonData["volume"].doubleValue)
            
            lines["ma5"]?.append(CGFloat(jsonData["ma5"].doubleValue))
            lines["ma10"]?.append(CGFloat(jsonData["ma10"].doubleValue))
            lines["ma20"]?.append(CGFloat(jsonData["ma20"].doubleValue))
            // lines["ma30"]?.append(CGFloat(jsonData["ma30"].doubleValue))
            
            candlesticks.append(candlestick)
        }
        
        return GraphData(candlesticks: candlesticks, lines: lines.map({ (key: $0, values: $1) }))
    }
    
    class func getKLineModelArray() {
        
    }
}

extension StockInfo {
    static func getStockBasicInfoModel(_ json: JSON) -> StockInfo {
        var model = StockInfo()
        model.stockName = json["SZ300033"]["name"].stringValue
        model.preClosePrice = CGFloat(json["SZ300033"]["last_close"].doubleValue)
        
        return model
    }
}
