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
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       // Configure the view for the selected state
    }

}
