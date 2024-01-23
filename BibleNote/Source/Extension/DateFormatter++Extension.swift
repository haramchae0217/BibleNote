//
//  DateFormatter++Extension.swift
//  BibleNote
//
//  Created by Chae_Haram on 1/23/24.
//

import UIKit

extension DateFormatter {
    static let customDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        df.locale = Locale(identifier: "ko_KR")
        return df
    }()
    
    func strToDate(str: String) -> Date {
        self.dateFormat = "yyyy/MM/dd"
        return self.date(from: str)!
    }
    
    func dateToString(date: Date) -> String {
        self.dateFormat = "yyyy/MM/dd"
        return self.string(from: date)
    }
    
}
