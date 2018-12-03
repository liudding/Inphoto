//
//  ResourceTableViewCell.swift
//  Inphoto
//
//  Created by liuding on 2018/12/3.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit

class ResourceTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var resourceImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        resourceImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
}
