//
//  LocationTableViewCell.swift
//  Weather
//
//  Created by Ipsi Patro on 15/03/2023.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    // MARK: - Outlet
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationDetailsLabel: UILabel!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
    
    // MARK: - Configure cell
    func configure(name: String, details: String) {
        self.locationNameLabel.text = name
        self.locationDetailsLabel.text = details
    }
}
