import XCTest
@testable import FFKit

class JSONTests: XCTestCase {
  func testValueForKeyPath() {
    let json = JSON([
      "a" : [
        "b" : [
          "c" : "d",
          "e" : "f"
        ],
        "g" : "h"
      ]
    ])
    
    XCTAssertEqual(json.value(forKeyPath: "a.b.c")?.data as? String, "d")
    XCTAssertEqual(json.value(forKeyPath: "a.g")?.data as? String, "h")
    XCTAssertNil(json.value(forKeyPath: "a.b.c.d"))
  }
  
  func testConverToArray() {
    XCTAssertEqual(getValues(from: [["a":"b"], ["a":"c"]]) ?? [], ["b","c"])
    XCTAssertEqual(getValues(from: ["a":"b"]) ?? [], ["b"])
    XCTAssertNil(getValues(from: "a"))
  }
  
  private func getValues(_ data: Any) -> [String]? {
    return JSON(data).convertToArray(of: TestObject.self)?.flatMap { $0.value }
  }
  
  func testConvertToDouble() {
    XCTAssertEqual(JSON(8.8).convertToDouble(), 8.8)
    XCTAssertEqual(JSON(8).convertToDouble(), 8.0)
    XCTAssertEqual(JSON("8.8").convertToDouble(), 8.8)
    XCTAssertNil(JSON([8.8]).convertToDouble())
  }
  
  func testConvertToString() {
    XCTAssertEqual(JSON(8.8).convertToString(), "8.8")
    XCTAssertEqual(JSON(8).convertToString(), "8")
    XCTAssertEqual(JSON("8.8").convertToString(), "8.8")
    XCTAssertNil(JSON(["8.8"]).convertToString())
  }
}

private class TestObject: DictionaryInitializable {
  var value: String?
  
  required init?(dictionary: [String : Any]) {
    value = dictionary["a"] as? String
  }
}
