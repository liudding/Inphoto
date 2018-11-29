//
//  PhotoCollectionViewCell.swift
//  Inphoto
//
//  Created by liuding on 2018/10/23.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import PhotosUI

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var livePhotoBadgeImageView: UIImageView!
    
    var assetIdentifier: String!
    
    var isLivePhoto: Bool! {
        didSet {
            if isLivePhoto {
                livePhotoBadgeImageView.image = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
        livePhotoBadgeImageView.image = nil
    }
}
