//
//  LanguageCodesUnwrapper.swift
//  Translator
//
//  Created by IVAN CHERNOV on 13/09/15.
//  Copyright (c) 2015 IVAN CHERNOV. All rights reserved.
//

import Foundation

class LangUnwrapper {
    static var defEnglish = true // future localizations could use default locale
    
    class func getCode(language: String!) -> String {
        return NSLocale.canonicalLanguageIdentifierFromString(language)
    }
    
    class func getLanguage(langCode: String!) -> String?{
        if(defEnglish) {
            return NSLocale(localeIdentifier: "en").displayNameForKey(NSLocaleIdentifier, value: langCode)
        } else {
            return NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: langCode)
        }
    }
    
    class func getLanguages(langCodes: [String]) -> [String] {
        var languagesList = [String]()
        for code in langCodes {
            var language: String?
            if(defEnglish) {
                language = NSLocale(localeIdentifier: "en").displayNameForKey(NSLocaleIdentifier, value: code)
            } else {
                language = NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: code)
            }
            if(language != nil) {
                languagesList.append(language!)
            }
        }
        languagesList.sorted{ $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedDescending }
        
        return languagesList
    }
}