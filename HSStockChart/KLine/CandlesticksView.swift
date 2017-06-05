//
//  HSKLineNew.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2017/2/16.
//  Copyright © 2017年 hanson. All rights reserved.
//

import UIKit

public enum ChartType {
    case timeLine
    case candlesticks
}

public struct Bounds {
    var min: CGFloat
    var max: CGFloat
    
    var difference: CGFloat {
        return max - min
    }
    
    init(min: CGFloat, max: CGFloat) {
        self.min = min
        self.max = max
    }
}

public struct GraphBounds {
    var price: Bounds
    var volume: Bounds
    var range: CountableClosedRange<Int>
    
    init(price: Bounds, volume: Bounds, range: CountableClosedRange<Int>) {
        self.price = price
        self.volume = volume
        self.range = range
    }
    
    init() {
        self.init(price: Bounds(min: 0, max: 0), volume: Bounds(min: 0, max: 0), range: 0...0)
    }
}

open class CandlesticsView: UIView, DrawLayer {
    public var theme = ChartTheme()
    
    private(set) var positionModels: [GraphCoordinate] = []
    private var klineModels: GraphData = GraphData()
    private var kLineViewTotalWidth: CGFloat = 0
    private var showContentWidth: CGFloat = 0
    
    private var selectedIndex: Int = 0
    
    private var priceUnit: CGFloat = 0.1
    private var volumeUnit: CGFloat = 0
    private var renderRect: CGRect = CGRect.zero
    
    // Layers
    private var candleChartLayer = CAShapeLayer()
    private var volumeLayer = CAShapeLayer()
    private var lineLayers: [CAShapeLayer] = []
    private var xAxisTimeMarkLayer = CAShapeLayer()
    
    // Bounds
    private(set) var graphBounds = GraphBounds()
    
    // Accessable Properties
    var contentOffsetX: CGFloat = 0
    var renderWidth: CGFloat = 0
    var data: GraphData = GraphData()
    
    private var upperChartHeight: CGFloat {
        return theme.upperChartHeightScale * self.frame.height
    }
    
    private var lowerChartHeight: CGFloat {
        return self.frame.height * (1 - theme.upperChartHeightScale) - theme.xAxisHeight
    }
    
    var visibleStartIndex: Int {
        let scrollViewOffsetX = max(0, contentOffsetX)
        let leftCandleCount = Int(scrollViewOffsetX / (theme.candleWidth + theme.candleGap))
        return min(leftCandleCount, data.candlesticks.count)
    }
    
    var visibleEndIndex: Int {
        return min(visibleStartIndex + numberOfCandles, data.candlesticks.count - 1)
    }
    
    var visibleRange: CountableClosedRange<Int> {
        return visibleStartIndex...visibleEndIndex
    }
    
    private var numberOfCandles: Int {
        return Int((renderWidth - theme.candleWidth) / ( theme.candleWidth + theme.candleGap))
    }
    
    
    // MARK: - Initialize
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Drawing Function
    
    func drawKLineView() {
        self.graphBounds = calculateBounds()
        convertToPositionModel(data: data)

        clearLayer()
        drawXAxisTimeMarkLayer()
        drawCandleChartLayer(coordinates: positionModels)
        drawVolumeLayer(coordinates: positionModels)
        drawLineLayers(coordinates: positionModels)
    }
    
    fileprivate func calculateBounds() -> GraphBounds {
        let visibleRange = self.visibleRange
        
        guard visibleRange.startIndex < visibleRange.endIndex else {
            return GraphBounds()
        }
        
        var maxPrice = CGFloat.leastNormalMagnitude
        var minPrice = CGFloat.greatestFiniteMagnitude
        var maxVolume = CGFloat.leastNormalMagnitude
        var minVolume = CGFloat.greatestFiniteMagnitude
        
        for index in visibleRange {
            let entity = data.candlesticks[index]
            maxPrice = max(maxPrice, entity.high)
            minPrice = min(minPrice, entity.low)
            
            maxVolume = max(maxVolume, entity.volume)
            minVolume = min(minVolume, entity.volume)
            
            for line in data.lines {
                guard index < line.values.count else { break }
                let value = line.values[index]
                maxPrice = max(maxPrice, value)
                minPrice = min(minPrice, value)
            }
        }
        
        return GraphBounds(
            price: Bounds(min: minPrice, max: maxPrice),
            volume: Bounds(min: minVolume, max: maxVolume),
            range: visibleRange
        )
    }
    
    fileprivate func convertToPositionModel(data: GraphData) {
        self.positionModels.removeAll()
        self.klineModels = GraphData()
        
        let bounds = self.graphBounds
        let axisGap = numberOfCandles / 10
        let gap = theme.viewMinYGap
        let minY = gap
        let startX = max(0, contentOffsetX)
        
        if bounds.price.difference > 0, bounds.volume.max > 0 {
            priceUnit = (upperChartHeight - 2 * minY) / bounds.price.difference
            volumeUnit = (lowerChartHeight - theme.volumeGap) / bounds.volume.max
        }
        
        var candlesticks: [Candlestick] = []
        
        for index in visibleRange {
            // Price
            let candlestick = data.candlesticks[index]
            let leftPosition = startX + CGFloat(index - visibleStartIndex) * (theme.candleWidth + theme.candleGap)
            let xPosition = leftPosition + theme.candleWidth / 2.0
            
            let highPoint = CGPoint(x: xPosition, y: (bounds.price.max - candlestick.high) * priceUnit + minY)
            let lowPoint = CGPoint(x: xPosition, y: (bounds.price.max - candlestick.low) * priceUnit + minY)
            
            let openPointY = (bounds.price.max - candlestick.open) * priceUnit + minY
            let closePointY = (bounds.price.max - candlestick.close) * priceUnit + minY
            var fillCandleColor = UIColor.black
            
            // Volume
            let volume = candlestick.volume * volumeUnit
            let volumeStartPoint = CGPoint(x: xPosition, y: self.frame.height - volume)
            let volumeEndPoint = CGPoint(x: xPosition, y: self.frame.height)
            let height = max(abs(openPointY - closePointY), theme.candleMinHeight)
            let candleRect = CGRect(x: leftPosition, y: min(closePointY, openPointY), width: theme.candleWidth, height: height)
            
            if openPointY > closePointY {
                fillCandleColor = theme.riseColor
            } else if openPointY < closePointY {
                fillCandleColor = theme.fallColor
            } else if index > 0 {
                if(candlestick.open > data.candlesticks[index - 1].close) {
                    fillCandleColor = theme.riseColor
                } else {
                    fillCandleColor = theme.fallColor
                }
            }
            
            let positionModel = GraphCoordinate()
            positionModel.highPoint = highPoint
            positionModel.lowPoint = lowPoint
            positionModel.closeY = closePointY
            positionModel.volumeStartPoint = volumeStartPoint
            positionModel.volumeEndPoint = volumeEndPoint
            positionModel.candleFillColor = fillCandleColor
            positionModel.candleRect = candleRect
            positionModel.isDrawAxis = index % axisGap == 0
            
            self.positionModels.append(positionModel)
            candlesticks.append(candlestick)
            self.klineModels = GraphData(candlesticks: candlesticks, lines: [])
        }
    }
    
    func drawCandleChartLayer(coordinates: [GraphCoordinate]) {
        candleChartLayer.sublayers?.removeAll()
        
        for coordinate in coordinates {
            let candleLayer = getCandleLayer(model: coordinate)
            candleChartLayer.addSublayer(candleLayer)
        }
        
        self.layer.addSublayer(candleChartLayer)
    }
    
    func drawVolumeLayer(coordinates: [GraphCoordinate]) {
        volumeLayer.sublayers?.removeAll()
        
        for model in coordinates {
            let volLayer = drawLine(lineWidth: theme.candleWidth, startPoint: model.volumeStartPoint, endPoint: model.volumeEndPoint, strokeColor: model.candleFillColor, fillColor: model.candleFillColor)
            volumeLayer.addSublayer(volLayer)
        }
        
        self.layer.addSublayer(volumeLayer)
    }
    
    func drawLineLayers(coordinates: [GraphCoordinate]) {
        lineLayers.forEach({ $0.sublayers?.removeAll() })
    }
    
    private func createLineLayer(for coordinates: [CGPoint], color: CGColor) -> CAShapeLayer {
        let linePath = UIBezierPath()
        
        for index in 1 ..< coordinates.count {
            let previousPoint = coordinates[index - 1]
            let point = coordinates[index]
            linePath.move(to: previousPoint)
            linePath.addLine(to: point)
        }
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.strokeColor = color
        lineLayer.fillColor = UIColor.clear.cgColor
        return lineLayer
    }
    
    func drawXAxisTimeMarkLayer() {
        var lastDate: Date?
        xAxisTimeMarkLayer.sublayers?.removeAll()
        
        for (index, position) in positionModels.enumerated() {
            let date = klineModels.candlesticks[index].date
            
            if lastDate == nil {
                lastDate = date
            }
            
            guard position.isDrawAxis else { break }
            let timeMark = drawXAxisTimeMark(xPosition: position.highPoint.x, date: date, index: index)
            xAxisTimeMarkLayer.addSublayer(timeMark)
            
            lastDate = date
        }
        
        self.layer.addSublayer(xAxisTimeMarkLayer)
    }
    
    func clearLayer() {
        candleChartLayer.removeFromSuperlayer()
        volumeLayer.removeFromSuperlayer()
        xAxisTimeMarkLayer.removeFromSuperlayer()
    }
    
    fileprivate func getCandleLayer(model: GraphCoordinate) -> CAShapeLayer {
        let linePath = UIBezierPath(rect: model.candleRect)
        linePath.move(to: model.lowPoint)
        linePath.addLine(to: model.highPoint)
        
        let klayer = CAShapeLayer()
        klayer.path = linePath.cgPath
        klayer.strokeColor = model.candleFillColor.cgColor
        klayer.fillColor = model.candleFillColor.cgColor
        
        return klayer
    }
    
    func drawXAxisTimeMark(xPosition: CGFloat, date: Date, index: Int) -> CAShapeLayer {
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: xPosition, y: 0))
        linePath.addLine(to: CGPoint(x: xPosition,  y: self.frame.height * theme.upperChartHeightScale))
        linePath.move(to: CGPoint(x: xPosition, y: self.frame.height * theme.upperChartHeightScale + theme.xAxisHeight))
        linePath.addLine(to: CGPoint(x: xPosition, y: self.frame.height))
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = 0.25
        lineLayer.strokeColor = theme.borderColor.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        
        let text = theme.format(date: date, for: .dateLabel(index: index))
        let textFrameSize = theme.getFrameSize(for: .dateLabel(index: index), text: text)
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        let maxX = frame.maxX - textFrameSize.width
        labelX = xPosition - textFrameSize.width / 2.0
        labelY = self.frame.height * theme.upperChartHeightScale
        
        if labelX > maxX {
            labelX = maxX
        } else if labelX < frame.minX {
            labelX = frame.minX
        }
        
        let timeLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: textFrameSize.width, height: textFrameSize.height), text: text, foregroundColor: theme.textColor)
        
        let shaperLayer = CAShapeLayer()
        shaperLayer.addSublayer(lineLayer)
        shaperLayer.addSublayer(timeLayer)
        
        return shaperLayer
    }
}
