//
//  DrawLayer.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/28.
//  Copyright © 2017年 hanson. All rights reserved.
//

import Foundation
import UIKit

public protocol DrawLayer {
    var theme: ChartTheme { get }
    
    func drawLine(lineWidth: CGFloat, startPoint: CGPoint, endPoint: CGPoint, strokeColor: UIColor, fillColor: UIColor, isDash: Bool, isAnimated: Bool) -> CAShapeLayer
    
    func drawTextLayer(frame: CGRect, text: String, foregroundColor: UIColor, backgroundColor: UIColor, fontSize: CGFloat) -> CATextLayer
}

extension DrawLayer {
    public var theme: ChartTheme {
        return ChartTheme()
    }
    
    public func drawLine(lineWidth: CGFloat, startPoint: CGPoint, endPoint: CGPoint, strokeColor: UIColor, fillColor: UIColor, isDash: Bool = false, isAnimated: Bool = false) -> CAShapeLayer {
        
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = lineWidth
        lineLayer.strokeColor = strokeColor.cgColor
        lineLayer.fillColor = fillColor.cgColor
        
        if isDash {
            lineLayer.lineDashPattern = [3, 3]
        }
        
        if isAnimated {
            let path = CABasicAnimation(keyPath: "strokeEnd")
            path.duration = 1.0
            path.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            path.fromValue = 0.0
            path.toValue = 1.0
            lineLayer.add(path, forKey: "strokeEndAnimation")
            lineLayer.strokeEnd = 1.0
        }
        
        return lineLayer
    }
    
    public func drawTextLayer(frame: CGRect, text: String, foregroundColor: UIColor, backgroundColor: UIColor = UIColor.clear, fontSize: CGFloat = 10) -> CATextLayer {
        
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.string = text
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = foregroundColor.cgColor
        textLayer.backgroundColor = backgroundColor.cgColor
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.contentsScale = UIScreen.main.scale
        
        return textLayer
    }
    
    
    func getYAxisMarkLayer(frame: CGRect, text: String, y: CGFloat, isLeft: Bool, element: ChartTheme.Element) -> CATextLayer {
        let frame = createFrame(for: text, inFrame: frame, y: y, isLeft: isLeft, element: element)
        let yMarkLayer = drawTextLayer(frame: frame, text: text, foregroundColor: theme.textColor)
        
        return yMarkLayer
    }
    
    func createFrame(for text: String, inFrame frame: CGRect, y: CGFloat, isLeft: Bool, element: ChartTheme.Element) -> CGRect {
        let size = theme.getFrameSize(for: element, text: text)
        var positionX: CGFloat = theme.labelEdgeInsets
        let positionY: CGFloat = y - size.height / 2
        
        if !isLeft {
            positionX = frame.width - size.width - theme.labelEdgeInsets
        }
        
        let origin = CGPoint(x: positionX, y: positionY)
        return CGRect(origin: origin, size: size)
    }
}
