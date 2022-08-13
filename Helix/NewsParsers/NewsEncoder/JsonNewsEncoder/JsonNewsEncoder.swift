//
//  JsonNewsEncoder.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import Foundation

class JsonNewsEncoder: INewsEncoder {
    // MARK: - Private Properties
    
    private let news: [News]
    
    // MARK: - Initializers
    
    required init(news: [News]) {
        self.news = news
    }
    
    // MARK: - INewsEncoder
    
    func encode() -> Data? {
        return try? JSONEncoder().encode(news)
    }
}
