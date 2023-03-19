//
//  WeatherViewController.swift
//  Weather
//
//  Created by Ipsi Patro on 14/03/2023.
//

import UIKit
import RxSwift

class WeatherViewController: UIViewController {
    // MARK: - Outlet
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var temeratureDescriptionLabel: UILabel!
    @IBOutlet weak var showCityListButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: - Private variables
    private var viewModel: WeatherViewModel?
    private let disposeBag = DisposeBag()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
        bind()
    }
    
    // MARK: - Binding
    func bind(viewModel: WeatherViewModel) {
        self.viewModel = (viewModel as WeatherViewModel)
    }
    
    private func bind() {
        guard let viewModel = self.viewModel else {
            assertionFailure("Missing WeatherViewModel")
            return
        }
        
        // Title
        self.title = viewModel.output.titleText
        self.temperatureLabel.text = viewModel.output.temperatureValue
        self.maxTemperatureLabel.text = viewModel.output.maxTemperatureValue
        self.minTemperatureLabel.text = viewModel.output.minTemperatureValue
        self.temeratureDescriptionLabel.text = viewModel.output.weatherDescription.capitalized
        
        // Bind showCityListButton tap
        self.showCityListButton?.rx.tap.asObservable()
            .subscribe(viewModel.input.showCityListButtonTapped)
            .disposed(by: disposeBag)
        
        guard let url = URL(string:viewModel.output.iconImageURL) else { return }
        self.iconImageView.load(url: url)
        
        self.addButton?.rx.tap.asObservable()
            .subscribe(viewModel.input.addButtonTapped)
            .disposed(by: disposeBag)

    }
}
