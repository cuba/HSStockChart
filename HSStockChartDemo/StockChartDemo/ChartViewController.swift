//
//  ChartViewController.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/6.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import SwiftyJSON
import HSStockChart

class ChartViewController: UIViewController {
    
    var chartType: HSChartType = .timeLineForDay
    var timeLineView: HSTimeLine?
    var chartRect: CGRect = CGRect.zero
    var isLandscapeMode: Bool = false

    
    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        print(self.view.frame)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(self.view.frame)
    }
    
    override func viewDidLayoutSubviews() {
        print(self.view.frame)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(self.view.frame)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    // MARK: - Function
    
    func setUpViewController() {
        let stockBasicInfo = HSStockBasicInfoModel.getStockBasicInfoModel(getJsonDataFromFile("SZ300033"))
        
        switch chartType {
            
        case .timeLineForDay:
            timeLineView = HSTimeLine(frame: chartRect)
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("timeLineForDay"), type: chartType, basicInfo: stockBasicInfo)
            timeLineView?.dataT = modelArray
            timeLineView!.isUserInteractionEnabled = true
            timeLineView?.tag = chartType.rawValue
            timeLineView?.isLandscapeMode = self.isLandscapeMode
            self.view.addSubview(timeLineView!)
            
        case .timeLineForFiveday:
            let stockChartView = HSTimeLine(frame: chartRect, isFiveDay: true)
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile("timeLineForFiveday"), type: chartType, basicInfo: stockBasicInfo)
            stockChartView.dataT = modelArray
            stockChartView.isUserInteractionEnabled = true
            stockChartView.tag = chartType.rawValue
            stockChartView.isLandscapeMode = self.isLandscapeMode
            self.view.addSubview(stockChartView)
            
        case .kLineForDay:
            let data = HSKLineModel.getKLineModelArray(getJsonDataFromFile("kLineForDay"))
            let stockChartView = HSKLineView(frame: chartRect, data: data, type: chartType)
            stockChartView.tag = chartType.rawValue
            stockChartView.isLandscapeMode = self.isLandscapeMode
            self.view.addSubview(stockChartView)
            
        case .kLineForWeek:
            let data = HSKLineModel.getKLineModelArray(getJsonDataFromFile("kLineForWeek"))
            let stockChartView = HSKLineView(frame: chartRect, data: data, type: chartType)
            stockChartView.tag = chartType.rawValue
            stockChartView.isLandscapeMode = self.isLandscapeMode
            self.view.addSubview(stockChartView)
            
        case .kLineForMonth:
            let data = HSKLineModel.getKLineModelArray(getJsonDataFromFile("kLineForMonth"))
            let stockChartView = HSKLineView(frame: chartRect, data: data, type: chartType)
            stockChartView.tag = chartType.rawValue
            stockChartView.isLandscapeMode = self.isLandscapeMode
            self.view.addSubview(stockChartView)
        }
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        return JSON(data: jsonContent)
    }
}

extension HSKLineModel {
    class func getKLineModelArray(_ json: JSON) -> [HSKLineModel] {
        var models = [HSKLineModel]()
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = HSKLineModel()
            model.date = Date.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").toString("yyyyMMddHHmmss")
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

extension HSStockBasicInfoModel {
    class func getStockBasicInfoModel(_ json: JSON) -> HSStockBasicInfoModel {
        let model = HSStockBasicInfoModel()
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
            model.time = Date.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").toString("HH:mm")
            model.avgPirce = CGFloat(jsonData["avg_price"].doubleValue)
            model.price = CGFloat(jsonData["current"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
            model.days = (json["days"].arrayObject as? [String]) ?? [""]
            modelArray.append(model)
        }
        return modelArray
    }
    
    class func getTimeLineModelArray(_ json: JSON, type: HSChartType, basicInfo: HSStockBasicInfoModel) -> [HSTimeLineModel] {
        var modelArray = [HSTimeLineModel]()
        var toComparePrice: CGFloat = 0
        
        if type == .timeLineForFiveday {
            toComparePrice = CGFloat(json["chartlist"][0]["current"].doubleValue)
            
        } else {
            toComparePrice = basicInfo.preClosePrice
        }
        
        for (_, jsonData): (String, JSON) in json["chartlist"] {
            let model = HSTimeLineModel()
            model.time = Date.toDate(jsonData["time"].stringValue, format: "EEE MMM d HH:mm:ss z yyyy").toString("HH:mm")
            model.avgPirce = CGFloat(jsonData["avg_price"].doubleValue)
            model.price = CGFloat(jsonData["current"].doubleValue)
            model.volume = CGFloat(jsonData["volume"].doubleValue)
            model.rate = (model.price - toComparePrice) / toComparePrice
            model.preClosePx = basicInfo.preClosePrice
            model.days = (json["days"].arrayObject as? [String]) ?? [""]
            modelArray.append(model)
        }
        
        return modelArray
    }
}
