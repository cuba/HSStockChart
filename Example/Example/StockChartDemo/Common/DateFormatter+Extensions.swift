//
//  DateFormatter+Extensions.swift
//  SafetyBoot
//
//  Created by Jacob Sikorski on 2017-03-20.
//  Copyright © 2017 Tamarai. All rights reserved.
//


import Foundation

extension DateFormatter {
    static let chartListTime: DateFormatter = {
        // TODO: @JS Switch to [ISO8601DateFormatter](https://developer.apple.com/documentation/foundation/iso8601dateformatter) when we drop ios 9 support.
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE MMM d HH:mm:ss z yyyy"
        
        return formatter
    }()
    
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
    
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat =  dateFormat
    }
}
