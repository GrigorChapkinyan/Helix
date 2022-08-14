//
//  NewsFileManager.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import RxSwift

struct NewsFileManager {
    // MARK: - Nested Types

    typealias Result = (data: [News]?, error: Error?)
    
    enum Error: Swift.Error {
        case readingError(error: Swift.Error?)
        case savingError(error: Swift.Error?)
        case exportingError(error: Swift.Error?)
    }
    
    // MARK: - Private Properties
    
    private let decoderType: INewsDecoder.Type
    private let encoderType: INewsEncoder.Type
    private var error: Error?
    
    // MARK: - Public API
    
    @discardableResult mutating func storeItems(_ items: [News]) -> Result {
        error = nil
        save(news: items, withFileName: Constants.ResourcesNames.newsFile.rawValue)
        return (nil, error)
    }
    
    @discardableResult mutating func retrieveItems() -> Result {
        error = nil
        let items = read(fromDocumentsWithFileName: Constants.ResourcesNames.newsFile.rawValue)
        return (items, error)
    }
    
    @discardableResult mutating func exportItems(_ items: [News]) -> Result {
        error = nil
        save(news: items, isExport: true, withFileName: Constants.ResourcesNames.helixNewsList.rawValue)
        return (nil, error)
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
    
    private func documentsDirectory() -> String? {
        let libraryDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
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

    mutating private func read(fromDocumentsWithFileName fileName: String) -> [News]? {
        guard   let libraryDirectory = libraryDirectory(),
                let filePath = append(toPath: libraryDirectory,
                                      withPathComponent: fileName),
                let saveData = try? String(contentsOfFile: filePath).data(using: .utf8)  else {
                    self.error = .readingError(error: nil)
                    return nil
        }

        let decodedData = decoderType.init(data: saveData).decode()
        return decodedData
    }

    @discardableResult mutating private func save(
        news: [News],
        isExport: Bool = false,
        withFileName fileName: String
    ) -> Bool {
        // If this is exporting case,
        // we must append correct file extension to its name
        let fileName = isExport ? getCorrectedFileNameForExporting(initialName: fileName) : fileName
        
        guard   let baseDirectoryPath = isExport ? documentsDirectory() : libraryDirectory(),
                let filePath = append(toPath: baseDirectoryPath,
                                         withPathComponent: fileName),
                let encodedData = encoderType.init(news: news).encode()    else {
            self.error = isExport ? .exportingError(error: nil) : .savingError(error: nil)
            return false
        }

        do {
            let fileUrl = URL(fileURLWithPath: filePath)
            try encodedData.write(to: fileUrl)
            return true
        }
        catch {
            print("Error while writing to file: \(error)")
            self.error = isExport ? .exportingError(error: error) : .savingError(error: error)
            return false
        }
    }
    
    private func getCorrectedFileNameForExporting(initialName: String) -> String {
        let fileTypeIsXml = (encoderType == XmlNewsEncoder.self)
        let fileExt = fileTypeIsXml ? "xml" : "json"
        let fileName = initialName + "." + fileExt
        return fileName
    }
}
