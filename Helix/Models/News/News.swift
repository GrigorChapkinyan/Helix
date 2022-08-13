//
//  News.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import Foundation

struct News: Codable {
    // MARK: - Nested Types
    
    enum CodingKeys: String, CodingKey {
        case title
        case thumbnailImageUrlStr = "urlToImage"
        case infoDescription = "description"
        case linkUrlStr = "url"
        case publishDate = "publishedAt"
    }
    
    enum XmlCodingKeys: String {
        case title
        case thumbnailImageUrlStr = "image"
        case infoDescription = "description"
        case linkUrlStr = "guid"
        case publishDate = "pubDate"
    }
    
    // MARK: - Public Properties

    let title: String
    let thumbnailImageUrlStr: String?
    let infoDescription: String
    let linkUrlStr: String
    let publishDate: Date!
    
    // MARK: - Initializers
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try values.decode(String.self, forKey: .title)
        thumbnailImageUrlStr = try values.decode(String.self, forKey: .thumbnailImageUrlStr)
        infoDescription = try values.decode(String.self, forKey: .infoDescription)
        linkUrlStr = try values.decode(String.self, forKey: .linkUrlStr)
        
        // Must convert date str into date
        // We can have two types of date reprasantation
        // So trying both
        let publishDateStr = try values.decode(String.self, forKey: .publishDate)
        if let publishDate = ISO8601DateFormatter().date(from: publishDateStr) {
            self.publishDate = publishDate
        }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
            let publishDate = dateFormatter.date(from: publishDateStr)
            self.publishDate = publishDate
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encode(thumbnailImageUrlStr, forKey: .thumbnailImageUrlStr)
        try container.encode(infoDescription, forKey: .infoDescription)
        try container.encode(linkUrlStr, forKey: .linkUrlStr)

        // Must convert Date into str
        // We can have two types of date reprasantation
        // So trying both
        let iso8601DateStr = ISO8601DateFormatter().string(from: publishDate)
        if (!iso8601DateStr.isEmpty) {
            try container.encode(iso8601DateStr, forKey: .publishDate)
        }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
            let dateStr = dateFormatter.string(from: publishDate)
            try container.encode(dateStr, forKey: .publishDate)
        }
    }
    
    init?(dictionary:[AnyHashable:Any]) {
        guard let title = dictionary[XmlCodingKeys.title.rawValue] as? String,
              let thumbnailImageUrlStr = dictionary[XmlCodingKeys.thumbnailImageUrlStr.rawValue] as? String,
              let infoDescription = dictionary[XmlCodingKeys.infoDescription.rawValue] as? String,
              let linkUrlStr = dictionary[XmlCodingKeys.linkUrlStr.rawValue] as? String,
              let publishDateStr = dictionary[XmlCodingKeys.publishDate.rawValue] as? String else {
            return nil
        }
        
        self.title = title
        self.thumbnailImageUrlStr = thumbnailImageUrlStr
        self.infoDescription = infoDescription
        self.linkUrlStr = linkUrlStr
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let publishDate = dateFormatter.date(from: publishDateStr)
        self.publishDate = publishDate
    }
}
