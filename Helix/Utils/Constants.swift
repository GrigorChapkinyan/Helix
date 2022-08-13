//
//  Constants.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import Foundation
import CoreGraphics

struct Constants {
    enum APIEndpoint: String {
        // Development API base URL
        #if DEBUG
            case jsonDataBaseUrl = "https://newsapi.org/v2"
            case xmlDataBaseUrl = "http://feeds.bbci.co.uk"
        // Release API base URL
        #else
            case jsonDataBaseUrl = "https://newsapi.org/v2"
            case xmlDataBaseUrl = "http://feeds.bbci.co.uk"
        #endif
        
        case jsonDataTopHeadlinesEndpoint = "/top-headlines"
        case xmlDataNewsVideoAndAudioTechnologyEndpoint = "/news/video_and_audio/technology/rss.xml"
    }
    
    enum ResourcesNames: String {
        case newsFile = "News.json"
    }
    
//    enum HttpBodyKeys: String {
//    }
//
//    enum ImageAssetNames: String {
//
//    }
//
//    enum ColorNames: String {
//
//    }
    
    static let requestJsonHeaders = ["Content-Type": "application/json","Accept": "application/json"]
}

