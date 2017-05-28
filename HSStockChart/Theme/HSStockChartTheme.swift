//
//  HSStockChartTheme.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/28.
//  Copyright © 2017年 hanson. All rights reserved.
//

import Foundation
import UIKit

public struct HSStockChartTheme  {
    
    public var upperChartHeightScale: CGFloat = 0.7 // 70% 的空间是上部分的走势图
    
    public var lineWidth: CGFloat = 1
    public var frameWidth: CGFloat = 0.25
    
    public var xAxisHeitht: CGFloat = 30
    public var viewMinYGap: CGFloat = 15
    public var volumeGap: CGFloat = 10
    
    public var candleWidth: CGFloat = 5
    public var candleGap: CGFloat = 2
    public var candleMinHeight: CGFloat = 0.5
    public var candleMaxWidth: CGFloat = 30
    public var candleMinWidth: CGFloat = 2
    
    public var ma5Color = UIColor(netHex: 0xe8de85, alpha: 1)
    public var ma10Color = UIColor(netHex: 0x6fa8bb, alpha: 1)
    public var ma20Color = UIColor(netHex: 0xdf8fc6, alpha: 1)
    public var borderColor = UIColor(rgba: "#e4e4e4")
    public var crossLineColor = UIColor(rgba: "#546679")
    public var textColor = UIColor(rgba: "#8695a6")
    public var riseColor = UIColor(rgba: "#1dbf60") // green
    public var fallColor = UIColor(rgba: "#f24957") // red
    public var priceLineColor = UIColor(rgba: "#0095ff")
    public var avgLineColor = UIColor(rgba: "#ffc004")
    public var fillColor = UIColor(rgba: "#e3efff")
    
    public var baseFont = UIFont.systemFont(ofSize: 10)
    
    public func getTextSize(text: String) -> CGSize {
        let size = text.size(attributes: [NSFontAttributeName: baseFont])
        let width = ceil(size.width) + 5
        let height = ceil(size.height)
        
        return CGSize(width: width, height: height)
    }
}
