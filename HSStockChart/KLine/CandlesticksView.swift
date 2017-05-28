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

open class CandlesticsView: UIView, HSDrawLayerProtocol {
    public var theme = HSStockChartTheme()
    
    private(set) var positionModels: [GraphCoordinate] = []
    private var klineModels: [Candlestick] = []
    private var kLineViewTotalWidth: CGFloat = 0
    private var showContentWidth: CGFloat = 0
    
    private var selectedIndex: Int = 0
    
    private var priceUnit: CGFloat = 0.1
    private var volumeUnit: CGFloat = 0
    private var renderRect: CGRect = CGRect.zero
    
    // Layers
    private var candleChartLayer = CAShapeLayer()
    private var volumeLayer = CAShapeLayer()
    private var ma5LineLayer = CAShapeLayer()
    private var ma10LineLayer = CAShapeLayer()
    private var ma20LineLayer = CAShapeLayer()
    private var xAxisTimeMarkLayer = CAShapeLayer()
    
    // Bounds
    private(set) var maxPrice: CGFloat = 0
    private(set) var minPrice: CGFloat = 0
    private(set) var maxVolume: CGFloat = 0
    private(set) var maxMA: CGFloat = 0
    private(set) var minMA: CGFloat = 0
    private(set) var maxMACD: CGFloat = 0
    
    // Accessable Properties
    var contentOffsetX: CGFloat = 0
    var renderWidth: CGFloat = 0
    var data: [Candlestick] = []
    var type = ChartType.timeLine
    
    private var upperChartHeight: CGFloat {
        return theme.upperChartHeightScale * self.frame.height
    }
    
    private var lowerChartHeight: CGFloat {
        return self.frame.height * (1 - theme.upperChartHeightScale) - theme.xAxisHeight
    }
    
    var startIndex: Int {
        let scrollViewOffsetX = max(0, contentOffsetX)
        let leftCandleCount = Int(abs(scrollViewOffsetX) / (theme.candleWidth + theme.candleGap))
        
        if leftCandleCount > data.count {
            return data.count - 1
        } else if leftCandleCount == 0 {
            return leftCandleCount
        } else {
            return leftCandleCount + 1
        }
    }
    
    var startX: CGFloat {
        return max(0, contentOffsetX)
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
        calcMaxAndMinData()
        convertToPositionModel(data: data)

        clearLayer()
        drawxAxisTimeMarkLayer()
        drawCandleChartLayer(array: positionModels)
        drawVolumeLayer(array: positionModels)
        drawMALayer(coordinates: positionModels)
    }
    
    fileprivate func calcMaxAndMinData() {
        guard data.count > 0 else { return }
        
        self.maxPrice = CGFloat.leastNormalMagnitude
        self.minPrice = CGFloat.greatestFiniteMagnitude
        self.maxVolume = CGFloat.leastNormalMagnitude
        self.maxMA = CGFloat.leastNormalMagnitude
        self.minMA = CGFloat.greatestFiniteMagnitude
        self.maxMACD = CGFloat.leastNormalMagnitude
        let startIndex = self.startIndex
        
        let count = (startIndex + numberOfCandles + 1) > data.count ? data.count : (startIndex + numberOfCandles + 1)
        
        if startIndex < count {
            for i in startIndex ..< count {
                let entity = data[i]
                self.maxPrice = self.maxPrice > entity.high ? self.maxPrice : entity.high
                self.minPrice = self.minPrice < entity.low ? self.minPrice : entity.low
                
                self.maxVolume = self.maxVolume > entity.volume ? self.maxVolume : entity.volume
                
                let tempMAMax = max(entity.ma5, entity.ma10, entity.ma20)
                self.maxMA = self.maxMA > tempMAMax ? self.maxMA : tempMAMax
                
                let tempMAMin = min(entity.ma5, entity.ma10, entity.ma20)
                self.minMA = self.minMA < tempMAMin ? self.minMA : tempMAMin
                
                let tempMax = max(abs(entity.diff), abs(entity.dea), abs(entity.macd))
                self.maxMACD = tempMax > self.maxMACD ? tempMax : self.maxMACD
            }
        }
        
        self.maxPrice = self.maxPrice > self.maxMA ? self.maxPrice : self.maxMA
        self.minPrice = self.minPrice < self.minMA ? self.minPrice : self.minMA
    }
    
    
    fileprivate func convertToPositionModel(data: [Candlestick]) {
        self.positionModels.removeAll()
        self.klineModels.removeAll()
        
        let axisGap = numberOfCandles / 3
        let gap = theme.viewMinYGap
        let minY = gap
        let maxDiff = self.maxPrice - self.minPrice
        
        if maxDiff > 0, maxVolume > 0 {
            priceUnit = (upperChartHeight - 2 * minY) / maxDiff
            volumeUnit = (lowerChartHeight - theme.volumeGap) / self.maxVolume
        }
        
        let count = (startIndex + numberOfCandles + 1) > data.count ? data.count : (startIndex + numberOfCandles + 1)
        if startIndex < count {
            for index in startIndex ..< count {
                let model = data[index]
                let leftPosition = startX + CGFloat(index - startIndex) * (theme.candleWidth + theme.candleGap)
                let xPosition = leftPosition + theme.candleWidth / 2.0
                
                let highPoint = CGPoint(x: xPosition, y: (maxPrice - model.high) * priceUnit + minY)
                let lowPoint = CGPoint(x: xPosition, y: (maxPrice - model.low) * priceUnit + minY)
                
                let ma5Point = CGPoint(x: xPosition, y: (maxPrice - model.ma5) * priceUnit + minY)
                let ma10Point = CGPoint(x: xPosition, y: (maxPrice - model.ma10) * priceUnit + minY)
                let ma20Point = CGPoint(x: xPosition, y: (maxPrice - model.ma20) * priceUnit + minY)
                
                let openPointY = (maxPrice - model.open) * priceUnit + minY
                let closePointY = (maxPrice - model.close) * priceUnit + minY
                var fillCandleColor = UIColor.black
                var candleRect = CGRect.zero
                
                let volume = (model.volume - 0) * volumeUnit
                let volumeStartPoint = CGPoint(x: xPosition, y: self.frame.height - volume)
                let volumeEndPoint = CGPoint(x: xPosition, y: self.frame.height)
                
                if(openPointY > closePointY) {
                    fillCandleColor = theme.riseColor
                    candleRect = CGRect(x: leftPosition, y: closePointY, width: theme.candleWidth, height: openPointY - closePointY)
                    
                } else if(openPointY < closePointY) {
                    fillCandleColor = theme.fallColor
                    candleRect = CGRect(x: leftPosition, y: openPointY, width: theme.candleWidth, height: closePointY - openPointY)
                    
                } else {
                    candleRect = CGRect(x: leftPosition, y: closePointY, width: theme.candleWidth, height: theme.candleMinHeight)
                    if(index > 0) {
                        let preKLineModel = data[index - 1]
                        if(model.open > preKLineModel.close) {
                            fillCandleColor = theme.riseColor
                        } else {
                            fillCandleColor = theme.fallColor
                        }
                    }
                }
                
                let positionModel = GraphCoordinate()
                positionModel.highPoint = highPoint
                positionModel.lowPoint = lowPoint
                positionModel.closeY = closePointY
                positionModel.ma5Point = ma5Point
                positionModel.ma10Point = ma10Point
                positionModel.ma20Point = ma20Point
                positionModel.volumeStartPoint = volumeStartPoint
                positionModel.volumeEndPoint = volumeEndPoint
                positionModel.candleFillColor = fillCandleColor
                positionModel.candleRect = candleRect
                if index % axisGap == 0 {
                    positionModel.isDrawAxis = true
                }
                self.positionModels.append(positionModel)
                self.klineModels.append(model)
            }
        }
    }
    
    func drawCandleChartLayer(array: [GraphCoordinate]) {
        candleChartLayer.sublayers?.removeAll()
        
        for object in array.enumerated() {
            let candleLayer = getCandleLayer(model: object.element)
            candleChartLayer.addSublayer(candleLayer)
        }
        
        self.layer.addSublayer(candleChartLayer)
    }
    
    func drawVolumeLayer(array: [GraphCoordinate]) {
        volumeLayer.sublayers?.removeAll()
        for object in array.enumerated() {
            let model = object.element
            let volLayer = drawLine(lineWidth: theme.candleWidth, startPoint: model.volumeStartPoint, endPoint: model.volumeEndPoint, strokeColor: model.candleFillColor, fillColor: model.candleFillColor)
            volumeLayer.addSublayer(volLayer)
        }
        self.layer.addSublayer(volumeLayer)
    }
    
    func drawMALayer(coordinates: [GraphCoordinate]) {
        ma5LineLayer = createMALayer(for: coordinates.map({ $0.ma5Point }), color: theme.ma5Color.cgColor)
        ma10LineLayer = createMALayer(for: coordinates.map({ $0.ma10Point }), color: theme.ma10Color.cgColor)
        ma20LineLayer = createMALayer(for: coordinates.map({ $0.ma20Point }), color: theme.ma20Color.cgColor)
        
        self.layer.addSublayer(ma5LineLayer)
        self.layer.addSublayer(ma10LineLayer)
        self.layer.addSublayer(ma20LineLayer)
    }
    
    private func createMALayer(for coordinates: [CGPoint], color: CGColor) -> CAShapeLayer {
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
    
    func drawxAxisTimeMarkLayer() {
        var lastDate: Date?
        xAxisTimeMarkLayer.sublayers?.removeAll()
        
        for (index, position) in positionModels.enumerated() {
            guard let date = klineModels[index].date else { break }
            
            if lastDate == nil {
                lastDate = date
            }
            
            guard position.isDrawAxis else { break }
            
            switch type {
            case .timeLine:
                xAxisTimeMarkLayer.addSublayer(drawXAxisTimeMark(xPosition: position.highPoint.x, dateString: date.toString(withFormat: "yyyy-MM")!))
            case .candlesticks:
                xAxisTimeMarkLayer.addSublayer(drawXAxisTimeMark(xPosition: position.highPoint.x, dateString: date.toString(withFormat: "MM-dd")!))
            }
            
            lastDate = date
        }
        
        self.layer.addSublayer(xAxisTimeMarkLayer)
    }
    
    func clearLayer() {
        ma5LineLayer.removeFromSuperlayer()
        ma10LineLayer.removeFromSuperlayer()
        ma20LineLayer.removeFromSuperlayer()
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
    
    func drawXAxisTimeMark(xPosition: CGFloat, dateString: String) -> CAShapeLayer {
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
        
        let textSize = theme.getTextSize(text: dateString)
        
        var labelX: CGFloat = 0
        var labelY: CGFloat = 0
        let maxX = frame.maxX - textSize.width
        labelX = xPosition - textSize.width / 2.0
        labelY = self.frame.height * theme.upperChartHeightScale
        
        if labelX > maxX {
            labelX = maxX
        } else if labelX < frame.minX {
            labelX = frame.minX
        }
        
        let timeLayer = drawTextLayer(frame: CGRect(x: labelX, y: labelY, width: textSize.width, height: textSize.height),text: dateString, foregroundColor: theme.textColor)
        
        let shaperLayer = CAShapeLayer()
        shaperLayer.addSublayer(lineLayer)
        shaperLayer.addSublayer(timeLayer)
        
        return shaperLayer
    }
}
