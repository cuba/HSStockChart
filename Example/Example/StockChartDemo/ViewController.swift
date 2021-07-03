//
//  ViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/15.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import StockChart
import SnapKit

public enum HSChartType: Int {
    case lineForDay
    case lineForWeek
    case lineForMonth
    case empty
    
    var title: String {
        switch self {
        case .lineForDay:   return "Day"
        case .lineForWeek:  return "Week"
        case .lineForMonth: return "Month"
        case .empty:        return "Empty"
        }
    }
    
    var filename: String? {
        switch self {
        case .lineForDay:   return "lineForDay"
        case .lineForWeek:  return "lineForWeek"
        case .lineForMonth: return "lineForMonth"
        case .empty:        return nil
        }
    }
}

class ViewController: UIViewController {
    private let defaultDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    // MARK: - Views
    
    private lazy var segmentMenu: SegmentMenu = {
        return SegmentMenu()
    }()
    
    private lazy var lineBriefView: HSKLineBriefView = {
        let view = HSKLineBriefView()
        view.isHidden = true
        return view
    }()
    
    private lazy var chartView: StockChartView = {
        return StockChartView()
    }()
    
    // MARK: - Private data
    private var graphData = GraphData()
    private var timer: Timer?
    private var chartTypes: [HSChartType] = [.lineForDay, .lineForWeek, .lineForMonth, .empty]
    
    // MARK: - Computed properties
    
    private var menuTitles: [String] {
        return self.chartTypes.map { $0.title }
    }
    
    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        
        segmentMenu.delegate = self
        chartView.dataSource = self
        chartView.delegate = self
        view.backgroundColor = .secondarySystemBackground
        
        segmentMenu.setButtons(from: menuTitles)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        segmentMenu.selectButton(at: 0, animated: false)
        setChart(at: segmentMenu.currentIndex)
        
        // Start Timer
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(addRandomGraphEntry), userInfo: nil, repeats: true)
    }
    
    private func setupConstraints() {
        view.addSubview(segmentMenu)
        view.addSubview(chartView)
        view.addSubview(lineBriefView)
        
        segmentMenu.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalTo(view.readableContentGuide)
            make.height.equalTo(50)
        }
        
        lineBriefView.snp.makeConstraints { make in
            make.edges.equalTo(segmentMenu)
        }
        
        chartView.snp.makeConstraints { make in
            make.top.equalTo(segmentMenu.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { coordinator in
            self.segmentMenu.updateIndicatorFrame()
        }, completion: { coordinator in
            self.setChart(at: self.segmentMenu.currentIndex)
        })
    }
    
    @objc
    private func addRandomGraphEntry() {
        let lastEntry = graphData.candlesticks.last ?? Candlestick()
        let isIncrease = arc4random_uniform(2) > 0
        let delta = arc4random_uniform(5)
        let highDelta = arc4random_uniform(5)
        let lowDelta = arc4random_uniform(5)
        let volume = arc4random_uniform(9) * 900000
        
        var newEntry = Candlestick()
        newEntry.open = lastEntry.close
        
        if newEntry.open == 0 {
            newEntry.open = CGFloat(arc4random_uniform(100))
            newEntry.close = CGFloat(arc4random_uniform(100))
        }
        
        if isIncrease {
            newEntry.close = newEntry.open + CGFloat(delta)
            newEntry.high = newEntry.close + CGFloat(highDelta)
            newEntry.low = newEntry.open - CGFloat(lowDelta)
        } else {
            newEntry.close = newEntry.open - CGFloat(delta)
            newEntry.high = newEntry.open + CGFloat(highDelta)
            newEntry.low = newEntry.close - CGFloat(lowDelta)
        }
        
        newEntry.volume = CGFloat(volume * delta)
        print("Add entry: \(newEntry.close)")
        
        graphData.candlesticks.append(newEntry)
        chartView.didInsertData()
    }
}


// MARK: - SegmentMenuDelegate

extension ViewController: SegmentMenuDelegate {
    func menuButtonDidClick(index: Int) {
        setChart(at: index)
    }
    
    func setChart(at index: Int) {
        self.graphData = getGraphData(at: index)
        chartView.reloadData()
    }
    
    func getGraphData(at index: Int) -> GraphData {
        let type = self.chartTypes[index]
        guard let filename = type.filename else { return GraphData() }
        let data = getJsonDataFromFile(filename)
        let jsonDecoder = JSONDecoder()
        
        do {
            return try jsonDecoder.decode(GraphData.self, from: data)
        } catch {
            assertionFailure(error.localizedDescription)
            return GraphData()
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
    func getJsonDataFromFile(_ fileName: String) -> Data {
        let pathForResource = Bundle.main.path(forResource: fileName, ofType: "json")
        let content = try! String(contentsOfFile: pathForResource!, encoding: String.Encoding.utf8)
        return content.data(using: String.Encoding.utf8)!
    }
}

extension ViewController: StockChartViewDataSource {
    func numberOfCandlesticks() -> Int {
        return graphData.candlesticks.count
    }
    
    func numberOfLines() -> Int {
        return graphData.lines.count
    }
    
    func candlestick(atIndex index: Int) -> Candlestick {
        return graphData.candlesticks[index]
    }
    
    func line(atIndex index: Int) -> Line {
        let line = graphData.lines[index]
        return Line(values: line.values)
    }
    
    func format(volume: CGFloat, forElement: Element) -> String {
        return String(format: "%.0f", volume)
    }
    
    func format(price: CGFloat, forElement: Element) -> String {
        return String(format: "%.3f", price)
    }
    
    func format(date: Date, forElement: Element) -> String {
        return defaultDateFormatter.string(from: date)
    }
    
    func color(forLineAtIndex index: Int) -> CGColor {
        switch index {
        case 0:
            return UIColor(hex: 0xe8de85, alpha: 1).cgColor
        default:
            return UIColor(hex: 0xe8de85, alpha: 1).cgColor
        }
    }
    
    func bounds(inVisibleRange visibleRange: CandlestickRange, maximumVisibleCandles: Int) -> GraphBounds {
        print("GET BOUNDS")
        let buffer = maximumVisibleCandles / 2
        let startIndex = max(0, visibleRange.lowerBound - buffer)
        let endIndex = max(startIndex, min(graphData.count - 1, visibleRange.upperBound + buffer))
        
        var maxPrice = CGFloat.leastNormalMagnitude
        var minPrice = CGFloat.greatestFiniteMagnitude
        var maxVolume = CGFloat.leastNormalMagnitude
        var minVolume = CGFloat.greatestFiniteMagnitude
        let range = startIndex...endIndex
        
        guard startIndex < endIndex else {
            return GraphBounds()
        }
        
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
            price: Bounds(min: minPrice.rounded(), max: maxPrice.rounded()),
            volume: Bounds(min: minVolume, max: maxVolume)
        )
    }
}

extension ViewController: StockChartViewDelegate {
    func performedLongPressGesture(atIndex index: Int) {
        chartView.showDetails(forCandleAtIndex: index)
    }
    
    func releasedLongPressGesture() {
        chartView.hideDetails()
    }
    
    func performedTap(atIndex index: Int) {
        if lineBriefView.isHidden {
            chartView.showDetails(forCandleAtIndex: index)
        } else {
            chartView.hideDetails()
        }
    }
    
    func showedDetails(atIndex index: Int){
        let candlestick = graphData.candlesticks[index]
        lineBriefView.configureView(candlestick: candlestick)
        lineBriefView.isHidden = false
        segmentMenu.isHidden = true
    }
    
    func hidDetails() {
        lineBriefView.isHidden = true
        segmentMenu.isHidden = false
    }
}
