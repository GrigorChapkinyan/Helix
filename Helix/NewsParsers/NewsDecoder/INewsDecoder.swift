//
//  INewsDecoder.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import Foundation

protocol INewsDecoder {
    /// Returns decoded objects if everything is OK, otherwise nil
    /// - Attention: Must be called from background thread, otherwise will always return nil
    /// - Returns: the decoded objects or nil
    func decode() -> [News]?
    
    
    /// Default initializer
    /// - Parameter data: The data to be decoded
    init(data: Data)
}
