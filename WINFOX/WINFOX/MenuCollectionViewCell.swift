//
//  MenuCollectionViewCell.swift
//  WINFOX
//
//  Created by  Admin on 07.11.2021.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        func setupViews(){
            backgroundColor = UIColor.red
        }
}
