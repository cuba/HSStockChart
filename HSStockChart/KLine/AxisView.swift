//
//  HSHighLight.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/16.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

open class AxisView: UIView, HSDrawLayerProtocol {
    private var rrText = CATextLayer()
    private var volText = CATextLayer()
    private var maxMark = CATextLayer()
    private var midMark = CATextLayer()
    private var minMark = CATextLayer()
    private var maxVolMark = CATextLayer()
    private var yAxisLayer = CAShapeLayer()
    
    private var corssLineLayer = CAShapeLayer()
    private var volMarkLayer = CATextLayer()
    private var leftMarkLayer = CATextLayer()
    private var xAxisMarkLayer = CATextLayer()
    private var yAxisMarkLayer = CATextLayer()
    
    private var upperChartHeight: CGFloat {
        return theme.upperChartHeightScale * self.frame.height
    }
    
    private var lowerChartTop: CGFloat {
        return upperChartHeight + theme.xAxisHeight
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawMarkLayers()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            // 交给下一层级的view响应事件（解决该 view 在 scrollView 上面到时scrollView无法滚动问题）
            return nil
        }
        return view
    }
    
    open func configureAxis(max: CGFloat, min: CGFloat, maxVol: CGFloat) {
        let maxPriceStr = String(format: "%0.2f", max)
        let minPriceStr = String(format: "%0.2f", min)
        let midPriceStr = String(format: "%0.2f", (max + min) / 2)
        let maxVolStr = String(format: "%0.2f", maxVol)
        maxMark.string = maxPriceStr
        minMark.string = minPriceStr
        midMark.string = midPriceStr
        maxVolMark.string = maxVolStr
    }
    
    public func drawMarkLayers() {
        // Title Labels
        rrText = getYAxisMarkLayer(frame: frame, text: "Price", y: theme.viewMinYGap, isLeft: true, element: .titleLabel)
        volText = getYAxisMarkLayer(frame: frame, text: "Trade Volume", y: lowerChartTop + theme.volumeGap, isLeft: true, element: .titleLabel)
        
        // Price Labels
        maxMark = getYAxisMarkLayer(frame: frame, text: "0.00", y: theme.viewMinYGap, isLeft: false, element: .priceLabel)
        midMark = getYAxisMarkLayer(frame: frame, text: "0.00", y: upperChartHeight / 2, isLeft: false, element: .priceLabel)
        minMark = getYAxisMarkLayer(frame: frame, text: "0.00", y: upperChartHeight - theme.viewMinYGap, isLeft: false, element: .priceLabel)
        
        // Volume Labels
        maxVolMark = getYAxisMarkLayer(frame: frame, text: "0.00", y: lowerChartTop + theme.volumeGap, isLeft: false, element: .volumeLabel)
        
        self.layer.addSublayer(rrText)
        self.layer.addSublayer(volText)
        self.layer.addSublayer(maxMark)
        self.layer.addSublayer(minMark)
        self.layer.addSublayer(midMark)
        self.layer.addSublayer(maxVolMark)
    }
    
    public func drawCrossLine(pricePoint: CGPoint, volumePoint: CGPoint, model: Model, index: Int) {
        corssLineLayer.removeFromSuperlayer()
        corssLineLayer = getCrossLineLayer(frame: frame, pricePoint: pricePoint, volumePoint: volumePoint, model: model, index: index)
        self.layer.addSublayer(corssLineLayer)
    }
    
    public func removeCrossLine() {
        self.corssLineLayer.removeFromSuperlayer()
    }
    
    public func getCrossLineLayer(frame: CGRect, pricePoint: CGPoint, volumePoint: CGPoint, model: Model, index: Int) -> CAShapeLayer {
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
        
        let labelX: CGFloat = frame.minX
        let labelY: CGFloat = pricePoint.y - priceMarkSize.height / 2.0
        
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
        labelY = max(maxY, labelY)
        
        // Volume Label
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
