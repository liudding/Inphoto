//
//  AlbumTableViewCell.swift
//  Inphoto
//
//  Created by liuding on 2018/10/23.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
