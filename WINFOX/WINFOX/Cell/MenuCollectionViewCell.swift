//
//  MenuCollectionViewCell.swift
//  WINFOX
//
//  Created by Svetlana Frolova on 11/8/21.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var globalView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.backgroundColor = .white
        globalView.layer.cornerRadius = 12
        image.layer.cornerRadius = 12
    }

}
