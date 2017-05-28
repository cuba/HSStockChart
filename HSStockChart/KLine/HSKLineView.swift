//
//  StockChartView.swift
//  HSStockChart
//
//  Created by Hanson on 2017/2/16.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

open class StockChartView: UIView {
    private var scrollView: UIScrollView!
    private var kLine: CandlesticsView!
    private var upFrontView: HSKLineUpFrontView!
    
    private var type: ChartType!
    private var theme = HSStockChartTheme()
    
    private var widthOfKLineView: CGFloat = 0
    private var enableKVO: Bool = true
    private var lineViewWidth: CGFloat = 0.0
    
    fileprivate var data: [HSKLineModel] = []
    fileprivate var allData: [HSKLineModel] = []
    
    private var upperChartHeight: CGFloat {
        return theme.upperChartHeightScale * self.frame.height
    }
    
    private var lowerChartTop: CGFloat {
        return upperChartHeight + theme.xAxisHeitht
    }
    
    public init(frame: CGRect, data: [HSKLineModel], type: ChartType) {
        super.init(frame: frame)
        self.allData = data
        backgroundColor = UIColor.white
        
        drawFrameLayer()
        
        scrollView = UIScrollView(frame: bounds)
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.delegate = self
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
        addSubview(scrollView)
        
        kLine = CandlesticsView()
        kLine.type = type
        scrollView.addSubview(kLine)
        
        upFrontView = HSKLineUpFrontView(frame: bounds)
        addSubview(upFrontView)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        kLine.addGestureRecognizer(longPressGesture)
        
        let tmpdata = Array(allData[allData.count-70..<allData.count])
        self.configureView(data: tmpdata)
        self.configureView(data: data)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIScrollView.contentOffset) && enableKVO {
            kLine.contentOffsetX = scrollView.contentOffset.x
            kLine.renderWidth = scrollView.frame.width
            kLine.drawKLineView()
            
            upFrontView.configureAxis(max: kLine.maxPrice, min: kLine.minPrice, maxVol: kLine.maxVolume)
        }
    }
    
    func configureView(data: [HSKLineModel]) {
        self.data = data
        kLine.data = data
        let count: CGFloat = CGFloat(data.count)
        
        lineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        if lineViewWidth < self.frame.width {
            lineViewWidth = self.frame.width
        } else {
            lineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        }
        
        kLine.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: lineViewWidth, height: scrollView.frame.height)
        
        var contentOffsetX: CGFloat = 0
        
        if scrollView.contentSize.width > 0 {
            contentOffsetX = lineViewWidth - scrollView.contentSize.width
        } else {
            // 首次加载，将 kLine 的右边和scrollview的右边对齐
            contentOffsetX = kLine.frame.width - scrollView.frame.width
        }
        
        scrollView.contentSize = CGSize(width: lineViewWidth, height: self.frame.height)
        scrollView.contentOffset = CGPoint(x: contentOffsetX, y: 0)
        kLine.contentOffsetX = scrollView.contentOffset.x

    }
    
    func updateKlineViewWidth() {
        let count: CGFloat = CGFloat(kLine.data.count)
        // 总长度
        lineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        if lineViewWidth < self.frame.width {
            lineViewWidth = self.frame.width
        } else {
            lineViewWidth = count * theme.candleWidth + (count + 1) * theme.candleGap
        }
        
        kLine.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: lineViewWidth, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: lineViewWidth, height: self.frame.height)
    }
    
    func drawFrameLayer() {
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
        
        let volFramePath = UIBezierPath(rect: CGRect(x: 0, y: upperChartHeight + theme.xAxisHeitht, width: frame.width, height: frame.height - upperChartHeight - theme.xAxisHeitht))
        
        volFramePath.move(to: CGPoint(x: 0, y: upperChartHeight + theme.xAxisHeitht + theme.volumeGap))
        volFramePath.addLine(to: CGPoint(x: frame.maxX, y: upperChartHeight + theme.xAxisHeitht + theme.volumeGap))
        
        let volumeFrameLayer = CAShapeLayer()
        volumeFrameLayer.lineWidth = theme.frameWidth
        volumeFrameLayer.strokeColor = theme.borderColor.cgColor
        volumeFrameLayer.fillColor = UIColor.clear.cgColor
        volumeFrameLayer.path = volFramePath.cgPath
        
        self.layer.addSublayer(upperFrameLayer)
        self.layer.addSublayer(volumeFrameLayer)
    }
    
    // 长按操作
    func handleLongPressGestureAction(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            let point = recognizer.location(in: kLine)
            let highLightIndex = Int(point.x / (theme.candleWidth + theme.candleGap))
            guard highLightIndex < kLine.data.count else { return }
            let index = highLightIndex - kLine.startIndex
            guard index < kLine.positionModels.count else { return }
            
            let entity = kLine.data[highLightIndex]
            let left = kLine.startX + CGFloat(highLightIndex - kLine.startIndex) * (self.theme.candleWidth + theme.candleGap) - scrollView.contentOffset.x
            let centerX = left + theme.candleWidth / 2.0
            let highLightVolume = kLine.positionModels[index].volumeStartPoint.y
            let highLightClose = kLine.positionModels[index].closeY
            
            upFrontView.drawCrossLine(pricePoint: CGPoint(x: centerX, y: highLightClose), volumePoint: CGPoint(x: centerX, y: highLightVolume), model: entity)
            
            let lastData = highLightIndex > 0 ? kLine.data[highLightIndex - 1] : kLine.data[0]
            let userInfo: [AnyHashable: Any]? = ["preClose" : lastData.close, "kLineEntity" : kLine.data[highLightIndex]]
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: ChartLongPress), object: self, userInfo: userInfo)
        }
        
        if recognizer.state == .ended {
            upFrontView.removeCrossLine()
            NotificationCenter.default.post(name: Notification.Name(rawValue: ChartLongPressDismiss), object: self)
        }
    }
}

extension StockChartView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x < 0 && data.count < allData.count) {
            self.configureView(data: allData)
        }
    }
}
