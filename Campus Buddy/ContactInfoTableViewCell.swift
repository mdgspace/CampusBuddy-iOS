//
//  ContactInfoTableViewCell.swift
//  cBuddy
//
//  Created by Kush Taneja on 30/08/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit

class ContactInfoTableViewCell: UITableViewCell {
    


    @IBOutlet var ImageView: UIImageView!
    
    @IBOutlet var ProfDesignatonLabel: UILabel!
    
    @IBOutlet var ProfNameLabel: UILabel!
    
    @IBOutlet var ProfDepartmentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
