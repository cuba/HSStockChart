//
//  ChartTheme.swift
//  StockChartExample
//
//  Created by Hanson on 2017/2/28.
//  Copyright © 2017年 hanson. All rights reserved.
//

import Foundation
import UIKit

open class ChartTheme  {
    public var labelEdgeInsets: CGFloat = 5.0
    public var upperChartHeightScale: CGFloat = 0.7
    
    public var lineWidth: CGFloat = 2
    public var frameWidth: CGFloat = 0.25
    
    public var xAxisHeight: CGFloat = 30
    public var viewMinYGap: CGFloat = 15
    public var volumeGap: CGFloat = 1
    
    public var candleWidth: CGFloat = 3
    public var candleGap: CGFloat = 2
    public var candleMinHeight: CGFloat = 0.5
    
    public var crossLineColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.black
        }
    }()
    
    public var labelColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.secondaryLabel
        } else {
            return UIColor(hexString: "#8695a6")!
        }
    }()
    
    public var labelBackgroundColor: UIColor = {
        return UIColor.clear
    }()
    
    public var crossLinelabelBackgroundColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return UIColor.white
        }
    }()
    
    public var riseColor: UIColor = {
        if #available(iOS 11.0, *) {
            if let color = UIColor(named: "stock.rise") {
                return color
            } else {
                return UIColor(hexString: "#1dbf56")!
            }
        } else {
            return UIColor(hexString: "#1dbf56")!
        }
    }()
        
    public var fallColor: UIColor = {
        if #available(iOS 11.0, *) {
            if let color = UIColor(named: "stock.fall") {
                return color
            } else {
                return UIColor(hexString: "#f24857")!
            }
        } else {
            return UIColor(hexString: "#1dbf56")!
        }
    }()
    
    public var fillColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor(hexString: "#e3efff")!
        }
    }()
    
    public var baseFont = UIFont.systemFont(ofSize: 10)
    public var priceLabel = "Label.Price".localized
    public var volumeLabel = "Label.Volume".localized
    
    var widthOfCandlePlusGap: CGFloat {
        return candleWidth + candleGap
    }
    
    public init() { }
}
