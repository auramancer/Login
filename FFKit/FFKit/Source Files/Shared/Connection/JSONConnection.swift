import Foundation

protocol JSONConnectionDelegate: class {
  func connection(_: JSONConnection, didReceiveResponse: JSON)
  func connection(_: JSONConnection, didFailWithError: Error)
}

public class JSONConnection {
  var url: URL
  var request: JSON?
  var response: JSON?
  weak var delegate: JSONConnectionDelegate?
  
  init(url: URL, request: JSON? = nil) {
    self.url = url
    self.request = request
  }
  
  private var connection: MKDJSONConnection?
  
  func connect() {
    let body = request?.data as? [String : Any]
    
    connection = MKDJSONConnection(jsonURL: url.absoluteString, delegate: self, httpBody: body)
  }
}

extension JSONConnection: MKDJSONConnectionDelegate {
  public func jsonConnectionFinished(_ connection: MKDJSONConnection) {
    delegate?.connection(self, didReceiveResponse: JSON(connection.responseData!))
  }
  
  public func jsonConnectionFailed(_ connection: MKDJSONConnection) {
    delegate?.connection(self, didFailWithError: connection.error!)
  }
}

public class MKDJSONConnection {
  init(jsonURL: String?, delegate: MKDJSONConnectionDelegate, httpBody: [String : Any]?) {
  }
  
  var responseData: Any?
  var error: Error?
}

public protocol MKDJSONConnectionDelegate {
  func jsonConnectionFinished(_: MKDJSONConnection)
  func jsonConnectionFailed(_: MKDJSONConnection)
}
