import XCTest
@testable import FFKit

class MasServiceTests: XCTestCase {
  private var service: MasServiceSpy!
  private var server: MasServerStub!
  
  private var result: MasServiceSpy.Result?
  
  override func setUp() {
    super.setUp()
    
    server = MasServerStub()
    
    service = MasServiceSpy()
    service.server = server
  }
  
  func testDefaultMethods() {
    let service = MasService<Int, Int>()
    
    XCTAssertEqual(service.method, "")
    XCTAssertFalse(service.isSessionRequired)
    XCTAssertNil(service.convertToOutput(from: JSON(["a" : "b"])))
  }
  
  func testGetURL() {
    XCTAssertEqual(service.url, testURL)
  }
  
  func testSetSession() {
    service.session = "QWERTY"
    
    XCTAssertEqual(server.session, "QWERTY")
  }
  
  func testGetSession() {
    server.session = "ASDFGH"
    
    XCTAssertEqual(service.session, "ASDFGH")
  }

  func testMakeConnectionWithoutSession() {
    let data: [String : Any] = [
      "a" : "b",
      "c" : [
        "d" : "e"
      ]
    ]
    
    let connection = service.makeConnection(with: testURL, request: JSON(data))
    
    let expected: [String : Any] = [
      "request" : [
        "header" : [],
        "a" : "b",
        "c" : [
          "d" : "e"
        ]
      ]
    ]
    XCTAssertEqual(connection?.request?.data as? NSDictionary, expected as NSDictionary)
  }
  
  func testMakeConnectionWithSession() {
    service.isSessionRequiredStub = true
    server.session = "QWERTY"
    
    let connection = service.makeConnection(with: testURL, request: JSON(["a" : "b"]))
    
    let expected: [String : Any] = [
      "request" : [
        "header" : [],
        "a" : "b",
        "session" : "QWERTY"
      ]
    ]
    XCTAssertEqual(connection?.request?.data as? NSDictionary, expected as NSDictionary)
  }
  
  func testConvertFromJSONWithNoError() {
    let response = JSON([
      "response" : [
        "body" : [
          "key" : "value"
        ]
      ]
    ])
    
    let (output, errors) = service.convertFromJSON(response)
    
    XCTAssertEqual(output, "value")
    XCTAssertEqual(errors.count, 0)
  }
  
  func testConvertFromJSONWithError() {
    let response = JSON([
      "response" : [
        "body" : [
          "errors" : [
            "error" : [
              "code" : 4,
              "subCode" : 17005,
              "field" : "location",
              "content" : "Location forbidden."
            ]
          ]
        ]
      ]
    ])
    
    let (output, errors) = service.convertFromJSON(response)
    
    XCTAssertNil(output)
    let expected = MasError(message: "Location forbidden.", code: 4, subCode: 17005, field: "location")
    XCTAssertEqual((errors as? [MasError]) ?? [], [expected])
  }
  
  func testConvertFromJSONWithNoBody() {
    let (output, errors) = service.convertFromJSON(JSON("response"))
    
    XCTAssertNil(output)
    XCTAssertEqual((errors as? [MasError]) ?? [], [MasError.unknown])
  }
  
  func testConvertFromJSONWithNoSpecificError() {
    let response = JSON([
      "response" : [
        "body" : [
          "errors" : "error"
        ]
      ]
    ])
    
    let (output, errors) = service.convertFromJSON(response)
    
    XCTAssertNil(output)
    XCTAssertEqual((errors as? [MasError]) ?? [], [MasError.unknown])
  }
}

private class MasServiceSpy: MasService<String, String> {
  var isSessionRequiredStub = false
  
  override var isSessionRequired: Bool {
    return isSessionRequiredStub
  }
  
  override func convertToOutput(from response: JSON) -> String? {
    return response.value(forKeyPath: "key")?.data as? String
  }
}

private class MasServerStub: MasServer {
  override var url: URL {
    return testURL
  }
  
  override func request(forMethod method: String) -> [String : Any] {
    return [
      "request" : [
        "header" : []
      ]
    ]
  }
}
