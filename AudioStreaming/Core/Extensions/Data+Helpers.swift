//
//  Data+Helpers.swift
//  AudioStreaming
//
//  Created by Max Lesichniy on 10.08.2021.
//

import Foundation

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
}
