protocol Identity {
  var identifier: String { get }
  var credential: String { get }
}

struct DigitalIdentity: Identity {
  var identifier: String
  var credential: String
}

struct RetailIdentity: Identity {
  var identifier: String
  var credential: String
  var verificationCode: String?
  var authenticationToken: String?
  var membershipNumber: String?
}

extension RetailIdentity {
  init(identifier: String, credential: String) {
    self.init(identifier: identifier,
              credential: credential,
              verificationCode: nil,
              authenticationToken: nil,
              membershipNumber: nil)
  }
  
  var isValid: Bool {
    return identifierIsValid && credentialIsValid
  }
  
  fileprivate var identifierIsValid: Bool {
    return identifier != ""
  }
  
  fileprivate var credentialIsValid: Bool {
    return credential != ""
  }
  
  var isValidForLoginWithCode: Bool {
    return isValid && verificationCodeIsValid
  }
  
  fileprivate var verificationCodeIsValid: Bool {
    return verificationCode != nil && verificationCode != ""
  }
}
