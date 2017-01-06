//
//  DepartmentTableViewCell.swift
//  cBuddy
//
//  Created by Kush Taneja on 30/08/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit

class DepartmentTableViewCell: UITableViewCell {

    @IBOutlet var Title: UILabel!
    
    @IBOutlet var departmentImageView: UIImageView!
    
    @IBOutlet var Subtitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
