//
//  UIScrollView+Extensions.swift
//  StockChartExample
//
//  Created by Jacob Sikorski on 2017-12-20.
//  Copyright © 2017 hanson. All rights reserved.
//

import UIKit

enum ScrollDirection {
    case top
    case right
    case bottom
    case left
}

extension UIScrollView {
    func scrollTo(direction: ScrollDirection, animated: Bool = true) {
        self.setContentOffset(self.contentOffset(for: direction), animated: animated)
    }
    
    func isScrolled(to direction: ScrollDirection) -> Bool {
        return self.contentOffset == self.contentOffset(for: direction)
    }
    
    private func contentOffset(for direction: ScrollDirection) -> CGPoint {
        switch direction {
        case .top:      return CGPoint(x: 0, y: -self.contentInset.top)
        case .right:    return CGPoint(x: self.contentSize.width - self.bounds.size.width, y: 0)
        case .bottom:   return CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        case .left:     return CGPoint(x: -self.contentInset.left, y: 0)
        }
    }
}
