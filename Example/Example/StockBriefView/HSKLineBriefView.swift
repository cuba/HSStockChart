//
//  HSKLineBriefView.swift
//  StockChartExample
//
//  Created by Hanson on 16/9/8.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import StockChart

class HSKLineBriefView: UIView {
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var close: UILabel!
    @IBOutlet weak var high: UILabel!
    @IBOutlet weak var low: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var ratio: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    
    private let riseColor = UIColor(named: "stock.rise")!
    private let downColor = UIColor(named: "stock.fall")!
    
    weak var view: UIView!
    
    override func layoutSubviews() {
        view.frame = bounds
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    func setupSubviews() {
        view = instanceViewFromNib()
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(view)
    }
    
    func instanceViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func configureView(candlestick: Candlestick) {
//        if kLineModel.rate > 0 {
//            close.labelColor = riseColor
//            ratio.labelColor = riseColor
//        } else {
//            close.labelColor = downColor
//            ratio.labelColor = downColor
//        }
        
        if candlestick.open > candlestick.close {
            open.textColor = riseColor
        } else {
            open.textColor = downColor
        }
        
        if candlestick.open < candlestick.high {
            high.textColor = riseColor
        } else {
            high.textColor = downColor
        }
        
        if candlestick.open < candlestick.low {
            low.textColor = riseColor
        } else {
            low.textColor = downColor
        }
        
        open.text = candlestick.open.toString(withFormat: ".8")
        close.text = candlestick.close.toString(withFormat: ".8")
        high.text = candlestick.high.toString(withFormat: ".8")
        low.text = candlestick.low.toString(withFormat: ".8")
        volume.text = candlestick.volume.toString(withFormat: ".2")
        //ratio.text = candlestick.rate.toString(withFormat: ".2") + "%"
        date.text = DateFormatter.shortDate.string(from: candlestick.date)
        time.text = DateFormatter.shortTime.string(from: candlestick.date)
    }

}
