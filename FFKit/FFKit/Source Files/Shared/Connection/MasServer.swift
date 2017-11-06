import Foundation

public typealias MasSession = String

public class MasServer {
  static let shared = MasServer()
  
  var url: URL {
    return URL(string: "")!//MKDMasConnection.hostManager().urlString()
  }
  
  func request(forMethod method: String) -> [String : Any] {
    return [:] //MKDJSONConnection.jsonRequest(withMethod: method)
  }
  
  var session: MasSession?
}
