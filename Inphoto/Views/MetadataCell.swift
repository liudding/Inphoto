//
//  MetadataCell.swift
//  Inphoto
//
//  Created by liuding on 2018/11/29.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit

class MetadataCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
