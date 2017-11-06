import XCTest
@testable import FFKit

class HostManager: XCTestCase {
  var hostManager: HostManager!
  
  override func setUp() {
    super.setUp()
    
    hostManager = HostManager(scheme: "https://", host: ["mas1.mkodo.net", "mas2.mkodo.net"], path: "")
  }
  
  func test() {
    
  }
}

class HostManager {
  var scheme: String
  var host: [String]
  var path: String
  
  init(scheme: String, host: [String], path: String) {
    self.scheme = scheme
    self.host = host
    self.path = path
  }
}

struct HostAddress {
  var scheme: String?
  var host: String?
  var path: String?
  
  var url: URL {
    return
  }
}
