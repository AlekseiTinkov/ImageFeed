//
//  OptionalString+Extension.swift
//  ImageFeed
//
//  Created by Алексей Тиньков on 21.06.2023.
//

import Foundation

extension Optional where Wrapped == String {
    var unwrap: String {
        return self ?? ""
    }
}
