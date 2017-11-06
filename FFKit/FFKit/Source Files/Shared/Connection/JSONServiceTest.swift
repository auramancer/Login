import XCTest
@testable import FFKit

let testURLString = "https://test.com"
let testURL = URL(string: testURLString)!

class JSONServiceTests: XCTestCase {
  private var service: JSONServiceSpy!
  
  private var result: JSONServiceSpy.Result?
  
  override func setUp() {
    super.setUp()
    
    service = JSONServiceSpy()
    service.urlStub = testURL
    service.convertToJSONRequest = JSON(data: "request")
    service.convertFromJSONOutput = ("output", [])
  }
  
  func testDefaultMethods() {
    let service = JSONService<Int, Int>()
    
    XCTAssertNil(service.url)
    XCTAssertNil(service.convertToJSON(8))
    XCTAssertNil(service.convertFromJSON(JSON(9)).0)
    XCTAssertEqual(service.convertFromJSON(JSON(9)).1.count, 0)
  }
  
  func testMakeConnection() {
    let service = JSONService<Int, Int>()
    
    let connection = service.makeConnection(with: testURL, request: JSON(data: "request"))
    
    XCTAssertNotNil(connection)
    XCTAssertEqual(connection?.url.absoluteString, testURLString)
    XCTAssertEqual(connection?.request?.data as? String, "request")
  }
  
  func testMakeConnectionWithNoURL() {
    let service = JSONService<Int, Int>()
    
    let connection = service.makeConnection(with: nil, request: JSON(data: "request"))
    
    XCTAssertNil(connection)
  }
  
  func testInvoke() {
    service.invoke("input", completion: handleResult)
    
    XCTAssertEqual(service.input, "input")
    XCTAssertNotNil(service.completion)
    XCTAssertTrue(service.isInUse)
    XCTAssertEqual(service.convertToJSONInput, "input")
    XCTAssertEqual(service.makeConnectionURL?.absoluteString, testURLString)
    XCTAssertEqual(service.makeConnectionRequest?.data as? String, "request")
    XCTAssertTrue(service.connection?.delegate === service)
    XCTAssertEqual((service.connection as? JSONConnetionSpy)?.didConnect, true)
  }
  
  func testParseResponseWithNoError() {
    service.invoke("input", completion: handleResult)
    service.connection(service.connection!, didReceiveResponse: JSON(data: "response"))
    
    XCTAssertEqual(service.convertFromJSONResponse?.data as? String, "response")
    assertResultEquals(JSONServiceSpy.Result.succeeded("output"))
  }
  
  func testParseResponseWithErrors() {
    service.convertFromJSONOutput = (nil, [SimpleError("error1"), SimpleError("error2")])
    
    service.invoke("input", completion: handleResult)
    service.connection(service.connection!, didReceiveResponse: JSON(data: "response"))
    
    XCTAssertEqual(service.convertFromJSONResponse?.data as? String, "response")
    assertResultEquals(JSONServiceSpy.Result.failed([SimpleError("error1"), SimpleError("error2")]))
  }
  
  func testConnectionFailed() {
    service.invoke("input", completion: handleResult)
    service.connection(service.connection!, didFailWithError: SimpleError("error"))
    
    assertResultEquals(JSONServiceSpy.Result.notAvailable(SimpleError("error")))
  }
  
  private func handleResult(_ result: JSONServiceSpy.Result) {
    self.result = result
  }
  
  private func assertResultEquals(_ expected: JSONServiceSpy.Result) {
    guard let result = result else {
      XCTFail()
      return
    }
    
    switch (result, expected) {
    case (let .succeeded(output1), let .succeeded(output2)):
      XCTAssertEqual(output1, output2)
      
    case (let .failed(errors1), let .failed(errors2)):
      guard let errors1 = errors1 as? [SimpleError], let errors2 = errors2 as? [SimpleError] else {
        XCTFail()
        return
      }
      XCTAssertEqual(errors1, errors2)
      
    case (let .notAvailable(error1), let .notAvailable(error2)):
      guard let error1 = error1 as? SimpleError, let error2 = error2 as? SimpleError else {
        XCTFail()
        return
      }
      XCTAssertEqual(error1, error2)
      
    default:
      XCTFail()
    }
  }
  
  func testReset() {
    let connection = JSONConnetionSpy()
    service.connection = connection
    connection.delegate = service
    
    service.reset()
    
    XCTAssertNil(connection.delegate)
    XCTAssertNil(service.connection)
  }
}

struct SimpleError: Error, Equatable {
  var message: String
  
  init(_ message: String) {
    self.message = message
  }
  
  var localizedDescription: String {
    return message
  }
  
  static func ==(lhs: SimpleError, rhs: SimpleError) -> Bool {
    return lhs.message == rhs.message
  }
}

private class JSONServiceSpy: JSONService<String, String> {
  var urlStub: URL?
  
  override var url: URL? {
    return urlStub
  }
  
  var convertToJSONInput: String?
  var convertToJSONRequest: JSON?
  
  override func convertToJSON(_ input: String) -> JSON? {
    convertToJSONInput = input
    return convertToJSONRequest!
  }
  
  var convertFromJSONResponse: JSON?
  var convertFromJSONOutput: (String?, [Error])?
  
  override func convertFromJSON(_ response: JSON) -> (String?, [Error]) {
    convertFromJSONResponse = response
    return convertFromJSONOutput!
  }
  
  var makeConnectionURL: URL?
  var makeConnectionRequest: JSON?
  
  override func makeConnection(with url: URL?, request: JSON?) -> JSONConnection? {
    makeConnectionURL = url
    makeConnectionRequest = request
    return JSONConnetionSpy()
  }
}

private class JSONConnetionSpy: JSONConnection {
  var didConnect = false
  
  init() {
    super.init(url: testURL)
  }
  
  override func connect() {
    didConnect = true
  }
}
