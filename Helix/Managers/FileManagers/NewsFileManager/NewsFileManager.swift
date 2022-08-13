//
//  NewsFileManager.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import RxSwift

struct NewsFileManager {
    // MARK: - Nested Types

    enum Error: Swift.Error {
        case readingError(error: Swift.Error?)
        case savingError(error: Swift.Error?)
    }
    
    // MARK: - Private Properties
    
    private let decoderType: INewsDecoder.Type
    private let encoderType: INewsEncoder.Type
    
    // MARK: - Public API
    
    func storeItems(_ items: [News]) -> Bool {
        return save(news: items, withFileName: Constants.ResourcesNames.newsFile.rawValue)
    }
    
    func retrieveItems() -> [News]? {
        return read(fromDocumentsWithFileName: Constants.ResourcesNames.newsFile.rawValue)
    }
    
    // MARK: - Initializers
    
    init(decoderType: INewsDecoder.Type, encoderType: INewsEncoder.Type) {
        self.decoderType = decoderType
        self.encoderType = encoderType
    }
    
    // MARK: - Private API
    
    private func libraryDirectory() -> String? {
        let libraryDirectory = NSSearchPathForDirectoriesInDomains(.libraryDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return libraryDirectory.last
    }

    private func append(toPath path: String,
                        withPathComponent pathComponent: String) -> String? {
        if var pathURL = URL(string: path) {
            pathURL.appendPathComponent(pathComponent)

            return pathURL.absoluteString
        }

        return nil
    }

    private func read(fromDocumentsWithFileName fileName: String) -> [News]? {
        guard   let libraryDirectory = libraryDirectory(),
                let filePath = append(toPath: libraryDirectory,
                                      withPathComponent: fileName),
                let saveData = try? String(contentsOfFile: filePath).data(using: .utf8)  else {
                                            return nil
        }

        let decodedData = decoderType.init(data: saveData).decode()
        return decodedData
    }

    private func save(news: [News],
                      withFileName fileName: String) -> Bool {
        guard   let libraryDirectory = libraryDirectory(),
                let filePath = append(toPath: libraryDirectory,
                                         withPathComponent: fileName),
                let jsonData = encoderType.init(news: news).encode()    else {
            return false
        }

        do {
            let fileUrl = URL(fileURLWithPath: filePath)
            try jsonData.write(to: fileUrl)
            return true
        }
        catch {
            print("Error writing to JSON file: \(error)")
            return false
        }
    }
}
