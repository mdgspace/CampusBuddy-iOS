//
//  ProfContactTableViewCell.swift
//  cBuddy
//
//  Created by Kush Taneja on 30/08/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import UIKit

class ProfContactTableViewCell: UITableViewCell {

    
    @IBOutlet var ProfessorName: UILabel!
    
    @IBOutlet var Profdesignation: UILabel!
    
    @IBOutlet var ProfImageView: UIImageView!
   

    override func awakeFromNib() {
        super.awakeFromNib()
       
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
