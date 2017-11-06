import Foundation

open class JSONService<Input, Output>: Service<Input, Output> {
  var connection: JSONConnection?
  
  override open func invoke(_ input: Input, completion: ((Service<Input, Output>.Result) -> Void)?) {
    super.invoke(input, completion: completion)
    
    makeConnection()
  }
  
  open var url: URL? {
    // Should be overridden
    return nil
  }
  
  open func convertToJSON(_ input: Input) -> JSON? {
    // Should be overridden
    return nil
  }
  
  open func convertFromJSON(_ response: JSON) -> (Output?, [Error]) {
    // Should be overridden
    return (nil, [])
  }
  
  private func makeConnection() {
    let request = convertToJSON(input!)
    
    connection = makeConnection(with: url, request: request)
    connection?.delegate = self
    connection?.connect()
  }
  
  open func makeConnection(with url: URL?, request: JSON?) -> JSONConnection? {
    guard let url = url else { return nil }
    
    return JSONConnection(url: url, request: request)
  }
  
  override open func reset() {
    super.reset()
    
    connection?.delegate = nil
    connection = nil
  }
}

extension JSONService: JSONConnectionDelegate {
  func connection(_ connection: JSONConnection, didReceiveResponse response: JSON) {
    let (output, errors) = convertFromJSON(response)
    
    if errors.count > 0 {
      fail(withErrors: errors)
    }
    else {
      succeed(withOutput: output!)
    }
  }
  
  func connection(_ connection: JSONConnection, didFailWithError error: Error) {
    notAvailable(dueTo: error)
  }
}
