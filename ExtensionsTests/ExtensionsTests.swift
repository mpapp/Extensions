//
//  ExtensionsTests.swift
//  ExtensionsTests
//
//  Created by Matias Piipari on 06/04/2016.
//  Copyright © 2016 Manuscripts.app Limited. All rights reserved.
//

import XCTest
import Foundation
import Extensions
import OHHTTPStubs

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
    
    fileprivate var debugWindowController:EvaluatorDebugWindowController?
    
    override func setUp() {
        super.setUp()

        UserDefaults.standard.set(true, forKey: "WebKitDeveloperExtras")
        //_ = EvaluatorDebugWindowController.sharedInstance()

        let bundleURL = Bundle(for: type(of: self)).bundleURL
        try! ExtensionRegistry.sharedInstance.loadExtensions(bundleURL, loadFailureHandler:{ (url, extensionError) in
            XCTFail("Load failure (URL: \(url), error: \(extensionError)")
        })
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoadingWebKitExtension() {
        let extensions = ExtensionRegistry.sharedInstance.extensionSet
        XCTAssertTrue(extensions.count > 0, "No extensions have been loaded.")
        
        let ext = try! ExtensionRegistry.sharedInstance.extensionWithIdentifier("com.manuscriptsapp.JSExample")
        
        XCTAssertTrue(ext.procedures.count == 2, "Unexpected procedure count: \(ext.procedures.count) != 2")
        
        let exp = expectation(description: "Evaluation ended successfully.")
        
        do {
            try ext.evaluate(Processable.stringData("foo"), procedureHandler: { _,_ in
                //print("Input \($0) -> Output:\($1)")
                exp.fulfill()
            }, errorHandler: { err in
                XCTFail("Evaluation error: \(err)")
            })
        }
        catch {
            XCTFail("Unexpected evaluation error: \(error)")
        }

        waitForExpectations(timeout: 11.0) { (err:Error?) in
            XCTAssertNil(err, "Unexpected error \(String(describing:err))")
        }
    }
    
    func testResolvingPMIDIdentifier() {
        stub(condition: isHost("eutils.ncbi.nlm.nih.gov")) { (_) in
            let stubPath = OHPathForFile("1304383.pubmed-xml", type(of: self))!
            return fixture(filePath: stubPath, headers: [:])
        }
        
        let pdb = ResolvableElementProcessor(resolver: PubMedResolver(), tokenizingPatterns: [], capturingPatterns:[PubMedIdentifier.capturingPattern()])
        let docP = ResolvingDocumentProcessor(resolver: PubMedResolver(), elementProcessors: [pdb])
        
        let URL:Foundation.URL = Bundle(for: type(of: self)).url(forResource: "PMID-reference-example", withExtension: "html")!
        
        var doc:XMLDocument? = nil
        do {
            doc = try XMLDocument(contentsOf: URL, options: Extensions.defaultXMLDocumentOutputOptions.union(.documentTidyHTML))
        }
        catch {
            XCTFail("Failed to initialize test document from URL \(URL).")
        }
        
        var count = 0
        do {
            _ = try docP.processedDocument(inputDocument: doc!, inPlace: true, resultHandler: { _, capturedResultRanges in
                for resultRange in capturedResultRanges {
                    
                    XCTAssert(resultRange.result.resolvable.originatingString.hasPrefix("PMID:"))
                    
                    switch resultRange.result.result {
                    case .bibliographyItems(let items):
                        count += 1
                        XCTAssert(items.count == 1, "Unexpected number of items resolved: \(items)")
                        XCTAssert(items.first?.title == "Crystal structure of a complex of HIV-1 protease with a dihydroxyethylene-containing inhibitor: comparisons with molecular modeling.", "Unexpected title: '\(String(describing: items.first?.title))'")
                    default:
                        XCTFail("Failed to resolve a bibliography item for \(resultRange)")
                    }
                    print("Result range:\(resultRange)")
                }
            })
        }
        catch {
            XCTFail("Failed to process document from URL \(URL).")
        }
        
        XCTAssert(count > 0, "No parsing events fired.")
    }
    
    func testResolvingPDBIdentifier() {
        stub(condition: isHost("www.rcsb.org")) { (_) in
            let stubPath = OHPathForFile("1HIV.rcsb-xml", type(of: self))!
            return fixture(filePath: stubPath, headers: [:])
        }
        
        stub(condition: isHost("eutils.ncbi.nlm.nih.gov")) { (_) in
            let stubPath = OHPathForFile("1304383.pubmed-xml", type(of: self))!
            return fixture(filePath: stubPath, headers: [:])
        }
        
        let pdb = ResolvableElementProcessor(resolver: ProteinDataBankResolver(), tokenizingPatterns: [], capturingPatterns:[ProteinDataBankIdentifier.capturingPattern()], replaceMatches: true)
        let docP = ResolvingDocumentProcessor(resolver: ProteinDataBankResolver(), elementProcessors: [pdb])
        
        let URL:Foundation.URL = Bundle(for: type(of: self)).url(forResource: "biolit", withExtension: "html")!
        
        var count = 0
        var doc:XMLDocument? = nil
        do {
            doc = try XMLDocument(contentsOf: URL, options: Extensions.defaultXMLDocumentOutputOptions.union(.documentTidyHTML))
        }
        catch {
            XCTFail("Failed to initialize test document from URL \(URL).")
        }
        
        var elementEncounters = 0
        do {
            _ = try docP.processedDocument(inputDocument: doc!, inPlace: true, resultHandler: { _, capturedResultRanges in
                count += 1
                for resultRange in capturedResultRanges {
                    switch resultRange.result.result {
                    case .bibliographyItems(let items):
                        XCTAssert(items.count == 1, "Unexpected number of items resolved: \(items)")
                        XCTAssert(items.first?.title == "Crystal structure of a complex of HIV-1 protease with a dihydroxyethylene-containing inhibitor: comparisons with molecular modeling.", "Unexpected title: '\(String(describing: items.first?.title))'")
                    default:
                        XCTFail("Failed to resolve a bibliography item for \(resultRange)")
                    }
                    print("Result range:\(resultRange)")
                }
            }, elementRepresentationProvider: { (elementProcessor:ResolvableElementProcessor, capturedResultRange:CapturedResultRange, textNode) -> Element in
                elementEncounters += 1
                let elem = SimpleInlineElement(contents: String(textNode.stringValue![capturedResultRange.ranges[0]]), tagName: "span")
                return elem
            })
        }
        catch {
            XCTFail("Failed to process document from URL \(URL):\(error)")
        }
        
        XCTAssert(elementEncounters > 0)
        XCTAssert(count > 0)
    }
    
    func testResolvingDOI1() {
        stub(condition: isHost("dx.doi.org")) { (_) in
            let stubPath = OHPathForFile("10.1038-nrd842.citeproc-json", type(of: self))!
            return fixture(filePath: stubPath, headers: [:])
        }
        
        let DOIResolver = DigitalObjectIdentifierResolver()
        
        switch try! DOIResolver.resolve("10.1038/nrd84").result {
        case .bibliographyItems(let items):
            XCTAssert(items.count == 1, "Unexpected item count \(items.count)")
        default:
            XCTFail("Failed to parse bibliography items.")
        }
        
        var count = 0
        let DOIProcessor = ResolvableElementProcessor(resolver: DOIResolver,
                                                      tokenizingPatterns: [],
                                                      capturingPatterns:[DigitalObjectIdentifier.capturingPattern()],
                                                      replaceMatches: true)
        let docP = ResolvingDocumentProcessor(resolver: DOIResolver, elementProcessors: [DOIProcessor])
        
        var doc:XMLDocument? = nil
        let URL:Foundation.URL = Bundle(for: type(of: self)).url(forResource: "biolit", withExtension: "html")!
        do { doc = try XMLDocument(contentsOf: URL, options: Extensions.defaultXMLDocumentOutputOptions.union(.documentTidyHTML)) }
        catch { XCTFail("Failed to initialize test document from URL \(URL).") }
        
        var elementEncounters = 0
        do {
            _ = try docP.processedDocument(inputDocument: doc!, inPlace: true,
                                       resultHandler: { _, capturedResultRanges in
                                                            count += 1
                                                            for resultRange in capturedResultRanges {
                                                                switch resultRange.result.result {
                                                                case .bibliographyItems(let items):
                                                                    XCTAssert(items.count == 1, "Unexpected number of items resolved: \(items)")
                                                                    XCTAssert(items.first?.title == "From the analyst\'s couch: Selective anticancer drugs", "Unexpected title: '\(String(describing: items.first?.title))'")
                                                                default:
                                                                    XCTFail("Failed to resolve a bibliography item for \(resultRange)")
                                                                }
                                                                print("Result range: \(resultRange)")
                                                            }
                                                        },
                                       elementRepresentationProvider: { (elementProcessor:ResolvableElementProcessor, capturedResultRange:CapturedResultRange, textNode) -> Element in
                                            elementEncounters += 1
                                            let elem = SimpleInlineElement(contents: String(textNode.stringValue![capturedResultRange.ranges[0]]), tagName: "span")
                                            return elem
                                       })
        }
        catch {
            XCTFail("Failed to process document from URL \(URL).")
        }
        
        XCTAssert(elementEncounters > 0)
        XCTAssert(count > 0)
    }
    
    func testResolvingDOI2() {
        stub(condition: isHost("dx.doi.org")) { (_) in
            let stubPath = OHPathForFile("10.1002-0470841559.ch1.citeproc-json", type(of: self))!
            return fixture(filePath: stubPath, headers: [:])
        }
        
        let DOIResolver = DigitalObjectIdentifierResolver()
        
        switch try! DOIResolver.resolve("10.1002/0470841559.ch1").result {
        case .bibliographyItems(let items):
            XCTAssert(items.count == 1, "Unexpected item count \(items.count)")
        default:
            XCTFail("Failed to parse bibliography items.")
        }
        
        var count = 0
        let DOIProcessor = ResolvableElementProcessor(resolver: DOIResolver,
                                                      tokenizingPatterns: [],
                                                      capturingPatterns:[DigitalObjectIdentifier.capturingPattern()],
                                                      replaceMatches: true)
        let docP = ResolvingDocumentProcessor(resolver: DOIResolver, elementProcessors: [DOIProcessor])
        
        var doc:XMLDocument? = nil
        let URL:Foundation.URL = Bundle(for: type(of: self)).url(forResource: "biolit", withExtension: "html")!
        do { doc = try XMLDocument(contentsOf: URL, options: Extensions.defaultXMLDocumentOutputOptions.union(.documentTidyHTML)) }
        catch {
            XCTFail("Failed to initialize test document from URL \(URL).")
        }
        
        var elementEncounters = 0
        do {
            _ = try docP.processedDocument(inputDocument: doc!, inPlace: true,
                                       resultHandler: { _, capturedResultRanges in
                                        count += 1
                                        for resultRange in capturedResultRanges {
                                            switch resultRange.result.result {
                                            case .bibliographyItems(let items):
                                                XCTAssert(items.count == 1, "Unexpected number of items resolved: \(items)")
                                                
                                                if let item = items.first {
                                                    XCTAssert(item.title == "Network Concepts", "Unexpected title: '\(String(describing: item.title))'")
                                                    
                                                    XCTAssertEqual(item.DOI!, "10.1002/0470841559.ch1", "Unexpected DOI: '\(String(describing: item.DOI))'")
                                                    XCTAssertEqual(item.URL!, Foundation.URL(string:"http://dx.doi.org/10.1002/0470841559.ch1"), "Unexpected URL: '\(String(describing: item.URL))'")
                                                    XCTAssertEqual(item.containerTitle, "Internetworking LANs and WANs", "Unexpected container title: \(String(describing: item.containerTitle))")
                                                    XCTAssert(item.publisher! == "Wiley-Blackwell", "Unexpected publisher: '\(String(describing: item.publisher))'")
                                                }
                                            default:
                                                XCTFail("Failed to resolve a bibliography item for \(resultRange)")
                                            }
                                            print("Result range: \(resultRange)")
                                        }
                },
                                       elementRepresentationProvider: { (elementProcessor:ResolvableElementProcessor, capturedResultRange:CapturedResultRange, textNode) -> Element in
                                        elementEncounters += 1
                                        let elem = SimpleInlineElement(contents: String(textNode.stringValue![capturedResultRange.ranges[0]]), tagName: "span")
                                        return elem
            })
        }
        catch {
            XCTFail("Failed to process document from URL \(URL).")
        }
        
        XCTAssert(elementEncounters > 0)
        XCTAssert(count > 0)
    }
    
    func testResolvingDOI3() {
        stub(condition: isHost("dx.doi.org")) { (_) in
            let stubPath = OHPathForFile("10.13039-100000054.citeproc-json", type(of: self))!
            return fixture(filePath: stubPath, headers: [:])
        }
        
        let DOIResolver = DigitalObjectIdentifierResolver()
        
        switch try! DOIResolver.resolve("10.13039/100000054").result {
        case .bibliographyItems(let items):
            XCTAssert(items.count == 1, "Unexpected item count \(items.count)")
        default:
            XCTFail("Failed to parse bibliography items.")
        }
        
        var count = 0
        let DOIProcessor = ResolvableElementProcessor(resolver: DOIResolver,
                                                      tokenizingPatterns: [],
                                                      capturingPatterns:[DigitalObjectIdentifier.capturingPattern()],
                                                      replaceMatches: true)
        let docP = ResolvingDocumentProcessor(resolver: DOIResolver, elementProcessors: [DOIProcessor])
        
        var doc:XMLDocument? = nil
        let URL:Foundation.URL = Bundle(for: type(of: self)).url(forResource: "biolit", withExtension: "html")!
        
        do { doc = try XMLDocument(contentsOf: URL, options: Extensions.defaultXMLDocumentOutputOptions.union(.documentTidyHTML)) }
        catch { XCTFail("Failed to initialize test document from URL \(URL).") }
        
        var elementEncounters = 0
        do {
            _ = try docP.processedDocument(inputDocument: doc!, inPlace: true,
                                       resultHandler: { _, capturedResultRanges in
                                        count += 1
                                        for resultRange in capturedResultRanges {
                                            switch resultRange.result.result {
                                            case .bibliographyItems(let items):
                                                XCTAssert(items.count == 1, "Unexpected number of items resolved: \(items)")
                                                
                                                if let item = items.first {
                                                    XCTAssert(item.title == "Understanding how perceptions of tobacco constituents and the FDA relate to effective and credible tobacco risk messaging: A national phone survey of U.S. adults, 2014–2015", "Unexpected title: '\(String(describing: item.title))'")
                                                    
                                                    XCTAssertEqual(item.DOI!, "10.1186/s12889-016-3151-5", "Unexpected DOI: '\(String(describing: item.DOI))'")
                                                    XCTAssertEqual(item.URL!, Foundation.URL(string:"http://dx.doi.org/10.1186/s12889-016-3151-5"), "Unexpected URL: '\(item.URL!)'")
                                                    XCTAssertEqual((item.issued!.dateParts! as NSArray) as! [NSArray], [[2016, 6, 23]] as [NSArray], "Unexpected date parts: \(item.issued!)")
                                                    XCTAssert(item.publisher! == "Springer Nature", "Unexpected publisher: '\(String(describing: item.publisher))'")
                                                }
                                            default:
                                                XCTFail("Failed to resolve a bibliography item for \(resultRange)")
                                            }
                                            print("Result range: \(resultRange)")
                                        }
                },
                                       elementRepresentationProvider: { (elementProcessor:ResolvableElementProcessor, capturedResultRange:CapturedResultRange, textNode) -> Element in
                                        elementEncounters += 1
                                        let elem = SimpleInlineElement(contents: String(textNode.stringValue![capturedResultRange.ranges[0]]), tagName: "span")
                                        return elem
            })
        }
        catch {
            XCTFail("Failed to process document from URL \(URL).")
        }
        
        XCTAssert(elementEncounters > 0)
        XCTAssert(count > 0)
    }
    
    func testResolvingMarkdown() {
        do { _ = try MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownAsteriskStrong.self).resolve("**foobar**") }
        catch (let error) { XCTFail("Error: \(error)") }
        
        do { _ = try MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownAsteriskEmphasis.self).resolve("*foobar*") }
        catch (let error) { XCTFail("Error: \(error)") }
        
        do { _ = try MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownUnderscoreStrong.self).resolve("__foobar__") }
        catch (let error) { XCTFail("Error: \(error)") }
        
        do { _ = try MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownUnderscoreEmphasis.self).resolve("_foobar_") }
        catch (let error) { XCTFail("Error: \(error)") }
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
    
    func testProcessingMarkdown() {
        let resolvers:[Resolver] = [ MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownAsteriskStrong.self),
                                     MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownUnderscoreStrong.self),
                                     MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownAsteriskEmphasis.self),
                                     MarkdownSyntaxComponentResolver(markdownComponentType:MarkdownUnderscoreEmphasis.self) ]
        
        var encounteredIDs:Set<String> = []
        
        let docP = ResolvingCompoundDocumentProcessor(resolvers: resolvers, replaceMatches: true)
        
        var doc:XMLDocument? = nil
        let URL:Foundation.URL = Bundle(for: type(of: self)).url(forResource: "biolit", withExtension: "html")!
        do { doc = try XMLDocument(contentsOf: URL, options: Extensions.defaultXMLDocumentOutputOptions.union(.documentTidyHTML)) }
        catch { XCTFail("Failed to initialize test document from URL \(URL).") }
        
        _ = try! docP.processedDocument(inputDocument: doc!, inPlace: true, resultHandler: { (elementProcessor, capturedResultRanges) in
            
            for range in capturedResultRanges {
                switch range.result.result {
                case .inlineElements(let elems):
                    guard let resolvable = range.result.resolvable as? MarkdownSyntaxComponent else {
                        XCTFail("Resolvable is unexpectedly not a MarkdownSyntaxComponent: \(range.result.resolvable).")
                        break
                    }
                    
                    XCTAssert(elems.count == 1, "Unexpected inline element count: \(elems)")
                    
                    encounteredIDs.insert(resolvable.identifier)
                    
                    switch resolvable.identifier {
                    case "**delivers**":
                        XCTAssert(resolvable.innerHTML == "delivers", "Unexpected innerHTML: \(resolvable.innerHTML).")
                        XCTAssert(resolvable.tagName == "strong", "Unexpected tagName: \(resolvable.tagName).")
                        
                    case "__that__":
                        XCTAssert(resolvable.innerHTML == "that", "Unexpected innerHTML: \(resolvable.innerHTML).")
                        XCTAssert(resolvable.tagName == "strong", "Unexpected tagName: \(resolvable.tagName).")
                        
                    case "*resource*":
                        XCTAssert(resolvable.innerHTML == "resource", "Unexpected innerHTML: \(resolvable.innerHTML).")
                        XCTAssert(resolvable.tagName == "em", "Unexpected tagName: \(resolvable.tagName).")
                        
                    case "_semantically_":
                        XCTAssert(resolvable.innerHTML == "semantically", "Unexpected innerHTML: \(resolvable.innerHTML).")
                        XCTAssert(resolvable.tagName == "em", "Unexpected tagName: \(resolvable.tagName).")
                        
                    default:
                        break
                    }
                    
                case .bibliographyItems(_):
                    break
                    
                default:
                    XCTFail("There should be no failed resolve calls.")
                }
            }
        })
        
        for identifier in ["**delivers**", "__that__", "*resource*", "_semantically_"] {
            XCTAssert(encounteredIDs.contains(identifier), "Failed to resolve identifier \(identifier)")
        }
        
        let paddedBy2 = "foobar123foobar".stringAroundOccurrence(ofString: "123", maxPadding: 2)
        let paddedBy12 = "foobar123foobar".stringAroundOccurrence(ofString: "123", maxPadding: 12)
        XCTAssert(paddedBy2 == "ar123fo", "String matching")
        XCTAssert(paddedBy12 == "foobar123foobar", "String matching")
        
        XCTAssert("foobarfoobar".ranges("foobar").count == 2, "String.ranges is not behaving as expected")
        
        let xmlStr = doc?.xmlString(options: Extensions.defaultXMLDocumentOutputOptions)
        
        XCTAssert(xmlStr!.contains("<em>"), "XML string contains no instances of <em>")
        print(xmlStr!.stringAroundOccurrence(ofString: "delivers", maxPadding: 9) == " <strong>delivers</strong>")
    }
    
    func testElementHTMLSnippetRepresentation() {
        let snippetRep = SimpleInlineElement(contents: "foo", tagName: "span", attributes: ["id":"bar"]).HTMLSnippetRepresentation
        XCTAssert(snippetRep == "<span id=\"bar\">foo</span>")
        
    }
}
