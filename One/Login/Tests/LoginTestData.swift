struct LoginTestData {
  static let validUsername = "username"
  static let validPassword = "password"
  static let validCardNumber = "1234567890"
  static let validPIN = "8888"
  static let validToken = "1QAZ2WSX"
  static let validCode = "666666"
  static let membershipNumber = "9876543210"
  static let session = "12345QWERT"
  static let errorMessage = "Cannot log in."
  static let error = LoginSimpleError(errorMessage)
  
  static let emptyDigitalIdentity = DigitalIdentity(identifier: "", credential: "")
  static let validDigitalIdentity = DigitalIdentity(identifier: validUsername, credential: validPassword)
  static let digitalIdentityIdOnly = DigitalIdentity(identifier: validUsername, credential: "")

  static let emptyRetailIdentity = RetailIdentity(identifier: "", credential: "")
  static let validRetailIdentity = RetailIdentity(identifier: validCardNumber, credential: validPIN)
  static let retailIdentityIdOnly = RetailIdentity(identifier: validCardNumber, credential: "")
  static let retailIdentityWithMembershipNumber = RetailIdentity(identifier: validCardNumber,
                                                                 credential: validPIN,
                                                                 membershipNumber: membershipNumber)
  static let retailIdentityWithToken = RetailIdentity(identifier: validCardNumber,
                                                      credential: validPIN,
                                                      token: validToken)
  static let retailIdentityWithCode = RetailIdentity(identifier: validCardNumber,
                                                     credential: validPIN,
                                                     code: validCode)
  static let retailIdentityWithTokenAndCode = RetailIdentity(identifier: validCardNumber,
                                                             credential: validPIN,
                                                             token: validToken,
                                                             code: validCode)
  
  static let ambiguousIdentifier = "12345"
  static let validUsername2 = "username0"
  static let shortUsername = "user"
  static let nonAlphanumericUsername = "user_name"
  static let validPassword2 = "password0"
  static let shortPassword = "pass"
  static let nonAlphanumericPassword = "pass_word"
}

struct LoginSimpleError: LoginError, LoginVerificationError, IdentityCreationError {
  var message: String
  
  init(_ message: String) {
    self.message = message
  }
}

extension DigitalIdentity: Equatable {
  static func ==(lhs: DigitalIdentity, rhs: DigitalIdentity) -> Bool {
    return lhs.identifier == rhs.identifier &&
      lhs.credential == rhs.credential
  }
}

extension RetailIdentity: Equatable {
  static func ==(lhs: RetailIdentity, rhs: RetailIdentity) -> Bool {
    return lhs.identifier == rhs.identifier &&
      lhs.credential == rhs.credential &&
      lhs.authenticationToken == rhs.authenticationToken &&
      lhs.verificationCode == rhs.verificationCode
  }
}

extension LoginMessage: Equatable {
  static func ==(lhs: LoginMessage, rhs: LoginMessage) -> Bool {
    return lhs.text == rhs.text &&
      lhs.style == rhs.style
  }
}
