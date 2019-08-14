//
//  ExtensionsTests.swift
//  ExtensionsTests
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//
//  ---------------------------------------------------------------------------
//
//  © 2019 Atypon Systems LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import XCTest
import Foundation
import Extensions

extension String {
    func stringAroundOccurrence(ofString str:String, maxPadding:UInt, options:NSString.CompareOptions = []) -> String? {
        guard let range = self.range(of: str, options:options, range: nil, locale: nil) else {
            return nil
        }

        let p = Int(maxPadding)
        
        let r = (self.index(range.lowerBound, offsetBy: -p, limitedBy: self.startIndex) ?? self.startIndex)
                ..<
                (self.index(range.upperBound, offsetBy: p, limitedBy: self.endIndex) ?? self.endIndex)
        
        return String(self[r])
    }
}

class ExtensionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        UserDefaults.standard.set(true, forKey: "WebKitDeveloperExtras")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testXMLNodeSplitting() {
        let textNode = XMLNode(kind: .text)
        textNode.stringValue = "foo bar baz"
        
        let splitAtFooNodes = textNode.split(atIndex: 3)
        let splitAtFoo = [splitAtFooNodes.0.stringValue!, splitAtFooNodes.1.stringValue!]
        
        XCTAssertEqual(splitAtFoo, ["foo", " bar baz"], "Unexpected split position: \(splitAtFoo)")
        
        let splitNodes = textNode.split(atIndices: [3, 4, 7, 8])
        let splitStringValues = splitNodes.map { $0.stringValue! }
        
        XCTAssertEqual(splitStringValues, ["foo", " ", "bar", " ", "baz"], "Unexpected splits: \(splitStringValues)")
    }
    
    func testXMLElementExtraction() {
        let str = "foobarbaz"
        let doc = try! XMLDocument(xmlString: "<p>\(str)</p>", options: Extensions.defaultXMLDocumentParsingOptions)
        let elem = doc.rootElement()!
        XCTAssertTrue(elem.name == "p")
        XCTAssertTrue(elem.children!.first!.stringValue == str)
        
        let range = elem.stringValue!.index(elem.stringValue!.startIndex, offsetBy: 3) ..< elem.stringValue!.index(elem.stringValue!.startIndex, offsetBy: 6)
        XCTAssertTrue(String(elem.stringValue?[range] ?? "") == "bar", "Got my arithmetic wrong.")
        XCTAssertTrue(elem.children!.count == 1)
        XCTAssertTrue(elem.children!.first!.kind == .text)
        
        let splitNodes = elem.children!.first!.extract(elementWithName:"strong", range:3 ..< 6)
        
        XCTAssertTrue(splitNodes.before.stringValue == "foo")
        XCTAssertTrue(splitNodes.after.stringValue == "baz")
        XCTAssertTrue(splitNodes.extracted.name == "strong")
    }
    
    func testSimpleMultipleXMLElementExtraction() {
        let str = "foobarbaz"
        let doc = try! XMLDocument(xmlString: "<p>\(str)</p>", options: Extensions.defaultXMLDocumentParsingOptions)
        let elem = doc.rootElement()!
        XCTAssertTrue(elem.name == "p")
        XCTAssertTrue(elem.children!.first!.stringValue == str)
        
        let splitNodes = elem.children!.first!.extract(elementsWithName:"strong", ranges: [3 ..< 6])
        
        XCTAssertTrue(splitNodes[0].xmlString == "foo")
        XCTAssertTrue(splitNodes[1].xmlString == "<strong>bar</strong>", "Unexpected string value: \(String(describing: splitNodes[1].stringValue))")
        XCTAssertTrue(splitNodes[2].xmlString == "baz")
    }
    
    func testComplexMultipleXMLElementExtractions() {
        let str = "foobarbazadoo"
        let doc = try! XMLDocument(xmlString: "<p>\(str)</p>", options: Extensions.defaultXMLDocumentParsingOptions)
        let elem = doc.rootElement()!
        XCTAssertTrue(elem.name == "p")
        XCTAssertTrue(elem.children!.first!.stringValue == str)
        
        let splitNodes = elem.children!.first!.extract(elementsWithName:"em", ranges: [2 ..< 4, 5 ..< 6, 7 ..< 9])
        
        let firstElemSubstr = String(str[elem.stringValue!.index(elem.stringValue!.startIndex, offsetBy: 2) ..< elem.stringValue!.index(elem.stringValue!.startIndex, offsetBy: 4)])
        XCTAssertTrue(firstElemSubstr == "ob")
        
        let secondElemSubstr = String(str[elem.stringValue!.index(elem.stringValue!.startIndex, offsetBy: 5) ..< elem.stringValue!.index(elem.stringValue!.startIndex, offsetBy: 6)])
        XCTAssertTrue(secondElemSubstr == "r")
        
        let thirdElemSubstr = String(str[elem.stringValue!.index(elem.stringValue!.startIndex, offsetBy: 7) ..< elem.stringValue!.index(elem.stringValue!.startIndex, offsetBy: 9)])
        XCTAssertTrue(thirdElemSubstr == "az")

        // foobarbazadoo
        // fo|ob|a|r|b|az|adoo
        XCTAssertTrue(splitNodes[0].xmlString == "fo")
        XCTAssertTrue(splitNodes[1].xmlString == "<em>ob</em>", "Unexpected string value: \(String(describing: splitNodes[1].stringValue))")
        XCTAssertTrue(splitNodes[2].xmlString == "a")
        XCTAssertTrue(splitNodes[3].xmlString == "<em>r</em>")
        XCTAssertTrue(splitNodes[4].xmlString == "b")
        XCTAssertTrue(splitNodes[5].xmlString == "<em>az</em>")
    }

    func testComponentsSeparated() {
        let str = "foogbargbaz"
        let tokenizedComponents = str.componentsSeparated(tokenizingPatterns: ["g"])
        let noComponents = str.componentsSeparated(tokenizingPatterns: ["q"])

        XCTAssertEqual(tokenizedComponents, ["foo", "bar", "baz"])
        XCTAssertEqual(noComponents, [str])
    }

    func testComponentsCaptured() {
        let str = "foogbargbaz"
        let capturedComponents = str.componentsCaptured(capturingPatterns: [".g"])
        let noComponents = str.componentsCaptured(capturingPatterns: [".q"])

        XCTAssertEqual(capturedComponents, ["og", "rg"])
        XCTAssertEqual(noComponents, [])
    }

    func testCapturedRanges() {
        let str = "foogbargbaz"
        let capturedRanges = str.capturedRanges(capturingPatterns: [".g"])
        let noRanges = str.capturedRanges(capturingPatterns: [".q"])

        XCTAssertEqual(capturedRanges, [str.range(of: "og"),
                                        str.range(of: "rg")])
        XCTAssertEqual(noRanges, [])
    }
}
