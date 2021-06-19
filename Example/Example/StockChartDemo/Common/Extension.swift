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

struct GraphData: Decodable {
    enum CodingKeys: String, CodingKey {
        case chartlist
    }
    
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let chartlist = try container.decode([ChartlistResponse].self, forKey: .chartlist)
        var candlesticks: [Candlestick] = []
        
        var lines: [String: [CGFloat]] = [
            "ma5": [],
            "ma10": [],
            "ma20": [],
            // "ma30": []
        ]
        
        for chartlistRow in chartlist {
            var candlestick = Candlestick()
            candlestick.date = chartlistRow.date
            candlestick.open = chartlistRow.open
            candlestick.close = chartlistRow.close
            candlestick.high = chartlistRow.high
            candlestick.low = chartlistRow.low
            candlestick.volume = chartlistRow.volume
            
            candlesticks.append(candlestick)
            lines["ma5"]?.append(chartlistRow.ma5)
            lines["ma10"]?.append(chartlistRow.ma10)
            lines["ma20"]?.append(chartlistRow.ma20)
        }
        
        self.init(candlesticks: candlesticks, lines: lines.map({ (key: $0, values: $1) }))
    }
}

struct ChartlistResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case time
        case open
        case close
        case high
        case low
        case volume
        case ma5
        case ma10
        case ma20
    }
    
    let date: Date
    let open: CGFloat
    let close: CGFloat
    let high: CGFloat
    let low: CGFloat
    let volume: CGFloat
    let ma5: CGFloat
    let ma10: CGFloat
    let ma20: CGFloat
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decode(String.self, forKey: .time)
        
        guard let date = DateFormatter.chartListTime.date(from: dateString) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not convert `\(dateString)` to `Date`. Expecting it to be in the following format: `\(DateFormatter.chartListTime.dateFormat!)`"))
        }
        
        self.date = date
        self.open = try container.decode(CGFloat.self, forKey: .open)
        self.close = try container.decode(CGFloat.self, forKey: .close)
        self.high = try container.decode(CGFloat.self, forKey: .high)
        self.low = try container.decode(CGFloat.self, forKey: .low)
        self.volume = try container.decode(CGFloat.self, forKey: .volume)
        self.ma5 = try container.decode(CGFloat.self, forKey: .ma5)
        self.ma10 = try container.decode(CGFloat.self, forKey: .ma10)
        self.ma20 = try container.decode(CGFloat.self, forKey: .ma20)
    }
}
