//
//  MenuCollectionViewCell.swift
//  WINFOX
//
//  Created by Flash Jessi on 11/8/21.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.backgroundColor = .white
    }

}
