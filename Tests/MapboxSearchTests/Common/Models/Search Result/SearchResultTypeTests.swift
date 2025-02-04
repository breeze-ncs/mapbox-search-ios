import XCTest
@testable import MapboxSearch
import CwlPreconditionTesting

class SearchResultTypeTests: XCTestCase {

    func testAddressCaseAssociatedValues() throws {
        XCTAssertEqual(SearchResultType.address(subtypes: [.country, .place, .street]).addressSubtypes, [.country, .place, .street])
    }
    
    func testPOICaseMissingAssociatedAddressValues() {
        XCTAssertNil(SearchResultType.POI.addressSubtypes)
    }
    
    func testPOIInit() {
        XCTAssertEqual(SearchResultType(coreResultTypes: [.poi]), .POI)
    }
    
    func testMixedPOIInit() throws {
        #if !arch(x86_64)
        throw XCTSkip("Unsupported architecture")
        #else
        
        let assertionError = catchBadInstruction {
            _ = SearchResultType(coreResultTypes: [.poi, .place])
        }
        XCTAssertNotNil(assertionError)
        
        #endif
    }
    
    func testAddressInit() {
        XCTAssertEqual(SearchResultType(coreResultTypes: [.place, .country])?.addressSubtypes,
                       [.place, .country])
    }
    
    func testAddressWithPOIInit() throws {
        #if !arch(x86_64)
        throw XCTSkip("Unsupported architecture")
        #else
        
        let assertionError = catchBadInstruction {
            _ = SearchResultType(coreResultTypes: [.place, .unknown])
        }
        XCTAssertNotNil(assertionError)
        
        #endif
    }
    
    func testInappropriateTypesInInit() {
        XCTAssertNil(SearchResultType(coreResultTypes: [.category]))
    }
}

// MARK: Codable tests

extension SearchResultTypeTests {
    func testPOICodableConversion() throws {
        let object = SearchResultType.POI
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        
        let decoder = JSONDecoder()
        let decodedObject = try decoder.decode(SearchResultType.self, from: data)
        
        XCTAssertEqual(decodedObject, object)
    }
    
    func testAddressCodableConversion() throws {
        let object = try XCTUnwrap(SearchResultType(coreResultTypes: CoreResultType.allAddressTypes))
        
        XCTAssertEqual(object.addressSubtypes?.count, CoreResultType.allAddressTypes.count)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        
        let decoder = JSONDecoder()
        let decodedObject = try decoder.decode(SearchResultType.self, from: data)
        
        XCTAssertEqual(decodedObject, object)
    }
    
    func testDecodableWithCorruptedData() throws {
        #if !arch(x86_64)
        throw XCTSkip("Unsupported architecture")
        #else
        
        let fakeObject = SearchRequestOptions(query: "query", proximity: .sample1)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(fakeObject)
        
        let assertionError = catchBadInstruction {
            let decoder = JSONDecoder()
            _ = try! decoder.decode(SearchResultType.self, from: data)
        }
        XCTAssertNotNil(assertionError)
        
        #endif
    }
}
