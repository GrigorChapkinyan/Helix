//
//  NewsDataManager.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 13.08.22.
//

import Foundation
import RxSwift
import RxCocoa

class NewsDataManager {
    // MARK: - Nested Types
    
    enum Error: Swift.Error {
        case parseError
    }

    // MARK: - Private Nested Types
    
    private enum DataFormatType: CaseIterable {
        case json
        case xml
    }
    
    // MARK: - Output
    
    let allItemsObservable = BehaviorRelay<[News]?>(value: nil)

    // MARK: - Private Properties
    
    private var fileManager = NewsFileManager(decoderType: JsonNewsDecoder.self, encoderType: JsonNewsEncoder.self)
    private let bag = DisposeBag()
    
    // MARK: - Public Static Properties
    
    static let shared = NewsDataManager()

    // MARK: - Public API
    
    func updateItems() {
        fetchAllItems()
            .subscribe(
                onNext: { [weak self] (items) in
                    // Emmiting to observable
                    self?.allItemsObservable.accept(items)
                    // Saving locally
                    self?.storeItems(items: items)
                },
                onError: { (error) in
                    print("Error while updating data for \"News\": \(error)")
                }
            )
            .disposed(by: bag)
    }
    
    // MARK: - Initializers
    
    private init() {
        // When this shared instance is called first time,
        // it must to try emmit already saved items.
        // Going to the background thread, so the caller will not keep waiting us 
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let storedItems = self?.getAllStoredItems() else {
                return
            }
            
            self?.allItemsObservable.accept(storedItems)
        }
    }
    
    // MARK: - Private API
    
    private func fetchAllItems() -> Observable<[News]> {
        var allDataTypeObservables = [Observable<[News]>]()
        
        for dataTypeIter in DataFormatType.allCases {
            let observableToAppend = fetchItems(for: dataTypeIter)
            allDataTypeObservables.append(observableToAppend)
        }
        
        return Observable
            .zip(allDataTypeObservables)
            .map{ $0.flatMap({ $0 }) }
    }
    
    private func fetchItems(for dataType: DataFormatType) -> Observable<[News]> {
        return getReponse(for: dataType)
            .map{ [weak self] (response) in
                guard let data = response.data,
                      let parsedItems = self?.parseItems(from: data, for: dataType)  else {
                    throw Error.parseError
                }
                
                return parsedItems
            }
    }
    
    private func getItemsArrayData(from initialApiResponse: Data, for dataType: DataFormatType) -> Data? {
        switch (dataType) {
            case .xml:
                return initialApiResponse
            
            case .json:
                guard   let initDict = try? JSONSerialization.jsonObject(with: initialApiResponse, options: []) as? [String: Any],
                        let objectsDictArray = initDict["articles"] as? [[AnyHashable:Any]],
                        let finalData = try? JSONSerialization.data(withJSONObject: objectsDictArray, options: []) else {
                    print("Failed getting nested items array data for \(dataType) type.")
                    return nil
                }
            
                return finalData
        }
    }
    
    private func parseItems(from data: Data, for dataType: DataFormatType) -> [News]? {
        guard let neededData = getItemsArrayData(from: data, for: dataType) else {
            return nil
        }
        
        let decoder: INewsDecoder
        
        switch (dataType) {
            case .xml:
                decoder = XmlNewsDecoder(data: neededData)
            
            case .json:
                decoder = JsonNewsDecoder(data: neededData)
        }
        
        let decodedItems = decoder.decode()
        return decodedItems
    }
    
    private func getReponse(for dataType: DataFormatType) -> Observable<NetworkService.Response> {
        return NetworkService
            .shared
            .sendHttpRequest(
                urlString: getRequestUrlStr(for: dataType),
                httpMethod: .get,
                queryParametrs: getQueryParameters(for: dataType)
            )
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
    }
    
    private func getAllStoredItems() -> [News]? {
        let result = fileManager.retrieveItems()
        return result.data
    }
    
    private func storeItems(items: [News]) {
        fileManager.storeItems(items)
    }
    
    private func getQueryParameters(for dataType: DataFormatType) -> [String:String]? {
        switch (dataType) {
            case .xml:
                return nil
            
            case .json:
                return [
                    "sources" : "techcrunch",
                    "apiKey" : "97ba815035ae4381b223377b2df975ab"
                ]
        }
    }
    
    private func getRequestUrlStr(for dataType: DataFormatType) -> String {
        switch (dataType) {
            case .xml:
                return Constants.APIEndpoint.xmlDataBaseUrl.rawValue + Constants.APIEndpoint.xmlDataNewsVideoAndAudioTechnologyEndpoint.rawValue
            
            case .json:
                return Constants.APIEndpoint.jsonDataBaseUrl.rawValue + Constants.APIEndpoint.jsonDataTopHeadlinesEndpoint.rawValue
        }
    }
}
