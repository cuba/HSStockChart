//
//  HSKLineBriefView.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/8.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit
import HSStockChart

class HSKLineBriefView: UIView {
    
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var close: UILabel!
    @IBOutlet weak var high: UILabel!
    @IBOutlet weak var low: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var ratio: UILabel!
    @IBOutlet weak var time: UILabel!
    
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
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    func instanceViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func configureView(_ preClose: CGFloat, kLineModel: Candlestick) {
        let riseColor = UIColor.red
        let downColor = UIColor(hexString: "#1DBF60")

        if kLineModel.rate > 0 {
            close.textColor = riseColor
            ratio.textColor = riseColor
        } else {
            close.textColor = downColor
            ratio.textColor = downColor
        }
        
        if preClose < kLineModel.open {
            open.textColor = riseColor
        } else {
            open.textColor = downColor
        }
        
        if preClose < kLineModel.high {
            high.textColor = riseColor
        } else {
            high.textColor = downColor
        }
        
        if preClose < kLineModel.low {
            low.textColor = riseColor
        } else {
            low.textColor = downColor
        }
        open.text = kLineModel.open.toString(withFormat: ".8")
        close.text = kLineModel.close.toString(withFormat: ".8")
        high.text = kLineModel.high.toString(withFormat: ".8")
        low.text = kLineModel.low.toString(withFormat: ".8")
        volume.text = kLineModel.volume.toString(withFormat: ".2")
        ratio.text = kLineModel.rate.toString(withFormat: ".2") + "%"
        time.text = kLineModel.date?.toString(withFormat: "yyyy-MM-dd")
    }

}