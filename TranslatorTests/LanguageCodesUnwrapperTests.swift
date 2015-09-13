//
//  LanguageCodesUnwrapperTests.swift
//  Translator
//
//  Created by IVAN CHERNOV on 13/09/15.
//  Copyright (c) 2015 IVAN CHERNOV. All rights reserved.
//

import UIKit
import XCTest

class LanguageCodesUnwrapperTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLanguageDecoding() {
        XCTAssertTrue(LangUnwrapper.getLanguage("abc") == nil, "Only valid language codes should pass")

        if let unwrappedLanguage = LangUnwrapper.getLanguage("en") {
            XCTAssertEqual(unwrappedLanguage, "English", "Decoded language does not match the provided code")
        } else {
            XCTAssert(false, "Decoded language should not be nil")
        }
    }
    
    func testLanguageEncoding() {
        XCTAssertEqual(LangUnwrapper.getCode("English"), "en", "Language code does not match the provided code")
    }
}
