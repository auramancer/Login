public struct MasError: Error {
  var message: String
  var code: Int?
  var subCode: Int?
  var field: String?
}

extension MasError: DictionaryInitializable {
  init(message: String? = nil, code: Int? = nil, subCode: Int? = nil, field: String? = nil) {
    self.message = message ?? "There's something wrong. Please try again later."
    self.code = code
    self.subCode = subCode
    self.field = field
  }
  
  public init?(dictionary: [String : Any]) {
    let message = dictionary["content"] as? String
    let code = dictionary["code"] as? Int
    let subCode = dictionary["subCode"] as? Int
    let field = dictionary["field"] as? String
    
    self.init(message: message, code: code, subCode: subCode, field: field)
  }
}

extension MasError: Equatable {
  public static func ==(lhs: MasError, rhs: MasError) -> Bool {
    return lhs.code == rhs.code &&
      lhs.subCode == rhs.subCode &&
      lhs.field == rhs.field &&
      lhs.message == rhs.message
  }
}

extension MasError {
  static let unknown = MasError()
  
//  var mkdError: MKDError {
//    return MKDError(description: message, errorCode: String(code ?? 0), errorSubCode: String(subCode ?? 0))
//  }
}
