//
//  XmlNewsEncoder.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import Foundation

class XmlNewsEncoder: INewsEncoder {
    // MARK: - Private Properties
    
    private let news: [News]
    
    // MARK: - Initializers
    
    required init(news: [News]) {
        self.news = news
    }
    
    // MARK: - INewsEncoder
    
    func encode() -> Data? {
        let propertyListEncoder = PropertyListEncoder()
        propertyListEncoder.outputFormat = .xml
        let data = try? propertyListEncoder.encode(news)
        return data
    }
}
