//
//  ChartTheme.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/28.
//  Copyright © 2017年 hanson. All rights reserved.
//

import Foundation
import UIKit

open class ChartTheme  {
    public var labelEdgeInsets: CGFloat = 5.0
    public var upperChartHeightScale: CGFloat = 0.7
    
    public var lineWidth: CGFloat = 1
    public var frameWidth: CGFloat = 0.25
    
    public var xAxisHeight: CGFloat = 30
    public var viewMinYGap: CGFloat = 15
    public var volumeGap: CGFloat = 1
    
    public var candleWidth: CGFloat = 3
    public var candleGap: CGFloat = 2
    public var candleMinHeight: CGFloat = 0.5
    
    public var borderColor = UIColor(hexString: "#e4e4e4")!
    public var crossLineColor = UIColor(hexString: "#546679")!
    public var textColor = UIColor(hexString: "#8695a6")!
    public var riseColor = UIColor(hexString: "#1dbf60")! // green
    public var fallColor = UIColor(hexString: "#f24957")! // red
    public var priceLineColor = UIColor(hexString: "#0095ff")!
    public var fillColor = UIColor(hexString: "#e3efff")!
    public var baseFont = UIFont.systemFont(ofSize: 10)
    
    public var priceLabel = "Label.Price".localized
    public var volumeLabel = "Label.Volume".localized
    
    public init() { }
}
