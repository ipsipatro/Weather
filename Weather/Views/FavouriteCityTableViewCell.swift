//
//  FavouriteCityTableViewCell.swift
//  Weather
//
//  Created by Ipsi Patro on 16/03/2023.
//

import UIKit

class FavouriteCityTableViewCell: UITableViewCell {
    // MARK: - Outlet
    @IBOutlet weak var TitleLabel: UILabel!
    
    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        contentView.layer.cornerRadius = 10 //set corner radius here
        contentView.layer.borderColor = UIColor.gray.cgColor  // set cell border color here
        contentView.layer.borderWidth = 2
    }
}
