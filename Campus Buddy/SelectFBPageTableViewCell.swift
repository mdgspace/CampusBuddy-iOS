//
//  SelectFBPageTableViewCell.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 08/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

class SelectFBPageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pageImageView: UIImageView!

    @IBOutlet weak var pageName: UILabel!
    
    @IBOutlet weak var accesoryView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .none
//        accesoryView.layer.backgroundColor = UIColor.white.cgColor
//        accesoryView.layer.borderWidth = CGFloat(integerLiteral: 2)
//        accesoryView.layer.cornerRadius = accesoryView.frame.size.width*0.5
//        accesoryView.layer.borderColor = UIColor.gray.cgColor
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
