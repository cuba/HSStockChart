//
//  ViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/15.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import HSStockChart
import SwiftyJSON

public enum HSChartType: Int {
    case timeLineForDay
    case timeLineForFiveday
    case kLineForDay
    case kLineForWeek
    case kLineForMonth
    
    var chartType: ChartType {
        switch self {
        case .timeLineForDay:       fallthrough
        case .timeLineForFiveday:   return .timeLine
        case .kLineForMonth:        fallthrough
        case .kLineForDay:          fallthrough
        case .kLineForWeek:         return .candlesticks
        }
    }
    
    var title: String {
        switch self {
        case .timeLineForDay:       return "Day"
        case .timeLineForFiveday:   return "5 Days"
        case .kLineForDay:          return "Day"
        case .kLineForWeek:         return "Week"
        case .kLineForMonth:        return "Month"
        }
    }
    
    var filename: String {
        switch self {
        case .timeLineForDay:       return "timeLineForDay"
        case .timeLineForFiveday:   return "timeLineForFiveday"
        case .kLineForDay:          return "kLineForDay"
        case .kLineForWeek:         return "kLineForWeek"
        case .kLineForMonth:        return "kLineForMonth"
        }
    }
}

class ViewController: UIViewController {
    var containerView: UIView!
    var segmentMenu: SegmentMenu!
    var stockBriefView: HSStockBriefView!
    var lineBriefView: HSKLineBriefView!
    var currentChartView: UIView?
    
    var chartTypes: [HSChartType] = [.timeLineForDay, .timeLineForFiveday, .kLineForDay, .kLineForWeek, .kLineForMonth]
    
    var menuTitles: [String] {
        return self.chartTypes.map { $0.title }
    }
    
    
    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationsObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentMenu.selectButton(at: segmentMenu.currentIndex)
    }
    
    // MARK: -
    
    override func loadView() {
        super.loadView()
        segmentMenu = SegmentMenu(frame: CGRect.zero)
        segmentMenu.setButtons(from: menuTitles)
        stockBriefView = HSStockBriefView(frame: CGRect.zero)
        lineBriefView = HSKLineBriefView(frame: CGRect.zero)
        containerView = UIView()
        
        containerView.backgroundColor = UIColor.white
        lineBriefView?.isHidden = true
        stockBriefView?.isHidden = true
        segmentMenu.delegate = self
        
        self.view.addSubview(segmentMenu)
        self.view.addSubview(stockBriefView)
        self.view.addSubview(lineBriefView)
        self.view.addSubview(containerView)
        
        segmentMenu.translatesAutoresizingMaskIntoConstraints = false
        lineBriefView.translatesAutoresizingMaskIntoConstraints = false
        stockBriefView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        segmentMenu.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        segmentMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        segmentMenu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        segmentMenu.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        stockBriefView.topAnchor.constraint(equalTo: segmentMenu.topAnchor, constant: 0).isActive = true
        stockBriefView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        stockBriefView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        stockBriefView.bottomAnchor.constraint(equalTo: segmentMenu.bottomAnchor, constant: 0).isActive = true
        
        lineBriefView.topAnchor.constraint(equalTo: segmentMenu.topAnchor, constant: 0).isActive = true
        lineBriefView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        lineBriefView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        lineBriefView.bottomAnchor.constraint(equalTo: segmentMenu.bottomAnchor, constant: 0).isActive = true
        
        containerView.topAnchor.constraint(equalTo: segmentMenu.bottomAnchor, constant: 0).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
    }
    
    func addNotificationsObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(showLongPressView), name: NSNotification.Name(rawValue: ChartLongPress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideLongPressView), name: NSNotification.Name(rawValue: ChartLongPressDismiss), object: nil)
    }
    
    // 长按分时线图，显示摘要信息
    func showLongPressView(_ notification: Notification) {
        if currentChartView is TimeLineView {
            let dataDictionary = (notification as NSNotification).userInfo as! [String: AnyObject]
            let timeLineEntity = dataDictionary["timeLineEntity"] as! HSTimeLineModel
            stockBriefView?.isHidden = false
            stockBriefView?.configureView(timeLineEntity)
        } else {
            let dataDictionary = (notification as NSNotification).userInfo as! [String: AnyObject]
            let preClose = dataDictionary["preClose"] as! CGFloat
            let klineModel = dataDictionary["kLineEntity"] as! HSKLineModel
            lineBriefView?.configureView(preClose, kLineModel: klineModel)
            lineBriefView?.isHidden = false
        }
    }

    func hideLongPressView(_ notification: Notification) {
        stockBriefView?.isHidden = true
        lineBriefView?.isHidden = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { coordinator in
            self.segmentMenu.updateIndicatorFrame()
        }, completion: { coordinator in
            self.updateChartFrames()
        })
    }
}


// MARK: - SegmentMenuDelegate

extension ViewController: SegmentMenuDelegate {
    func updateChartFrames() {
        currentChartView?.frame = containerView.bounds
    }
    
    func menuButtonDidClick(index: Int) {
        currentChartView?.removeFromSuperview()
        let type = self.chartTypes[index]
        let chartView = getChart(for: type, with: containerView.bounds)
        currentChartView = chartView
        
        if chartView.superview == nil {
            self.view.addSubview(chartView)
            chartView.translatesAutoresizingMaskIntoConstraints = false
            
            chartView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
            chartView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
            chartView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
            chartView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        }
    }
}

extension ViewController {
    func getChart(for type: HSChartType, with frame: CGRect) -> UIView {
        
        switch type.chartType {
        case .timeLine:
            let stockBasicInfo = HSStockBasicInfoModel.getStockBasicInfoModel(getJsonDataFromFile("SZ300033"))
            let modelArray = HSTimeLineModel.getTimeLineModelArray(getJsonDataFromFile(type.filename), type: type, basicInfo: stockBasicInfo)
            let timeLineView = TimeLineView(frame: frame)
            timeLineView.dataT = modelArray
            timeLineView.isUserInteractionEnabled = true
            
            return timeLineView
        case .candlesticks:
            let data = HSKLineModel.getKLineModelArray(getJsonDataFromFile(type.filename))
            let stockChartView = StockChartView(frame: frame, data: data, type: type.chartType)
            return stockChartView
        }
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        return JSON(data: jsonContent)
    }
}


