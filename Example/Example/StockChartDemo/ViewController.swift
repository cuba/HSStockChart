//
//  ViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/15.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import StockChart
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
    fileprivate var defaultDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    var containerView: UIView!
    var segmentMenu: SegmentMenu!
    var lineBriefView: HSKLineBriefView!
    var currentChartView: UIView?
    var graphData: GraphData?
    
    var chartTypes: [HSChartType] = [.kLineForDay, .kLineForWeek, .kLineForMonth]
    
    var menuTitles: [String] {
        return self.chartTypes.map { $0.title }
    }
    
    
    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        graphData = data
        
        let stockChartView = StockChartView(frame: frame)
        stockChartView.configureView(data: data)
        stockChartView.dataSource = self
        stockChartView.delegate = self
        stockChartView.reloadData()
        return stockChartView
    }
    
    func getJsonDataFromFile(_ fileName: String) -> JSON {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        let jsonContent = content.data(using: String.Encoding.utf8)!
        return JSON(data: jsonContent)
    }
}

extension ViewController: StockChartViewDataSource {
    func format(volume: CGFloat, forElement: Element) -> String {
        return String(format: "%.0f", volume)
    }
    
    func format(price: CGFloat, forElement: Element) -> String {
        return String(format: "%.3f", price)
    }
    
    func format(date: Date, forElement: Element) -> String {
        return defaultDateFormatter.string(from: date)
    }
    
    func lineColor(forKey key: String) -> CGColor {
        switch key {
        case "ma5":
            return UIColor(hex: 0xe8de85, alpha: 1).cgColor
        default:
            return UIColor(hex: 0xe8de85, alpha: 1).cgColor
        }
    }
    
    func bounds(inVisibleRange visibleRange: CountableClosedRange<Int>, maximumVisibleCandles: Int) -> GraphBounds {
        guard let graphData = self.graphData else { return GraphBounds() }
        let buffer = maximumVisibleCandles / 2
        let startIndex = max(0, visibleRange.lowerBound - buffer)
        let endIndex = max(startIndex, min(graphData.count - 1, visibleRange.upperBound + buffer))
        
        var maxPrice = CGFloat.leastNormalMagnitude
        var minPrice = CGFloat.greatestFiniteMagnitude
        var maxVolume = CGFloat.leastNormalMagnitude
        var minVolume = CGFloat.greatestFiniteMagnitude
        let range = startIndex...endIndex
        
        for index in range {
            let entity = graphData.candlesticks[index]
            maxPrice = max(maxPrice, entity.high)
            minPrice = min(minPrice, entity.low)
            
            maxVolume = max(maxVolume, entity.volume)
            minVolume = min(minVolume, entity.volume)
            
            for (_, values) in graphData.lines {
                guard index < values.count else { break }
                let value = values[index]
                maxPrice = max(maxPrice, value)
                minPrice = min(minPrice, value)
            }
        }
        
        return GraphBounds(
            price: Bounds(min: minPrice, max: maxPrice),
            volume: Bounds(min: minVolume, max: maxVolume),
            range: range
        )
    }
}

extension ViewController: StockChartViewDelegate {
    func performedLongPressGesture(atIndex index: Int) {
        guard let candlestick = graphData?.candlesticks[index] else { return }
        lineBriefView?.configureView(candlestick: candlestick)
        lineBriefView?.isHidden = false
    }
    
    func releasedLongPressGesture() {
        lineBriefView?.isHidden = true
    }
    
    func performedTap(atIndex index: Int) {
        guard let candlestick = graphData?.candlesticks[index] else { return }
        lineBriefView?.configureView(candlestick: candlestick)
        lineBriefView?.isHidden = false
    }
}


