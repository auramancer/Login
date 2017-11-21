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
  
  init(identifier: String, credential: String, token: String) {
    self.init(identifier: identifier,
              credential: credential,
              verificationCode: nil,
              authenticationToken: token,
              membershipNumber: nil)
  }
  
  init(identifier: String, credential: String, membershipNumber: String) {
    self.init(identifier: identifier,
              credential: credential,
              verificationCode: nil,
              authenticationToken: nil,
              membershipNumber: membershipNumber)
  }
  
  init(identifier: String, credential: String, code: String) {
    self.init(identifier: identifier,
              credential: credential,
              verificationCode: code,
              authenticationToken: nil,
              membershipNumber: nil)
  }
  
  init(identifier: String, credential: String, token: String, code: String) {
    self.init(identifier: identifier,
              credential: credential,
              verificationCode: code,
              authenticationToken: token,
              membershipNumber: nil)
  }
  
  var isValid: Bool {
    return identifierIsValid && credentialIsValid
  }
  
  private var identifierIsValid: Bool {
    return identifier != ""
  }
  
  private var credentialIsValid: Bool {
    return credential != ""
  }
  
  var isValidForLoginWithCode: Bool {
    return isValid && verificationCodeIsValid
  }
  
  private var verificationCodeIsValid: Bool {
    return verificationCode != nil && verificationCode! != ""
  }
}
