//
//  PlaceCollectionViewCell.swift
//  WINFOX
//
//  Created by  Svetlana Frolova on 07.11.2021.
//

import UIKit

class PlaceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var globalView: UIView! {
        didSet {
            globalView.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}
