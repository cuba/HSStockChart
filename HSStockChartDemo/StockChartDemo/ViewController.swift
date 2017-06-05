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
    case kLineForDay
    case kLineForWeek
    case kLineForMonth
    
    var title: String {
        switch self {
        case .kLineForDay:          return "Day"
        case .kLineForWeek:         return "Week"
        case .kLineForMonth:        return "Month"
        }
    }
    
    var filename: String {
        switch self {
        case .kLineForDay:          return "kLineForDay"
        case .kLineForWeek:         return "kLineForWeek"
        case .kLineForMonth:        return "kLineForMonth"
        }
    }
}

class ViewController: UIViewController {
    var containerView: UIView!
    var segmentMenu: SegmentMenu!
    var lineBriefView: HSKLineBriefView!
    var currentChartView: UIView?
    
    var chartTypes: [HSChartType] = [.kLineForDay, .kLineForWeek, .kLineForMonth]
    
    var menuTitles: [String] {
        return self.chartTypes.map { $0.title }
    }
    
    
    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationsObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentMenu.selectButton(at: 0, animated: false)
        setChart(at: segmentMenu.currentIndex)
    }
    
    // MARK: -
    
    override func loadView() {
        super.loadView()
        segmentMenu = SegmentMenu()
        lineBriefView = HSKLineBriefView()
        containerView = UIView()
        segmentMenu.setButtons(from: menuTitles)
        
        containerView.backgroundColor = UIColor.white
        lineBriefView?.isHidden = true
        segmentMenu.delegate = self
        
        self.view.addSubview(segmentMenu)
        self.view.addSubview(lineBriefView)
        self.view.addSubview(containerView)
        
        segmentMenu.translatesAutoresizingMaskIntoConstraints = false
        lineBriefView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        segmentMenu.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 0).isActive = true
        segmentMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        segmentMenu.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        segmentMenu.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
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
        let dataDictionary = (notification as NSNotification).userInfo as! [String: AnyObject]
        let preClose = dataDictionary["preClose"] as! CGFloat
        let klineModel = dataDictionary["kLineEntity"] as! Candlestick
        lineBriefView?.configureView(preClose, kLineModel: klineModel)
        lineBriefView?.isHidden = false
    }

    func hideLongPressView(_ notification: Notification) {
        lineBriefView?.isHidden = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { coordinator in
            self.segmentMenu.updateIndicatorFrame()
            self.removeCurrentChart()
        }, completion: { coordinator in
            self.setChart(at: self.segmentMenu.currentIndex)
        })
    }
}


// MARK: - SegmentMenuDelegate

extension ViewController: SegmentMenuDelegate {
    func menuButtonDidClick(index: Int) {
        setChart(at: index)
    }
    
    func setChart(at index: Int) {
        currentChartView?.removeFromSuperview()
        let type = self.chartTypes[index]
        let chartView = getChart(for: type, with: containerView.bounds)
        currentChartView = chartView
        chartView.alpha = 0
        
        fadeIn(view: chartView, duration: 0.5)
        
        if chartView.superview == nil {
            self.view.addSubview(chartView)
            chartView.translatesAutoresizingMaskIntoConstraints = false
            
            chartView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
            chartView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
            chartView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
            chartView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        }
    }
    
    func removeCurrentChart() {
        if let view = currentChartView {
            fadeOut(view: view, duration: 0.5)
        }
    }
    
    func fadeOut(view: UIView, duration: CGFloat) {
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            view.alpha = 0
        }, completion: { status in
            view.removeFromSuperview()
        })
    }
    
    func fadeIn(view: UIView, duration: CGFloat) {
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            view.alpha = 1
        }, completion: nil)
    }
}

extension ViewController {
    func getChart(for type: HSChartType, with frame: CGRect) -> UIView {
        let data = Candlestick.getKLineModelArray(getJsonDataFromFile(type.filename))
        let stockChartView = StockChartView(frame: frame, data: data)
        return stockChartView
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        return JSON(data: jsonContent)
    }
}


