//
//  String+Extensions.swift
//  SafetyBoot
//
//  Created by Jacob Sikorski on 2017-03-20.
//  Copyright © 2017 Tamarai. All rights reserved.
//

import Foundation

extension String {
    func toDate(withFormat format: String) -> Date? {
        let formatter = DateFormatter(dateFormat: format)
        return formatter.date(from: self)
    }
}
