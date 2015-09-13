//
//  Translator.swift
//  Translator
//
//  Created by IVAN CHERNOV on 12/09/15.
//  Copyright (c) 2015 IVAN CHERNOV. All rights reserved.
//

import Foundation
import FGTranslator

class Translator {
    
    let kAZ_KEY = "iChernovTranslator"
    let kAZ_SECRET = "h6fYU65MiUEkhoUA8kHfgz9rzDM7wpXQWPvW+PGrb+E="
    let maxRetryCount = 3
    
    var defSource: String?
    var defTarget = "en"
    var translator: FGTranslator!
    var languagesList: [String]?
    var langListLoaded = false
    
    init() {
        //FGTranslator.flushCache() - we can use it to remove user's history every time the app relaunches
        //FGTranslator.flushCredentials() - in future could be used to erase credentials, if needed
        defSource = nil
        translator = FGTranslator(bingAzureClientId: kAZ_KEY, secret: kAZ_SECRET)
        self.loadSupportLanguages(1, completion:nil)
    }
    
    func detectLanguage(text: String!, customCompletion: ((NSError!, String!, Float) -> Void)!)
    {
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            self.translator.detectLanguage(text, completion: { (err: NSError!, detectedSource: String!, confidence: Float) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    customCompletion(err, detectedSource, confidence)
                })
            })
        })
    }
    
    func translate(text: String!, customCompletion: ((NSError!, String!, String!) -> Void)!)
    {
        if(self.defSource != nil && self.defSource! == self.defTarget) {
            customCompletion(nil, text, self.defSource)
            return
        }
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            self.translator.translateText(text, withSource: self.defSource, target: self.defTarget, completion: { (err: NSError!, translation: String!, source: String!) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    customCompletion(err, translation, source)
                })
            })
        })
    }
    
    func supportedLanguages(completion: (([String]?) -> Void)!) {
        if(self.langListLoaded) {
            completion(self.languagesList)
        } else {
            self.loadSupportLanguages(1, completion: completion)
        }
    }
    
    func currentSourceLanguage() -> String {
        if (self.defSource != nil) {
            return NSLocale(localeIdentifier: "en").displayNameForKey(NSLocaleIdentifier, value: self.defSource!) ?? "Auto"
        }
        return "Auto"
    }
    
    func currentTargetLanguage() -> String {
        return NSLocale(localeIdentifier: "en").displayNameForKey(NSLocaleIdentifier, value: self.defTarget) ?? "Not defined"
    }
    
    // MARK: private methods
    
    private func loadSupportLanguages(try: Int, completion:(([String]?) -> Void)?) {
        if(try < self.maxRetryCount) {
            var suppLanguagesDetector = FGTranslator(bingAzureClientId: kAZ_KEY, secret: kAZ_SECRET)
            suppLanguagesDetector.supportedLanguages { (err: NSError!, listOfLangs:[AnyObject]!) -> Void in
                if(err == nil) {
                    self.languagesList = listOfLangs as? [String]
                    self.langListLoaded = (self.languagesList != nil)
                    if(completion != nil) {
                        var realCompletion = completion!
                        realCompletion(self.languagesList)
                    }
                } else {
                    self.loadSupportLanguages(try + 1, completion: completion)
                }
            }
        } else {
            self.languagesList = nil
            self.langListLoaded = false
        }
    }
}
