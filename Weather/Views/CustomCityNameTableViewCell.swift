//
//  CustomCityNameTableViewCell.swift
//  Weather
//
//  Created by Ipsi Patro on 15/03/2023.
//

import UIKit

class CustomCityNameTableViewCell: UITableViewCell {
    // MARK: - Outlet
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityNameDetailsLabel: UILabel!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Configure cell
    func configure(name: String, details: String) {
        self.cityNameLabel.text = name
        self.cityNameDetailsLabel.text = details
    }
}
