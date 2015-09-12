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
    var defSource: String?
    var defTarget = "en"
    var translator: FGTranslator!
    
    init() {
        //FGTranslator.flushCache() - could be needed to free memory/don't keep the search history
        FGTranslator.flushCredentials()
        defSource = nil
        translator = FGTranslator(bingAzureClientId: kAZ_KEY, secret: kAZ_SECRET)
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
    
    func supportedLanguages(completion: ((NSError!, [AnyObject]!) -> Void)!) {
        let translator = FGTranslator(bingAzureClientId: kAZ_KEY, secret: kAZ_SECRET)
        translator.supportedLanguages(completion)
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
}
