//
//  PostTableViewCell.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 11/01/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postContentTextView: UITextView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var imageAndPostCOntent: NSLayoutConstraint!
    @IBOutlet weak var postImageFromProfile: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
