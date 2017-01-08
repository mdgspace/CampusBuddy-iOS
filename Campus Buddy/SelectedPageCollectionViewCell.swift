//
//  SelectedPageCollectionViewCell.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 08/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

class SelectedPageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pageImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = self.contentView.frame.width*0.5
        self.contentView.layer.borderWidth = CGFloat(integerLiteral: 1)
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.pageImageView.layer.cornerRadius = self.pageImageView.frame.width*0.5

    }
    
   
}
