import Foundation

open class MasService<Input, Output>: JSONService<Input, Output> {
  lazy var server = MasServer.shared

  open var method: String {
    return ""
  }
  
  open var isSessionRequired: Bool {
    return false
  }
  
  public var session: MasSession? {
    set {
      server.session = newValue
    }
    get {
      return server.session
    }
  }
  
  override open var url: URL? {
    return server.url
  }
  
  override open func makeConnection(with url: URL?, request: JSON?) -> JSONConnection? {
    return super.makeConnection(with: url, request: wrap(request))
  }
  
  private func wrap(_ request: JSON?) -> JSON? {
    var wrapper = server.request(forMethod: method)
    
    if let request = request,
      let dictionary = request.data as? [String : Any] {
      put(dictionary, into: &wrapper)
    }
    
    if isSessionRequired, let session = session {
      put(["session" : session], into: &wrapper)
    }
    
    return JSON(wrapper)
  }
  
  private func put(_ dictionary: [String : Any], into wrapper: inout [String : Any]) {
    var body = wrapper["request"] as? [String : Any]
    
    dictionary.forEach {
      body?[$0] = $1
    }
    
    wrapper["request"] = body
  }
  
  override open func convertFromJSON(_ response: JSON) -> (Output?, [Error]) {
    guard let body = response.value(forKeyPath: "response.body"),
          body.data is [String : Any] else {
      return (nil, [MasError.unknown])
    }
    
    if let errors = body.value(forKeyPath: "errors.error")?.convertToArray(of: MasError.self), errors.count > 0 {
      return (nil, errors)
    }
    else if let output = convertToOutput(from: body) {
      return (output, [])
    }
    
    return (nil, [MasError.unknown])
  }
  
  open func convertToOutput(from response: JSON) -> Output? {
    return nil
  }
}
