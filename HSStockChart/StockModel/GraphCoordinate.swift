//
//  GraphCoordinate.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/1/20.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

typealias LineCoordinate = (key: String, point: CGPoint)

class GraphCoordinate {
    var openPoint: CGPoint = .zero
    var closePoint: CGPoint = .zero
    var highPoint: CGPoint = .zero
    var lowPoint: CGPoint = .zero
    
    var volumeStartPoint: CGPoint = .zero
    var volumeEndPoint: CGPoint = .zero
    
    var candleFillColor: UIColor = UIColor.black
    var candleRect: CGRect = CGRect.zero
    
    var lineCoordinates: [LineCoordinate] = []
    
    var closeY: CGFloat = 0
    
    var isDrawAxis: Bool = false
}

class CandleCoordinate {
    var openPoint: CGPoint = .zero
    var closePoint: CGPoint = .zero
    var highPoint: CGPoint = .zero
    var lowPoint: CGPoint = .zero
    
    var volumeStartPoint: CGPoint = .zero
    var volumeEndPoint: CGPoint = .zero
    
    var candleFillColor: UIColor = UIColor.black
    var candleRect: CGRect = CGRect.zero
    
    var closeY: CGFloat = 0
    
    var isDrawAxis: Bool = false
}
