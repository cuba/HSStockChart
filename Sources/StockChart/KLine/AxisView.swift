//
//  HSHighLight.swift
//  StockChartExample
//
//  Created by Hanson on 2017/2/16.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

open class AxisView: UIView, DrawLayer {
    private var priceLabelLayer = CATextLayer()
    private var volumeLabelLayer = CATextLayer()
    private var maxPriceLabelLayer = CATextLayer()
    private var midPriceLabelLayer = CATextLayer()
    private var minPriceLabelLayer = CATextLayer()
    private var maxVolumeLabelLayer = CATextLayer()
    private var crossLineLayer = CAShapeLayer()
    private var timeMarkLayer = CAShapeLayer()
    private(set) var showingCrossView = false
    
    // Bounds
    private(set) var graphBounds = GraphBounds()
    private(set) var maxPrice = ""
    private(set) var minPrice = ""
    private(set) var midPrice = ""
    private(set) var maxVolume = ""
    
    private var upperChartHeight: CGFloat {
        return theme.upperChartHeightScale * self.frame.height
    }
    
    private var lowerChartTop: CGFloat {
        return upperChartHeight + theme.xAxisHeight
    }
    
    public var theme: ChartTheme = ChartTheme()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawMarkLayers()
    }
    
    public convenience init(frame: CGRect, theme: ChartTheme) {
        self.init(frame: frame)
        self.theme = theme
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if !showingCrossView {
            clearMarkLayers()
            drawMarkLayers()
        }
    }
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != self else { return nil }
        return view
    }
    
    open func configureAxis(maxPrice: String, minPrice: String, midPrice: String, maxVolume: String) {
        self.maxPrice = maxPrice
        self.minPrice = minPrice
        self.midPrice = midPrice
        self.maxVolume = maxVolume
        
        maxPriceLabelLayer.string = maxPrice
        minPriceLabelLayer.string = minPrice
        midPriceLabelLayer.string = midPrice
        maxVolumeLabelLayer.string = maxVolume
        
        updateFrames()
    }
    
    private func updateFrames() {
        maxPriceLabelLayer.frame = createFrame(for: maxPrice, inFrame: frame, y: theme.viewMinYGap, isLeft: false)
        midPriceLabelLayer.frame = createFrame(for: midPrice, inFrame: frame, y: upperChartHeight / 2, isLeft: false)
        minPriceLabelLayer.frame = createFrame(for: minPrice, inFrame: frame, y: upperChartHeight - theme.viewMinYGap, isLeft: false)
        maxVolumeLabelLayer.frame = createFrame(for: maxVolume, inFrame: frame, y: lowerChartTop + theme.volumeGap, isLeft: false)
    }
    
//    func timeMarkLayer(coordinates: [CandleCoordinate]) {
//        var lastDate: Date?
//        timeMarkLayer.sublayers?.removeAll()
//        
//        for (index, position) in coordinates.enumerated() {
//            let date = visibleCandlesticks[index].date
//            
//            if lastDate == nil {
//                lastDate = date
//            }
//            
//            guard position.isDrawAxis else { break }
//            let timeMark = drawXAxisTimeMark(xPosition: position.highPoint.x, date: date, index: index)
//            timeMarkLayer.addSublayer(timeMark)
//            
//            lastDate = date
//        }
//        
//        self.layer.addSublayer(timeMarkLayer)
//    }
    
    
    private func clearMarkLayers() {
        self.layer.sublayers?.removeAll()
    }
    
    public func drawMarkLayers() {
        // Title Labels
        priceLabelLayer = getYAxisMarkLayer(frame: frame, text: theme.priceLabel, y: theme.viewMinYGap, isLeft: true)
        volumeLabelLayer = getYAxisMarkLayer(frame: frame, text: theme.volumeLabel, y: lowerChartTop + theme.volumeGap, isLeft: true)
        
        // Price Labels
        maxPriceLabelLayer = getYAxisMarkLayer(frame: frame, text: maxPrice, y: theme.viewMinYGap, isLeft: false)
        midPriceLabelLayer = getYAxisMarkLayer(frame: frame, text: midPrice, y: upperChartHeight / 2, isLeft: false)
        minPriceLabelLayer = getYAxisMarkLayer(frame: frame, text: minPrice, y: upperChartHeight - theme.viewMinYGap, isLeft: false)
        
        // Volume Labels
        maxVolumeLabelLayer = getYAxisMarkLayer(frame: frame, text: maxVolume, y: lowerChartTop + theme.volumeGap, isLeft: false)
        
        self.layer.addSublayer(priceLabelLayer)
        self.layer.addSublayer(volumeLabelLayer)
        self.layer.addSublayer(maxPriceLabelLayer)
        self.layer.addSublayer(minPriceLabelLayer)
        self.layer.addSublayer(midPriceLabelLayer)
        self.layer.addSublayer(maxVolumeLabelLayer)
    }
    
    func drawCrossLine(pricePoint: CGPoint, volumePoint: CGPoint, priceString: String, dateString: String, volumeString: String, index: Int) {
        crossLineLayer.removeFromSuperlayer()
        crossLineLayer = getCrossLineLayer(frame: frame, pricePoint: pricePoint, volumePoint: volumePoint, priceString: priceString, dateString: dateString, volumeString: volumeString, index: index)
        self.layer.addSublayer(crossLineLayer)
        showingCrossView = true
    }
    
    func removeCrossLine() {
        self.crossLineLayer.removeFromSuperlayer()
        showingCrossView = false
    }
    
    func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, priceString: String, dateString: String, volumeString: String, index: Int) -> CAShapeLayer {
        let highlightLayer = CAShapeLayer()
        
        highlightLayer.addSublayer(createCrosshairs(for: frame, pricePoint: pricePoint, volumePoint: volumePoint))
        highlightLayer.addSublayer(createPriceTextLayer(for: frame, pricePoint: pricePoint, priceString: priceString, index: index))
        highlightLayer.addSublayer(createDateTextLayer(for: frame, pricePoint: pricePoint, dateString: dateString, index: index))
        highlightLayer.addSublayer(createVolumeTextLayer(for: frame, volumePoint: volumePoint, volumeString: volumeString, index: index))
        
        return highlightLayer
    }
    
    func createCrosshairs(for frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint) -> CAShapeLayer {
        let linePath = UIBezierPath()
        
        // Price Vertical Line
        linePath.move(to: CGPoint(x: pricePoint.x, y: 0))
        linePath.addLine(to: CGPoint(x: pricePoint.x, y: frame.height))
        
        // Price Horizontal Line
        linePath.move(to: CGPoint(x: frame.minX, y: pricePoint.y))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: pricePoint.y))
        
        // Volume Horizontal Line
        linePath.move(to: CGPoint(x: frame.minX, y: volumePoint.y))
        linePath.addLine(to: CGPoint(x: frame.maxX, y: volumePoint.y))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = theme.lineWidth
        shapeLayer.strokeColor = theme.crossLineColor.cgColor
        shapeLayer.fillColor = theme.crossLineColor.cgColor
        shapeLayer.path = linePath.cgPath
        return shapeLayer
    }
    
    func createPriceTextLayer(for frame: CGRect, pricePoint: CGPoint, priceString: String, index: Int) -> CATextLayer {
        let priceMarkSize = getFrameSize(for: priceString)
        var labelX: CGFloat = frame.minX
        let labelY: CGFloat = pricePoint.y - priceMarkSize.height / 2.0
        
        // Right align if we are to the left of the screen
        if pricePoint.x < frame.width / 2 {
            labelX = frame.maxX - priceMarkSize.width
        }
        
        let origin = CGPoint(x: labelX, y: labelY)
        let frame = CGRect(origin: origin, size: priceMarkSize)
        
        let shapeLayer = drawCrossLineLabelLayer(frame: frame, text: priceString, theme: theme)
        return shapeLayer
    }
    
    func createVolumeTextLayer(for frame: CGRect, volumePoint: CGPoint, volumeString: String, index: Int) -> CATextLayer {
        let volMarkSize = getFrameSize(for: volumeString)
        let maxY = frame.maxY - volMarkSize.height
        var labelX = frame.minX
        var labelY = volumePoint.y - volMarkSize.height / 2.0
        labelY = min(maxY, labelY)
        
        // Right align if we are to the left of the screen
        if volumePoint.x <= frame.width / 2 {
            labelX = frame.maxX - volMarkSize.width
        }
        
        return drawCrossLineLabelLayer(frame: CGRect(x: labelX, y: labelY, width: volMarkSize.width, height: volMarkSize.height), text: volumeString, theme: theme)
    }
    
    func createDateTextLayer(for frame: CGRect, pricePoint: CGPoint, dateString: String, index: Int) -> CATextLayer {
        let bottomMarkSize = getFrameSize(for: dateString)
        
        // Date Label
        let maxX = frame.maxX - bottomMarkSize.width
        var labelX = pricePoint.x - bottomMarkSize.width / 2.0
        let labelY = frame.height * theme.upperChartHeightScale
        
        if labelX > maxX {
            labelX = frame.maxX - bottomMarkSize.width
        } else if labelX < frame.minX {
            labelX = frame.minX
        }
        
        return drawCrossLineLabelLayer(frame: CGRect(x: labelX, y: labelY, width: bottomMarkSize.width, height: bottomMarkSize.height), text: dateString, theme: theme)
    }
    
    private func getYAxisMarkLayer(frame: CGRect, text: String, y: CGFloat, isLeft: Bool) -> CATextLayer {
        let frame = createFrame(for: text, inFrame: frame, y: y, isLeft: isLeft)
        let yMarkLayer = drawLabelLayer(frame: frame, text: text, theme: theme)
        
        return yMarkLayer
    }
    
    func createFrame(for text: String, inFrame frame: CGRect, y: CGFloat, isLeft: Bool) -> CGRect {
        let size = getFrameSize(for: text)
        var positionX: CGFloat = theme.labelEdgeInsets
        let positionY: CGFloat = y - size.height / 2
        
        if !isLeft {
            positionX = frame.width - size.width - theme.labelEdgeInsets
        }
        
        let origin = CGPoint(x: positionX, y: positionY)
        return CGRect(origin: origin, size: size)
    }
}
