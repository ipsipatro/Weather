//
//  FavouriteCitiesViewController.swift
//  Weather
//
//  Created by Ipsi Patro on 16/03/2023.
//


import UIKit
import RxCocoa
import RxDataSources
import RxSwift
import MapKit

class FavouriteCitiesViewController: UIViewController {
    // MARK: - Outlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var favouriteCitiestableView: UITableView!
    @IBOutlet weak var searchResultView: UIView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private variables
    private var viewModel: FavouriteCitiesViewModel?
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
        favouriteCitiestableView.rowHeight = UITableView.automaticDimension
        favouriteCitiestableView.estimatedRowHeight = 300
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
        
        self.searchResultsTableView.register(UINib(nibName: CustomCityNameTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: CustomCityNameTableViewCell.reuseIdentifier)
        
        viewModel.output.searchResultsDataSource
            .bind(to: searchResultsTableView.rx.items(dataSource: searchResultsDataSource))
            .disposed(by: disposeBag)
        
        searchResultsTableView.rx.itemSelected
            .bind(to: viewModel.input.searchItemSelected)
            .disposed(by: disposeBag)
        
        self.favouriteCitiestableView.register(UINib(nibName: FavouriteCityTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: FavouriteCityTableViewCell.reuseIdentifier)
        
        viewModel.output.favouriteCititesDataSource
            .bind(to: favouriteCitiestableView.rx.items(dataSource: favouritecitiesDataSource))
            .disposed(by: disposeBag)
        
        favouriteCitiestableView.rx.itemSelected
            .bind(to: viewModel.input.favouriteCitySelected)
            .disposed(by: disposeBag)
        
        favouriteCitiestableView.rx.itemDeleted
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
    
    func bind(viewModel: FavouriteCitiesViewModel) {
        self.viewModel = (viewModel as FavouriteCitiesViewModel)
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
    
    private var searchResultsDataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, CityCellModel>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<String, CityCellModel>>(configureCell: { _, tableView, indexPath, viewModel -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomCityNameTableViewCell.reuseIdentifier, for: indexPath) as? CustomCityNameTableViewCell else {
                assertionFailure("Missing CustomCityNameTableViewCell")
                return UITableViewCell()
            }
            cell.configure(name: viewModel.result.title, details: viewModel.result.subtitle)
            return cell
        })
    }
    
    private var favouritecitiesDataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, FavouriteCitiesCellModel>> {
        return RxTableViewSectionedReloadDataSource<SectionModel<String, FavouriteCitiesCellModel>>(configureCell: { _, tableView, indexPath, viewModel -> UITableViewCell in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavouriteCityTableViewCell.reuseIdentifier, for: indexPath) as? FavouriteCityTableViewCell else {
                assertionFailure("Missing FavouriteCityTableViewCell")
                return UITableViewCell()
            }
            cell.TitleLabel.text = viewModel.city.name
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
            self.viewModel?.input.selectedCityStream.onNext((name, coordinate.latitude, coordinate.longitude))
        }
    }
}

extension FavouriteCitiesViewController: UISearchBarDelegate {
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

extension FavouriteCitiesViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        self.viewModel?.input.searchResultsStream.onNext(completer.results)
    }
}
