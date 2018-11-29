//
//  Album.swift
//  Inphoto
//
//  Created by liuding on 2018/11/23.
//  Copyright © 2018 eastree. All rights reserved.
//

import UIKit
import Photos

struct Album {
    var title: String = ""
    var thumbnail: UIImage?
    var itemsCount: Int = 0
    var collection: PHAssetCollection?
}
