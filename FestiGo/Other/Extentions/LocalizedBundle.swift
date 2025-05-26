//
//  LocalizedBundle.swift
//  FestiGo
//
//  Created by kisellsn on 19/05/2025.
//


import Foundation

private var bundleKey: UInt8 = 0

class LocalizedBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
              let bundle = Bundle(path: path) else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }

        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, LocalizedBundle.self)
        }

        let isLanguageAvailable = Bundle.main.path(forResource: language, ofType: "lproj") != nil
        let languagePath = isLanguageAvailable ? Bundle.main.path(forResource: language, ofType: "lproj") : nil
        objc_setAssociatedObject(Bundle.main, &bundleKey, languagePath, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}