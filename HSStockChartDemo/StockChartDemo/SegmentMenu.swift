//
//  SegmentMenu.swift
//  HSStockChartDemo
//
//  Created by Hanson on 2016/11/15.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

@objc protocol SegmentMenuDelegate {
    func menuButtonDidClick(index: Int)
}

class SegmentMenu: UIView {
    private var stackView: UIStackView!
    private var bottomIndicator: UIView!
    private var bottomLine: UIView!
    private var buttons: [UIButton] = []
    private var selectedButton: UIButton?
    private var indicatorHeight: CGFloat = 2
    weak var delegate: SegmentMenuDelegate?
    
    var currentIndex: Int {
        if let button = selectedButton {
            return buttons.index(of: button) ?? 0
        } else {
            return 0
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        stackView = UIStackView()
        stackView.distribution = .fillEqually
        bottomIndicator = UIView()
        bottomIndicator.backgroundColor = UIColor(hexString: "#1782d0")
        
        bottomLine = UIView()
        bottomLine.backgroundColor = UIColor.groupTableViewBackground
        
        self.addSubview(stackView)
        self.addSubview(bottomIndicator)
        self.addSubview(bottomLine)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        
        bottomLine.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0).isActive = true
        bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButtons(from titles: [String]) {
        buttons.forEach() { self.stackView.removeArrangedSubview($0) }
        buttons.removeAll()
        
        // Create buttons
        buttons = titles.map {
            let button = UIButton()
            button.backgroundColor = UIColor.white
            button.setTitle($0, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(menuButtonDidClick(_:)), for: .touchUpInside)
            return button
        }
        
        buttons.forEach({ self.stackView.addArrangedSubview($0) })
        
        if let button = buttons.first {
            bottomIndicator.frame = indicatorFrame(for: button)
        }
    }
    
    func menuButtonDidClick(_ button: UIButton) {
        guard let index = buttons.index(of: button) else { return }
        selectButton(at: index)
    }
    
    func selectButton(at index: Int, animated: Bool = true) {
        guard index < self.buttons.count else { return }
        let button = self.buttons[index]
        
        if button != selectedButton {
            selectedButton?.setTitleColor(UIColor.black, for: .normal)
        }
        
        self.selectedButton = button
        delegate?.menuButtonDidClick(index: index)
        self.selectedButton?.setTitleColor(UIColor(hexString: "#1782d0"), for: .normal)
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.updateIndicatorFrame()
            }
        } else {
            self.updateIndicatorFrame()
        }
    }
    
    func updateIndicatorFrame() {
        if let button = selectedButton {
            self.bottomIndicator.frame = self.indicatorFrame(for: button)
            print(self.bottomIndicator.frame)
        }
    }
    
    func indicatorFrame(for button: UIButton) -> CGRect {
        let x = button.frame.origin.x
        let y = button.frame.size.height - self.indicatorHeight
        let width = button.frame.size.width
        let height = self.indicatorHeight
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
