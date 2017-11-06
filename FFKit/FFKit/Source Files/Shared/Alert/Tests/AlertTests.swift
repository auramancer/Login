import XCTest
@testable import FFKit

class AlertTests: XCTestCase {
  func testEquality() {
    var alert1 = Alert(title: "a", message: "b", actions: [])
    var alert2 = Alert(title: "a", message: "b", actions: [])
    XCTAssertEqual(alert1, alert2)
    
    alert1 = Alert(title: "a", message: "b", actions: [])
    alert2 = Alert(title: "a", message: "c", actions: [])
    XCTAssertNotEqual(alert1, alert2)
    
    alert1 = Alert(title: "a", message: "b", actions: [])
    alert2 = Alert(title: "c", message: "b", actions: [])
    XCTAssertNotEqual(alert1, alert2)
    
    alert1 = Alert(title: NSAttributedString(string: "a"), message: "b", actions: [])
    alert2 = Alert(title: NSAttributedString(string: "a"), message: "b", actions: [])
    XCTAssertEqual(alert1, alert2)
    
    alert1 = Alert(title: "a", message: NSAttributedString(string: "b"), actions: [])
    alert2 = Alert(title: "a", message: NSAttributedString(string: "b"), actions: [])
    XCTAssertEqual(alert1, alert2)
    
    alert1 = Alert(title: NSAttributedString(string: "a"), message: NSAttributedString(string: "b"), actions: [])
    alert2 = Alert(title: NSAttributedString(string: "a"), message: NSAttributedString(string: "b"), actions: [])
    XCTAssertEqual(alert1, alert2)
    
    alert1 = Alert(title: NSAttributedString(string: "a"), message: "b", actions: [])
    alert2 = Alert(title: "a", message: "b", actions: [])
    XCTAssertEqual(alert1, alert2)
    
    alert1 = Alert(title: NSAttributedString(string: "a"), message: "b", actions: [])
    alert2 = Alert(title: NSAttributedString(string: "c"), message: "b", actions: [])
    XCTAssertNotEqual(alert1, alert2)
  }
}
