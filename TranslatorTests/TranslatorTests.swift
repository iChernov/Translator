//
//  TranslatorTests.swift
//  TranslatorTests
//
//  Created by IVAN CHERNOV on 11/09/15.
//  Copyright (c) 2015 IVAN CHERNOV. All rights reserved.
//

import UIKit
import XCTest

class TranslatorTests: XCTestCase {
    
    var translator: Translator!
    
    override func setUp() {
        super.setUp()
        translator = Translator()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDefaultLanguages() {
        XCTAssertEqual(translator.currentSourceLanguage(), "Auto", "Default source language should be Auto")
        XCTAssertEqual(translator.currentTargetLanguage(), "English", "Default target language should be English")
    }
    
    func testLanguageDetection() {
        var expectation = self.expectationWithDescription("Waiting for lang detection")
        translator.detectLanguage("Guten Tag", customCompletion: { (err: NSError!, detectedSource: String!, relevance: Float) -> Void in
            XCTAssertEqual(detectedSource, "de", "Detected language should be german")
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5.0, handler: { (err: NSError!) -> Void in
            if(err != nil) {
                XCTAssert(false, err.description)
            }
        })
    }
    
    func testLanguageTranslation() {
        var expectation = self.expectationWithDescription("Waiting for translation")
        translator.translate("Guten Tag", customCompletion: { (err: NSError!, translation: String!, source: String!) -> Void in
            XCTAssertEqual(translation, "Good day", "Translation should be Good day")
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(5.0, handler: { (err: NSError!) -> Void in
            if(err != nil) {
                XCTAssert(false, err.description)
            }
        })
    }
    
    func testSupportedLanguages() {
        var expectation = self.expectationWithDescription("Waiting for list of supported languages")
        translator.supportedLanguages { (receivedList: [String]?) -> Void in
            if let listOfLanguages = receivedList {
                XCTAssertTrue(count(listOfLanguages) > 0, "No suported languages detected")
            } else {
                XCTAssert(false, "No suported languages detected")
            }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: { (err: NSError!) -> Void in
            if(err != nil) {
                XCTAssert(false, err.description)
            }
        })
    }
}
