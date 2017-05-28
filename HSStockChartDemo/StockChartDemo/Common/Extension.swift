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
            model.ma5 = CGFloat(jsonData["ma5"].doubleValue)
            model.ma10 = CGFloat(jsonData["ma10"].doubleValue)
            model.ma20 = CGFloat(jsonData["ma20"].doubleValue)
            model.ma30 = CGFloat(jsonData["ma30"].doubleValue)
            model.diff = CGFloat(jsonData["dif"].doubleValue)
            model.dea = CGFloat(jsonData["dea"].doubleValue)
            model.macd = CGFloat(jsonData["macd"].doubleValue)
            model.rate = CGFloat(jsonData["percent"].doubleValue)
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

extension HSTimeLineModel {
    class func getTimeLineModelArray(_ json: JSON) -> [HSTimeLineModel] {
        var modelArray = [HSTimeLineModel]()
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = HSTimeLineModel()
            model.time = jsonData["time"].stringValue.toDate(withFormat: "EEE MMM d HH:mm:ss z yyyy")!
            model.avgPirce = CGFloat(jsonData["avg_price"].doubleValue)
            model.price = CGFloat(jsonData["current"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
            model.days = (json["days"].arrayObject as? [String]) ?? [""]
            modelArray.append(model)
        }
        return modelArray
    }
    
    class func getTimeLineModelArray(_ json: JSON, type: HSChartType, stockInfo: StockInfo) -> [HSTimeLineModel] {
        var modelArray = [HSTimeLineModel]()
        let toComparePrice = CGFloat(json["chartlist"][0]["current"].doubleValue)
        
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = HSTimeLineModel()
            model.time = jsonData["time"].stringValue.toDate(withFormat: "EEE MMM d HH:mm:ss z yyyy")!
            model.avgPirce = CGFloat(jsonData["avg_price"].doubleValue)
            model.price = CGFloat(jsonData["current"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
            model.rate = (model.price - toComparePrice) / toComparePrice
            model.preClosePrice = stockInfo.preClosePrice
            model.days = (json["days"].arrayObject as? [String]) ?? [""]
            modelArray.append(model)
        }
        
        return modelArray
    }
}