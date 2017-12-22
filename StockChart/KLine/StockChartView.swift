//
//  StockChartView.swift
//  HSStockChart
//
//  Created by Hanson on 2017/2/16.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

public typealias CandlestickRange = CountableRange<Int>

public protocol StockChartViewDelegate {
    func performedLongPressGesture(atIndex index: Int)
    func releasedLongPressGesture()
    func performedTap(atIndex index: Int)
    func showedDetails(atIndex index: Int)
    func hidDetails()
}

public protocol StockChartViewDataSource {
    func numberOfCandlesticks() -> Int
    func numberOfLines() -> Int
    func candlestick(atIndex index: Int) -> Candlestick
    func line(atIndex index: Int) -> Line
    
    func format(volume: CGFloat, forElement: Element) -> String
    func format(price: CGFloat, forElement: Element) -> String
    func format(date: Date, forElement: Element) -> String
    func color(forLineAtIndex index: Int) -> CGColor
    
    func bounds(inVisibleRange CandlestickRange: CountableRange<Int>, maximumVisibleCandles: Int) -> GraphBounds
}

open class StockChartView: UIView {
    private var upperFrameLayer: CAShapeLayer?
    private var volumeFrameLayer: CAShapeLayer?
    
    private var scrollView: UIScrollView!
    private var candlesticsView: CandlesticsView!
    private var axisView: AxisView!
    
    private var widthOfKLineView: CGFloat = 0
    private var enableKVO: Bool = true
    private var lineViewWidth: CGFloat = 0.0
    
    private var upperChartHeight: CGFloat {
        return theme.upperChartHeightScale * self.frame.height
    }
    
    private var lowerChartHeight: CGFloat {
        return self.frame.height * (1 - theme.upperChartHeightScale) - theme.xAxisHeight
    }
    
    private var lowerChartTop: CGFloat {
        return upperChartHeight + theme.xAxisHeight
    }
    
    private var contentOffsetX: CGFloat {
        return scrollView.contentOffset.x
    }
    
    private var renderWidth: CGFloat {
        return frame.width
    }
    
    private var candleTotalWidth: CGFloat {
        return (theme.candleWidth + theme.candleGap)
    }
    
    fileprivate var visibleCandles: Int {
        let visibleCandles = Int(self.frame.width / candleTotalWidth)
        return visibleCandles
    }
    
    private var visibleStartIndex: Int {
        return candlesticsView.visibleRange.lowerBound
    }
    
    private var visibleEndIndex: Int {
        return candlesticsView.visibleRange.upperBound
    }
    
    private func candleXPosition(forIndex index: Int) -> CGFloat {
        return  max(0, contentOffsetX) + CGFloat(index - visibleStartIndex) * (theme.candleWidth + theme.candleGap)
    }
    
    private func lineXPosition(forIndex index: Int) -> CGFloat {
        let leftPosition = candleXPosition(forIndex: index)
        return leftPosition + theme.candleWidth / 2.0
    }
    
    public var theme = ChartTheme() {
        didSet {
            candlesticsView?.theme = theme
        }
    }
    
    public var dataSource: StockChartViewDataSource?
    public var delegate: StockChartViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        
        if scrollView.frame != bounds {
            scrollView.frame = bounds
            axisView.frame = bounds
            reloadData()
            drawFrameLayer()
        }
    }
    
    func setupView() {
        backgroundColor = UIColor.white
        
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        addSubview(scrollView)
        
        // Setup candlesticks view
        candlesticsView = CandlesticsView(frame: frame)
        candlesticsView.dataSource = self
        candlesticsView.theme = theme
        scrollView.addSubview(candlesticsView)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        candlesticsView.addGestureRecognizer(longPressGesture)
        candlesticsView.addGestureRecognizer(tapGesture)
        
        axisView = AxisView(frame: bounds, theme: theme)
        addSubview(axisView)
    }
    
    public convenience init(frame: CGRect, theme: ChartTheme) {
        self.init(frame: frame)
        self.theme = theme
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIScrollView.contentOffset) && enableKVO {
            // If our CandlestickRange changed, we need to redraw the candlesticks
            let updatedBounds = updateBounds()
            let updatedVisibleRange = updateVisibleRange()
            
            if updatedBounds || updatedVisibleRange {
                candlesticsView.drawLayers()
            }
            
            if axisView.showingCrossView {
                self.hideDetails()
            }
        }
    }
    
    private func createVisibleRange() -> CandlestickRange {
        let contentOffsetX = scrollView.contentOffset.x
        
        let minimumScrollViewOffset = max(0, contentOffsetX)
        let leftCandleCount = Int(minimumScrollViewOffset / (theme.candleWidth + theme.candleGap))
        let visibleStartIndex = min(leftCandleCount, dataSource?.numberOfCandlesticks() ?? 0)
        let numberOfCandles = self.numberOfCandles()
        let visibleCandles = self.visibleCandles
        let visibleEndIndex = max(visibleStartIndex, min(visibleStartIndex + visibleCandles, numberOfCandles - 1))
        let candlestickRange = visibleStartIndex..<visibleEndIndex
        return candlestickRange
    }
    
    public func didInsertData() {
        let isScrolledToEnd = scrollView.isScrolled(to: .right)
        let showingCrossView = axisView.showingCrossView
        
        if !showingCrossView {
            let _ = updateBounds()
        }
        
        let _ = updateVisibleRange()
        updateCandlesticksFrame()
        
        if isScrolledToEnd && !showingCrossView {
            scrollView.scrollTo(direction: .right, animated: true)
        }
    }
    
    public func reloadData() {
        // if the data is reloaded, we need to update the visibleRange
        // and redraw the candlesticks and update the candlesticks frame
        let _ = updateBounds()
        let _ = updateVisibleRange()
        updateCandlesticksFrame()
        candlesticsView.drawLayers()
        scrollView.scrollTo(direction: .right, animated: false)
    }
    
    public func showDetails(forCandleAtIndex index: Int) {
        guard let dataSource = self.dataSource else { return }
        let candlestick = dataSource.candlestick(atIndex: index)
        let candleOffset = CGFloat(index) * (theme.candleWidth + theme.candleGap) + (theme.candleWidth / 2.0)
        let lineXPosition = candleOffset - scrollView.contentOffset.x
        
        // Y positions
        let priceYPosition = candlesticsView.candleCoordinate(atIndex: index, for: self).closePoint.y
        let volumeYPosition = candlesticsView.volumeCoordinate(atIndex: index, for: self).highPoint.y
        
        let pricePoint =  CGPoint(x: lineXPosition, y: priceYPosition)
        let volumePoint = CGPoint(x: lineXPosition, y: volumeYPosition)
        
        let priceString = dataSource.format(price: candlestick.close, forElement: .overlay)
        let volumeString = dataSource.format(volume: candlestick.volume, forElement: .overlay)
        let dateString = dataSource.format(date: candlestick.date, forElement: .overlay)
        
        axisView.drawCrossLine(pricePoint: pricePoint, volumePoint: volumePoint, priceString: priceString, dateString: dateString, volumeString: volumeString, index: index)
        delegate?.showedDetails(atIndex: index)
    }
    
    public func hideDetails() {
        delegate?.hidDetails()
        axisView.removeCrossLine()
    }
    
    @objc func handleTapGesture(_ recognizer: UILongPressGestureRecognizer) {
        guard let dataSource = self.dataSource else { return }
        
        let point = recognizer.location(in: candlesticsView)
        let candleIndex = min(dataSource.numberOfCandlesticks(), max(0, Int(point.x / (theme.candleWidth + theme.candleGap))))
        delegate?.performedTap(atIndex: candleIndex)
    }
    
    @objc func handleLongPressGestureAction(_ recognizer: UILongPressGestureRecognizer) {
        guard let dataSource = self.dataSource else { return }
        
        if recognizer.state == .began || recognizer.state == .changed {
            let point = recognizer.location(in: candlesticsView)
            let candleIndex = min(dataSource.numberOfCandlesticks() - 1, max(0, Int(point.x / (theme.candleWidth + theme.candleGap))))
            delegate?.performedLongPressGesture(atIndex: candleIndex)
        }
        
        if recognizer.state == .ended {
            delegate?.releasedLongPressGesture()
        }
    }
    
    private func updateCandlesticksFrame() {
        candlesticsView.updateFrame(fromParentFrame: bounds)
        scrollView.contentSize = candlesticsView.frame.size
    }
    
    private func updateBounds() -> Bool {
        let graphBounds = dataSource?.bounds(inVisibleRange: candlesticsView.visibleRange, maximumVisibleCandles: visibleCandles) ?? GraphBounds()
        guard candlesticsView.graphBounds != graphBounds else { return false }
        candlesticsView.graphBounds = graphBounds
        
        // Update the axis view
        guard let dataSource = self.dataSource else { return true }
        let maxPrice = graphBounds.price.max
        let minPrice = graphBounds.price.min
        let midPrice = ((maxPrice - minPrice) / 2) + minPrice
        let maxVolume = graphBounds.volume.max
        
        let maxPriceString = dataSource.format(price: maxPrice, forElement: .axis)
        let minPriceString = dataSource.format(price: minPrice, forElement: .axis)
        let midPriceString = dataSource.format(price: midPrice, forElement: .axis)
        let maxVolumeString = dataSource.format(volume: maxVolume, forElement: .axis)
        
        axisView.configureAxis(maxPrice: maxPriceString, minPrice: minPriceString, midPrice: midPriceString, maxVolume: maxVolumeString)
        
        return true
    }
    
    private func updateVisibleRange() -> Bool {
        let previousVisibleRange = candlesticsView.visibleRange
        candlesticsView.visibleRange = self.createVisibleRange()
        return previousVisibleRange == candlesticsView.visibleRange
    }
    
    private func drawFrameLayer() {
        self.upperFrameLayer?.removeFromSuperlayer()
        self.volumeFrameLayer?.removeFromSuperlayer()
        
        let upperFramePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: upperChartHeight))
        
        upperFramePath.move(to: CGPoint(x: 0, y: theme.viewMinYGap))
        upperFramePath.addLine(to: CGPoint(x: frame.maxX, y: theme.viewMinYGap))
        
        upperFramePath.move(to: CGPoint(x: 0, y: upperChartHeight - theme.viewMinYGap))
        upperFramePath.addLine(to: CGPoint(x: frame.maxX, y: upperChartHeight - theme.viewMinYGap))
        
        upperFramePath.move(to: CGPoint(x: 0, y: upperChartHeight / 2.0))
        upperFramePath.addLine(to: CGPoint(x: frame.maxX, y: upperChartHeight / 2.0))
        
        let upperFrameLayer = CAShapeLayer()
        upperFrameLayer.lineWidth = theme.frameWidth
        upperFrameLayer.strokeColor = theme.borderColor.cgColor
        upperFrameLayer.fillColor = UIColor.clear.cgColor
        upperFrameLayer.path = upperFramePath.cgPath
        
        let volFramePath = UIBezierPath(rect: CGRect(x: 0, y: upperChartHeight + theme.xAxisHeight, width: frame.width, height: frame.height - upperChartHeight - theme.xAxisHeight))
        
        volFramePath.move(to: CGPoint(x: 0, y: upperChartHeight + theme.xAxisHeight + theme.volumeGap))
        volFramePath.addLine(to: CGPoint(x: frame.maxX, y: upperChartHeight + theme.xAxisHeight + theme.volumeGap))
        
        let volumeFrameLayer = CAShapeLayer()
        volumeFrameLayer.lineWidth = theme.frameWidth
        volumeFrameLayer.strokeColor = theme.borderColor.cgColor
        volumeFrameLayer.fillColor = UIColor.clear.cgColor
        volumeFrameLayer.path = volFramePath.cgPath
        
        self.layer.addSublayer(upperFrameLayer)
        self.layer.addSublayer(volumeFrameLayer)
        
        self.upperFrameLayer = upperFrameLayer
        self.volumeFrameLayer = volumeFrameLayer
    }
}

extension StockChartView: CandlesticksViewDataSource {
    
    func numberOfCandles() -> Int {
        return dataSource?.numberOfCandlesticks() ?? 0
    }
    
    func numberOfLines() -> Int {
        return dataSource?.numberOfLines() ?? 0
    }
    
    func candle(atIndex index: Int) -> Candle {
        guard let candlestick = dataSource?.candlestick(atIndex: index) else {
            return Candle(open: 0, close: 0, high: 0, low: 0)
        }
        
        return Candle(open: candlestick.open, close: candlestick.close, high: candlestick.high, low: candlestick.low)
    }
    
    func label(atIndex index: Int) -> String {
        guard let dataSource = self.dataSource else { return "" }
        let candlestick = dataSource.candlestick(atIndex: index)
        return dataSource.format(date: candlestick.date, forElement: .axis)
    }
    
    func volume(atIndex index: Int) -> CGFloat {
        let candlestick = dataSource?.candlestick(atIndex: index)
        return candlestick?.volume ?? 0
    }
    
    func values(forLineAtIndex lineIndex: Int) -> [CGFloat] {
        let line = dataSource?.line(atIndex: lineIndex)
        return line?.values ?? []
    }
    
    func color(forLineAtIndex lineIndex: Int) -> CGColor {
        return dataSource?.color(forLineAtIndex: lineIndex) ?? UIColor.white.cgColor
    }
}
