//
//  HSHighLight.swift
//  HSStockChartDemo
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
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != self else { return nil }
        return view
    }
    
    open func configureAxis(max: CGFloat, min: CGFloat, maxVol: CGFloat) {
        let maxPriceStr = theme.format(value: max, for: .priceLabel)
        let minPriceStr = theme.format(value: min, for: .priceLabel)
        let midPriceStr = theme.format(value: (max + min) / 2, for: .priceLabel)
        let maxVolStr = theme.format(value: maxVol, for: .volumeLabel)
        maxPriceLabelLayer.string = maxPriceStr
        minPriceLabelLayer.string = minPriceStr
        midPriceLabelLayer.string = midPriceStr
        maxVolumeLabelLayer.string = maxVolStr
        
        // We need to update the frames
        maxPriceLabelLayer.frame = createFrame(for: maxPriceStr, inFrame: frame, y: theme.viewMinYGap, isLeft: false, element: .priceLabel)
        minPriceLabelLayer.frame = createFrame(for: minPriceStr, inFrame: frame, y: upperChartHeight / 2, isLeft: false, element: .priceLabel)
        midPriceLabelLayer.frame = createFrame(for: midPriceStr, inFrame: frame, y: upperChartHeight - theme.viewMinYGap, isLeft: false, element: .priceLabel)
        maxVolumeLabelLayer.frame = createFrame(for: maxVolStr, inFrame: frame, y: lowerChartTop + theme.volumeGap, isLeft: false, element: .priceLabel)
    }
    
    public func drawMarkLayers() {
        // Title Labels
        priceLabelLayer = getYAxisMarkLayer(frame: frame, text: theme.priceLabel, y: theme.viewMinYGap, isLeft: true, element: .titleLabel)
        volumeLabelLayer = getYAxisMarkLayer(frame: frame, text: theme.volumeLabel, y: lowerChartTop + theme.volumeGap, isLeft: true, element: .titleLabel)
        
        // Price Labels
        maxPriceLabelLayer = getYAxisMarkLayer(frame: frame, text: "0.00", y: theme.viewMinYGap, isLeft: false, element: .priceLabel)
        midPriceLabelLayer = getYAxisMarkLayer(frame: frame, text: "0.00", y: upperChartHeight / 2, isLeft: false, element: .priceLabel)
        minPriceLabelLayer = getYAxisMarkLayer(frame: frame, text: "0.00", y: upperChartHeight - theme.viewMinYGap, isLeft: false, element: .priceLabel)
        
        // Volume Labels
        maxVolumeLabelLayer = getYAxisMarkLayer(frame: frame, text: "0.00", y: lowerChartTop + theme.volumeGap, isLeft: false, element: .volumeLabel)
        
        self.layer.addSublayer(priceLabelLayer)
        self.layer.addSublayer(volumeLabelLayer)
        self.layer.addSublayer(maxPriceLabelLayer)
        self.layer.addSublayer(minPriceLabelLayer)
        self.layer.addSublayer(midPriceLabelLayer)
        self.layer.addSublayer(maxVolumeLabelLayer)
    }
    
    func drawCrossLine(pricePoint: CGPoint, volumePoint: CGPoint, model: Model, index: Int) {
        crossLineLayer.removeFromSuperlayer()
        crossLineLayer = getCrossLineLayer(frame: frame, pricePoint: pricePoint, volumePoint: volumePoint, model: model, index: index)
        self.layer.addSublayer(crossLineLayer)
    }
    
    func removeCrossLine() {
        self.crossLineLayer.removeFromSuperlayer()
    }
    
    func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, model: Model, index: Int) -> CAShapeLayer {
        let highlightLayer = CAShapeLayer()
        
        let priceString = theme.format(value: model.price, for: .priceLabel)
        let dateString = theme.format(date: model.date, for: .dateLabel(index: index))
        let volumeString = theme.format(value: model.volume, for: .volumeLabel)
        
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
        let priceMarkSize = theme.getFrameSize(for: .priceLabel, text: priceString)
        var labelX: CGFloat = frame.minX
        let labelY: CGFloat = pricePoint.y - priceMarkSize.height / 2.0
        
        // Right align if we are to the left of the screen
        if pricePoint.x < frame.width / 2 {
            labelX = frame.maxX - priceMarkSize.width
        }
        
        let origin = CGPoint(x: labelX, y: labelY)
        let frame = CGRect(origin: origin, size: priceMarkSize)
        
        let shapeLayer = drawTextLayer(frame: frame, text: priceString, foregroundColor: UIColor.white, backgroundColor: theme.textColor)
        return shapeLayer
    }
    
    func createVolumeTextLayer(for frame: CGRect, volumePoint: CGPoint, volumeString: String, index: Int) -> CATextLayer {
        let volMarkSize = theme.getFrameSize(for: .volumeLabel, text: volumeString)
        let maxY = frame.maxY - volMarkSize.height
        var labelX = frame.minX
        var labelY = volumePoint.y - volMarkSize.height / 2.0
        labelY = min(maxY, labelY)
        
        // Right align if we are to the left of the screen
        if volumePoint.x <= frame.width / 2 {
            labelX = frame.maxX - volMarkSize.width
        }
        
        return drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: volMarkSize.width, height: volMarkSize.height), text: volumeString, foregroundColor: UIColor.white, backgroundColor: theme.textColor)
    }
    
    func createDateTextLayer(for frame: CGRect, pricePoint: CGPoint, dateString: String, index: Int) -> CATextLayer {
        let bottomMarkSize = theme.getFrameSize(for: .dateLabel(index: index), text: dateString)
        
        // Date Label
        let maxX = frame.maxX - bottomMarkSize.width
        var labelX = pricePoint.x - bottomMarkSize.width / 2.0
        let labelY = frame.height * theme.upperChartHeightScale
        
        if labelX > maxX {
            labelX = frame.maxX - bottomMarkSize.width
        } else if labelX < frame.minX {
            labelX = frame.minX
        }
        
        return drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: bottomMarkSize.width, height: bottomMarkSize.height), text: dateString, foregroundColor: UIColor.white, backgroundColor: theme.textColor)
    }
}
