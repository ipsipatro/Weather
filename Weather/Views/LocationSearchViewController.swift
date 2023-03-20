//
//  LocationSearchViewController.swift
//  Weather
//
//  Created by Ipsi Patro on 16/03/2023.
//


import UIKit
import RxCocoa
import RxDataSources
import RxSwift
import MapKit

class LocationSearchViewController: UIViewController {
    // MARK: - Outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var savedLocationsTableView: UITableView!
    @IBOutlet weak var searchResultView: UIView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private variables
    private var viewModel: LocationSearchViewModel?
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    private let disposeBag = DisposeBag()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        configureUI()
    }
    
    // MARK: - UI
    private func configureUI() {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.searchResultView.isHidden = true
        self.loadingView.isHidden = true
        self.title = "Weather"
        savedLocationsTableView.rowHeight = UITableView.automaticDimension
        savedLocationsTableView.estimatedRowHeight = 300
        self.navigationItem.backButtonTitle = ""
        
        handleLoadingView()
    }
    
    // MARK: - Binding
    private func bind() {
        guard let viewModel = self.viewModel else {
            assertionFailure("Missing TradingAccountsListViewModel")
            return
        }
        searchCompleter.delegate = self
        searchBar?.delegate = self
        
        self.searchResultsTableView.register(UINib(nibName: LocationTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: LocationTableViewCell.reuseIdentifier)
        
        viewModel.output.searchResultsDataSource
            .bind(to: searchResultsTableView.rx.items(dataSource: searchResultsDataSource))
            .disposed(by: disposeBag)
        
        searchResultsTableView.rx.itemSelected
            .bind(to: viewModel.input.searchItemSelected)
            .disposed(by: disposeBag)
        
        self.savedLocationsTableView.register(UINib(nibName: SavedLocationTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: SavedLocationTableViewCell.reuseIdentifier)
        
        viewModel.output.savedLocationsDataSource
            .bind(to: savedLocationsTableView.rx.items(dataSource: savedLocationsDataSource))
            .disposed(by: disposeBag)
        
        savedLocationsTableView.rx.itemSelected
            .bind(to: viewModel.input.savedLocationSelected)
            .disposed(by: disposeBag)
        
        savedLocationsTableView.rx.itemDeleted
            .subscribe(onNext: { indexpath in
                viewModel.input.itemDeleted.onNext(indexpath)
            })
            .disposed(by: disposeBag)
        
        
        viewModel.output.hideSearchResultsViewDriver.drive(onNext: { [weak self] hide in
            self?.searchResultView.isHidden = hide
        }).disposed(by: disposeBag)
        
        viewModel.output.searchForResultDriver.drive(onNext: { [weak self] result in
            self?.searchForResult(result)
        }).disposed(by: disposeBag)
        
        viewModel.output.showPopupDriver.drive(onNext: { [weak self] message in
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    func bind(viewModel: LocationSearchViewModel) {
        self.viewModel = (viewModel as LocationSearchViewModel)
    }
    
    // MARK: - Private methods
    private func handleLoadingView() {
        self.activityIndicator?.style = .medium
        //Show and Hide loading
        viewModel?.output.loadingStatusDriver
            .drive(onNext: { [weak self] show in
                guard let self = self else { return }
                self.loadingView?.isHidden =  !show
                self.activityIndicator?.isHidden = !show
                show ? self.activityIndicator?.startAnimating() : self.activityIndicator?.stopAnimating()
                if (!show) {
                    self.view.endEditing(true)
                }
            }).disposed(by: disposeBag)
    }
    
    private var searchResultsDataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, LocationCellModel>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<String, LocationCellModel>>(configureCell: { _, tableView, indexPath, viewModel -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseIdentifier, for: indexPath) as? LocationTableViewCell else {
                assertionFailure("Missing LocationTableViewCell")
                return UITableViewCell()
            }
            cell.configure(name: viewModel.result.title, details: viewModel.result.subtitle)
            return cell
        })
    }
    
    private var savedLocationsDataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, SavedLocationCellModel>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<String, SavedLocationCellModel>>(configureCell: { _, tableView, indexPath, viewModel -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SavedLocationTableViewCell.reuseIdentifier, for: indexPath) as? SavedLocationTableViewCell else {
                assertionFailure("Missing SavedLocationTableViewCell")
                return UITableViewCell()
            }
            cell.TitleLabel.text = viewModel.location.name
            return cell
        })
    }
    
    private func searchForResult(_ result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: result)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                return
            }
            
            guard let name = response?.mapItems[0].name else {
                return
            }
            self.viewModel?.input.selectedLocationStream.onNext((name, coordinate.latitude, coordinate.longitude))
        }
    }
}

extension LocationSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        if(searchText.isEmpty) {
            self.viewModel?.input.searchResultsStream.onNext([])
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
}

extension LocationSearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        self.viewModel?.input.searchResultsStream.onNext(completer.results)
    }
}
