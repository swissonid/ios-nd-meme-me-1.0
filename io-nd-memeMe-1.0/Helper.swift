//
//  FileHelper.swift
//  io-nd-memeMe-1.0
//
//  Created by Patrice Müller on 22.10.16.
//  Copyright © 2016 swissonid. All rights reserved.
//

import Foundation

enum TranslationKey: String {
    case placeholder_toptext
    case placeholder_bottomtext
    case label_album
    case label_cancel
    case label_share
    
}

func getString(_ key: TranslationKey) -> String {
    return NSLocalizedString(key.rawValue, comment: "NO COMMENT")
}


class FileHelper {
    static func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = path[0]
        return documentsDirectory
    }
    
    static func hasMemeSaved() -> Bool {
        return false
    }
}
