//
//  INewsEncoder.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import Foundation

protocol INewsEncoder {
    func encode() -> Data?
    init(news: [News])
}
