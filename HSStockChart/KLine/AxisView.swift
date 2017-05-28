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
    private var bottomMarkLayer = CATextLayer()
    private var yAxisMarkLayer = CATextLayer()
    
    private var upperChartHeight: CGFloat {
        return theme.upperChartHeightScale * self.frame.height
    }
    
    private var lowerChartTop: CGFloat {
        return upperChartHeight + theme.xAxisHeight
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawMarkLayer()
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
    
    public func drawMarkLayer() {
        rrText = getYAxisMarkLayer(frame: frame, text: "Price", y: theme.viewMinYGap, isLeft: true)
        volText = getYAxisMarkLayer(frame: frame, text: "Trade Volume", y: lowerChartTop + theme.volumeGap, isLeft: true)
        maxMark = getYAxisMarkLayer(frame: frame, text: "0.00", y: theme.viewMinYGap, isLeft: false)
        minMark = getYAxisMarkLayer(frame: frame, text: "0.00", y: upperChartHeight - theme.viewMinYGap, isLeft: false)
        midMark = getYAxisMarkLayer(frame: frame, text: "0.00", y: upperChartHeight / 2, isLeft: false)
        maxVolMark = getYAxisMarkLayer(frame: frame, text: "0.00", y: lowerChartTop + theme.volumeGap, isLeft: false)
        self.layer.addSublayer(rrText)
        self.layer.addSublayer(volText)
        self.layer.addSublayer(maxMark)
        self.layer.addSublayer(minMark)
        self.layer.addSublayer(midMark)
        self.layer.addSublayer(maxVolMark)
    }
    
    public func drawCrossLine(pricePoint: CGPoint, volumePoint: CGPoint, model: AnyObject?) {
        corssLineLayer.removeFromSuperlayer()
        corssLineLayer = getCrossLineLayer(frame: frame, pricePoint: pricePoint, volumePoint: volumePoint, model: model)
        self.layer.addSublayer(corssLineLayer)
    }
    
    public func removeCrossLine() {
        self.corssLineLayer.removeFromSuperlayer()
    }
}
