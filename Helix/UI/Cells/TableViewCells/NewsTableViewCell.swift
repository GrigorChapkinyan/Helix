//
//  NewsTableViewCell.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 14.08.22.
//

import UIKit
import RxSwift
import SDWebImage

class NewsTableViewCell: UITableViewCell {
    // MARK: - Outlets
    
    @IBOutlet private weak var customContainerView: UIView!
    @IBOutlet private weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var dateLabel: UILabel!
    
    // MARK: - Private Properties
    
    private var viewModel: NewsCellViewModel?
    private var reusableBag = DisposeBag()
    
    // MARK: - Static Properties
    
    static let reuseId = "NewsTableViewCell"
    static let nibFileName = "NewsTableViewCell"

    // MARK: - View Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        setupUIInitialConfigurations()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        setupUIInitialConfigurations()
    }
    
    // MARK: - Public API
    
    func setupViewModel(_ viewModel: NewsCellViewModel) {
        self.viewModel = viewModel
        resetViewModelBindings()
    }

    // MARK: - Private API
    
    private func setupUIInitialConfigurations() {
        // Giving exclusion path to text view
        let imageFrame = UIBezierPath(rect: thumbnailImageView.frame)
        descriptionTextView.textContainer.exclusionPaths = [imageFrame]
        
        customContainerView.layer.shadowColor = UIColor.black.cgColor
        customContainerView.layer.shadowOpacity = 1
        customContainerView.layer.shadowOffset = .zero
        customContainerView.layer.shadowRadius = 10
    }
    
    private func resetViewModelBindings() {
        reusableBag = DisposeBag()
        
        guard let viewModel = viewModel else {
            return
        }

        titleLabel.text = viewModel.title
        descriptionTextView.text = viewModel.description
        dateLabel.text = viewModel.publishDateStr
        
        thumbnailImageView
            .sd_setImage(with: URL(string: viewModel.imageEndpoint))
    }
}
