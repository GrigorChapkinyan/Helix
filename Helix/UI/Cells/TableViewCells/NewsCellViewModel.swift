//
//  NewsCellViewModel.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 14.08.22.
//

import RxSwift
import RxRelay

struct NewsCellViewModel {
    // MARK: - Input
    
    let tap = PublishRelay<Void>()
    
    // MARK: - Output
    
    let title: String
    let imageEndpoint: String
    let description: String
    let publishDateStr: String
    
    // MARK: Private Properties
    
    private let linkEndpoint: String
    private let bag = DisposeBag()

    // MARK: - Initializers
    
    init(item: News) {
        self.title = item.title
        self.description = item.infoDescription
        self.imageEndpoint = item.thumbnailImageUrlStr
        self.linkEndpoint = item.linkUrlStr
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YY hh:mm"
        let dateStr = dateFormatter.string(from: item.publishDate)
        self.publishDateStr = "Published at: " + dateStr
        
        self.setupInitialBindings()
    }
    
    // MARK: - Helpers
    
    private func setupInitialBindings() {
        tap
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { _ in
                guard let url = URL(string: self.linkEndpoint) else {
                    return
                }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            .disposed(by: bag)
    }
}
