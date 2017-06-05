//
//  Extension.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/17.
//  Copyright © 2016年 hanson. All rights reserved.
//

import Foundation
import UIKit
import HSStockChart
import SwiftyJSON

extension Candlestick {
    class func getKLineModelArray(_ json: JSON) -> [Candlestick] {
        var models = [Candlestick]()
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = Candlestick()
            model.date = jsonData["time"].stringValue.toDate(withFormat: "EEE MMM d HH:mm:ss z yyyy")!
            model.open = CGFloat(jsonData["open"].doubleValue)
            model.close = CGFloat(jsonData["close"].doubleValue)
            model.high = CGFloat(jsonData["high"].doubleValue)
            model.low = CGFloat(jsonData["low"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
            models.append(model)
        }
        return models
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
