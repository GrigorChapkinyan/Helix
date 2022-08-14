//
//  HomeViewController.swift
//  Helix
//
//  Created by Grigor Chapkinyan on 14.08.22.
//

import UIKit
import RxSwift
import CoreServices

class HomeViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var blackTransparentView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Private Properties
    
    private let viewModel = HomeViewModel()
    private let bag = DisposeBag()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUIInitialConfigurations()
        setupViewModelBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.updateData.accept(())
    }
    
    // MARK: - IBActions
    
    @IBAction private func shareBarBtnTap(_ sender: Any) {
        // Presenting the alert sheet
        let alertController = UIAlertController(title: "File format", message: "Please select the file format with which you want to save the file.", preferredStyle: .actionSheet)
        let xmlAction = UIAlertAction(title: "Xml", style: .default) { [weak self] (action) in
            // Notifying about exporting file type to view model
            self?.viewModel.exportFileWithFormatType.accept(.xml)
        }
        let jsonAction = UIAlertAction(title: "Json", style: .default) { [weak self] (action) in
            // Notifying about exporting file type to view model
            self?.viewModel.exportFileWithFormatType.accept(.json)
        }
        alertController.addAction(xmlAction)
        alertController.addAction(jsonAction)
        
        if let presenter = alertController.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            presenter.permittedArrowDirections = []
        }
        
        self.present(alertController, animated: true)
    }

    // MARK: - Private API
    
    private func setupUIInitialConfigurations() {
        configureTableView()
    }
    
    private func setupViewModelBindings() {
        viewModel
            .cellViewModels
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: bag)
        
        viewModel
            .isLoading
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (isLoading) in
                self?.configureLoadingState(isEnabled: isLoading)
            })
            .disposed(by: bag)
        
        viewModel
            .alertMessage
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (message) in
                let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
                alertController.addAction(okayAction)
                self?.present(alertController, animated: true)
            })
            .disposed(by: bag)
    }
    
    private func configureLoadingState(isEnabled: Bool) {
        blackTransparentView.isHidden = !isEnabled
        isEnabled ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.delaysContentTouches = false
        tableView.allowsSelection = true
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func configureTableView() {
        tableView.register(UINib(nibName: NewsTableViewCell.nibFileName, bundle: nil), forCellReuseIdentifier: NewsTableViewCell.reuseId)
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellViewModels = viewModel.cellViewModels.value,
              let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.reuseId, for: indexPath) as? NewsTableViewCell,
              cellViewModels.count > indexPath.row  else {
            return UITableViewCell()
        }
        
        cell.setupViewModel(cellViewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.value?.count ?? 0
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Notifying about cell tap to viewModel
        viewModel.cellTapIndex.accept(indexPath.row)
        // Deselecting the row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
    }
}
