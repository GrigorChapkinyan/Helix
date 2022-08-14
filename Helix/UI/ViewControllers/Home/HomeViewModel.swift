//
//  HomeViewModel.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 14.08.22.
//

import RxSwift
import RxRelay

struct HomeViewModel {
    // MARK: - Input
    
    let cellTapIndex = PublishRelay<Int>()
    let updateData = PublishRelay<Void>()
    let exportFileWithFormatType = PublishRelay<NewsDataManager.DataFormatType>()

    // MARK: - Output
    
    let alertMessage = PublishRelay<String>()
    let isLoading = BehaviorRelay<Bool>(value: false)
    let cellViewModels = BehaviorRelay<[NewsCellViewModel]?>(value: nil)
    
    // MARK: - Private Properties
    
    private let bag = DisposeBag()
    private let dataExportingIsLaoding = BehaviorRelay<Bool>(value: false)
    private let dataManagerIsLaoding = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Initializers
    
    init() {
        setupInitialBindings()
    }
    
    // MARK: - Private API
    
    private func setupInitialBindings() {
        NewsDataManager
            .shared
            .allItemsObservable
            .compactMap{ $0 }
            .map{ (news) in
                let sortedNewsNyDate = news.sorted(by: { $0.publishDate > $1.publishDate })
                let cellViewModels = sortedNewsNyDate.map{NewsCellViewModel(item: $0)}
                return cellViewModels
            }
            .bind(to: cellViewModels)
            .disposed(by: bag)
        
        NewsDataManager
            .shared
            .isLaoding
            .filter { (dataManagerIsLaoding) in
                // If current instance is loading,
                // we must listen to the loading state of data manager
                if (self.isLoading.value == true) {
                    return true
                }
                // Otherwis if the data already exist in this instance,
                // we must avoid emmiting loading values
                else {
                    if (self.cellViewModels.value == nil) {
                        return true
                    }
                    else {
                        return false
                    }
                }
            }
            .bind(to: dataManagerIsLaoding)
            .disposed(by: bag)
        
        cellTapIndex
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { (index) in
                self.handleCellTap(at: index)
            })
            .disposed(by: bag)
        
        updateData
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: {
                NewsDataManager.shared.updateItems()
            })
            .disposed(by: bag)
        
        Observable
            .combineLatest(dataExportingIsLaoding, dataManagerIsLaoding)
            .map{ $0 || $1 }
            .bind(to: isLoading)
            .disposed(by: bag)
        
        exportFileWithFormatType
            .observe(on: SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext:{ (url) in
                self.handleFileExport(with: url)
            })
            .disposed(by: bag)
    }
    
    private func handleCellTap(at index: Int) {
        guard let cellViewModels = cellViewModels.value,
              cellViewModels.count > index  else {
            return
        }
        
        cellViewModels[index].tap.accept(())
    }
    
    private func handleFileExport(with fileFormatType: NewsDataManager.DataFormatType) {
        guard let newsItems = NewsDataManager.shared.allItemsObservable.value else {
            return
        }
        
        // Correcting the loading state
        dataExportingIsLaoding.accept(true)
        
        // Getting correct encoder and decoder types
        let fileEncoderType: INewsEncoder.Type
        let fileDecoderType: INewsDecoder.Type
        
        switch (fileFormatType) {
            case .xml:
                fileEncoderType = XmlNewsEncoder.self
                fileDecoderType = XmlNewsDecoder.self
                
            case .json:
                fileEncoderType = JsonNewsEncoder.self
                fileDecoderType = JsonNewsDecoder.self
        }
        
        // Trying to export file
        var filesManager = NewsFileManager(decoderType: fileDecoderType, encoderType: fileEncoderType)
        let result = filesManager.exportItems(newsItems)
        
        // Correcting the loading state
        dataExportingIsLaoding.accept(false)
        
        let alertMessage: String = (result.error == nil) ? "File was saved successfully." : "Error while saving the file."
        self.alertMessage.accept(alertMessage)
    }
}
