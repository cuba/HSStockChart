//
//  DrawLayer.swift
//  StockChartExample
//
//  Created by Hanson on 2017/2/28.
//  Copyright © 2017年 hanson. All rights reserved.
//

import Foundation
import UIKit

public protocol DrawLayer {
    var theme: ChartTheme { get }
    
    func drawLine(lineWidth: CGFloat, startPoint: CGPoint, endPoint: CGPoint, strokeColor: CGColor, fillColor: CGColor, isDash: Bool, isAnimated: Bool) -> CAShapeLayer
    func drawTextLayer(frame: CGRect, text: String, foregroundColor: CGColor, backgroundColor: CGColor, fontSize: CGFloat) -> CATextLayer
    func getFrameSize(for text: String) -> CGSize
}

extension DrawLayer {
    public var theme: ChartTheme {
        return ChartTheme()
    }
    
    public func drawLine(lineWidth: CGFloat, startPoint: CGPoint, endPoint: CGPoint, strokeColor: CGColor, fillColor: CGColor, isDash: Bool = false, isAnimated: Bool = false) -> CAShapeLayer {
        
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = lineWidth
        lineLayer.strokeColor = strokeColor
        lineLayer.fillColor = fillColor
        
        if isDash {
            lineLayer.lineDashPattern = [3, 3]
        }
        
        if isAnimated {
            let path = CABasicAnimation(keyPath: "strokeEnd")
            path.duration = 1.0
            path.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            path.fromValue = 0.0
            path.toValue = 1.0
            lineLayer.add(path, forKey: "strokeEndAnimation")
            lineLayer.strokeEnd = 1.0
        }
        
        return lineLayer
    }
    
    public func drawLabelLayer(frame: CGRect, text: String, theme: ChartTheme) -> CATextLayer {
        return drawTextLayer(frame: frame, text: text, foregroundColor: theme.labelColor.cgColor, backgroundColor: theme.labelBackgroundColor.cgColor, fontSize: 10)
    }
    
    public func drawCrossLineLabelLayer(frame: CGRect, text: String, theme: ChartTheme) -> CATextLayer {
        return drawTextLayer(frame: frame, text: text, foregroundColor: theme.labelColor.cgColor, backgroundColor: theme.crossLinelabelBackgroundColor.cgColor, fontSize: 10)
    }
    
    public func drawTextLayer(frame: CGRect, text: String, foregroundColor: CGColor, backgroundColor: CGColor = UIColor.clear.cgColor, fontSize: CGFloat = 10) -> CATextLayer {
        
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.fontSize = fontSize
        textLayer.cornerRadius = frame.size.height / 2
        textLayer.foregroundColor = foregroundColor
        textLayer.backgroundColor = backgroundColor
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        textLayer.contentsScale = UIScreen.main.scale
        
        return textLayer
    }
    
    public func getFrameSize(for text: String) -> CGSize {
        let font = theme.baseFont
        let attributes = [NSAttributedString.Key.font: font]
        let size = text.size(withAttributes: attributes)
        return CGSize(width: size.width + 8, height: size.height)
    }
}
