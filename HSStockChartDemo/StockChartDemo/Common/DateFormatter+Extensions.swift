//
//  DateFormatter+Extensions.swift
//  SafetyBoot
//
//  Created by Jacob Sikorski on 2017-03-20.
//  Copyright © 2017 Tamarai. All rights reserved.
//


import Foundation

extension DateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat =  dateFormat
    }
}
