import XCTest
@testable import FFKit

class ConnectionManagerTests: XCTestCase {
  var connectionManager: ConnectionManager!
  var connection: MasConnection!
  var request: MasRequest!
  var response: MasResponse?
  var error: Error?
  
  override func setUp() {
    super.setUp()
    
    connectionManager = ConnectionManager()
    
    reset()
  }
  
  func reset() {
    connection = nil
  }
  
  func testMasConnection() {
    request = MasRequest(method: "ping", data: nil)
    response = MasResponse(data: nil, errors: nil)
    
    sendMasRequest()
    
    assertDidReceiveCorrectMasResponse()
  }
  
  private func sendMasRequest() {
    connection = connectionManager.sendMasRequest(request, delegate: self)
  }
  
  private func assertDidReceiveCorrectMasResponse() {
    
  }
}

extension ConnectionManagerTests: MasConnectionDelegate {
  func connection(_ connection: MasConnection, didReceive response: MasResponse) {
    self.response = response
  }
  
  func connection(_ connection: MasConnection, didFailWithError error: Error) {
    self.error = error
  }
}

class MasConnectionSpy: MasConnection {
  var request: MasRequest?
  var response: MasResponse?
  
  override func send(_ request: MasRequest) {
    self.request = request

    delegate?.connection(self, didReceive: response!)
  }
}
