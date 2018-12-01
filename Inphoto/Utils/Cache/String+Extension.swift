//
//  String+Extension.swift
//  Inphoto
//
//  Created by liuding on 2018/12/1.
//  Copyright © 2018 eastree. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    func md5String() -> String {
        guard let messageData = self.data(using:.utf8) else {
            return self
        }
        
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = digestData.withUnsafeMutableBytes { digestBytes in
            messageData.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        let md5 = digestData.base64EncodedString()
        return md5
    }
}
