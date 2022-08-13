//
//  JsonNewsDecoder.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import Foundation

struct JsonNewsDecoder: INewsDecoder {
    // MARK: - Private Properties
    
    private let data: Data
    
    // MARK: - Initializers
    
    init(data: Data) {
        self.data = data
    }
    
    // MARK: - INewsParser
    
    func decode() -> [News]? {
        return try? JSONDecoder().decode([News].self, from: data)
    }
}
