class ConnectionManager {
  static let shared = ConnectionManager()
  
  func sendMasRequest(_ request: MasRequest, delegate: MasConnectionDelegate?) -> MasConnection {
    let connection = MasConnection()
    connection.delegate = delegate
    return connection
  }
}

struct MasRequest {
  var method: String
  var data: [AnyHashable : Any]?
}

struct MasResponse {
  var data: [AnyHashable : Any]?
  var errors: [Error]?
}

protocol MasConnectionDelegate: class {
  func connection(_ connection: MasConnection, didReceive response: MasResponse)
  func connection(_ connection: MasConnection, didFailWithError error: Error)
}

class MasConnection {
  weak var delegate: MasConnectionDelegate?
  
  func send(_ request: MasRequest) {
  }
}

