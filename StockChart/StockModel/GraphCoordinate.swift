//
//  GraphCoordinate.swift
//  StockChartExample
//
//  Created by Hanson on 2017/1/20.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

class GraphCoordinates {
    var candleCoordinates: [CandleCoordinate] = []
    var lines: [String: LineCoordinates] = [:]
}

struct CandleCoordinate {
    var openPoint: CGPoint = .zero
    var closePoint: CGPoint = .zero
    var highPoint: CGPoint = .zero
    var lowPoint: CGPoint = .zero
    
    var frame: CGRect = CGRect.zero
    var fillColor: CGColor = UIColor.black.cgColor
    
    var isDrawAxis: Bool = false
}

struct VolumeCoordinate {
    var highPoint: CGPoint = .zero
    var lowPoint: CGPoint = .zero
    var fillColor: CGColor = UIColor.black.cgColor
}

typealias Coordinates = [CGPoint]

struct LineCoordinates {
    var points: Coordinates = []
    var color: CGColor
    
    init(points: Coordinates, color: CGColor) {
        self.points = points
        self.color = color
    }
}
