import Foundation

class DigitalLoginServiceStub: DigitalLoginServiceInput {
  weak var output: DigitalLoginServiceOutput?
  
  func logIn(withDigitalIdentity identity: DigitalIdentity) {
    print("* Username login service invoked. *")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if identity.credential == "1234" {
        self.output?.loginDidSucceed(withSession: "12345QWERT")
      }
      else {
        self.output?.loginDidFail(dueTo: [LoginSimpleError("Wrong password")])
      }
    }
  }
}

class RetailLoginServiceStub: RetailLoginServiceInput {
  weak var output: RetailLoginServiceOutput?

  func logIn(withRetailIdentity identity: RetailIdentity) {
    print("* Card number login service invoked. *")

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if identity.credential == "1234" {
        if identity.authenticationToken == nil {
          self.output?.loginDidFailDueToInvalidToken()
        }
        else {
          self.output?.loginDidSucceed(withSession: "12345QWERT")
        }
      }
      else {
        self.output?.loginDidFail(dueTo: [LoginSimpleError("Wrong pin")])
      }
    }
  }
}

class LoginVerificationServiceStub: RetailLoginServiceInput, VerificationCodeServiceInput {
  weak var output: LoginVerificationServiceOutput?
  
  func logIn(withRetailIdentity identity: RetailIdentity) {
    print("* Card number login service invoked. *")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if identity.credential == "1234" && identity.verificationCode == "123456" {
        self.output?.loginDidSucceed(withSession: "12345QWERT",
                                     token: "54321TREWQ",
                                     needToCreateDigitalIdentity: true)
      }
      else {
        self.output?.loginDidFail(dueTo: [LoginSimpleError("Wrong code")])
      }
    }
  }
  
  func resendCode(withRetailIdentity: RetailIdentity) {
    print("* Resend code service invoked. *")
  }
}

class DualModeLoginServiceStub: DualModeLoginServiceInput {
  weak var output: DualModeLoginServiceOutput? {
    didSet {
      usernameService.output = output
      cardNumberService.output = output
    }
  }

  fileprivate var usernameService = DigitalLoginServiceStub()
  fileprivate var cardNumberService = RetailLoginServiceStub()

  func logIn(withDigitalIdentity identity: DigitalIdentity) {
    usernameService.logIn(withDigitalIdentity: identity)
  }

  func logIn(withRetailIdentity identity: RetailIdentity) {
    cardNumberService.logIn(withRetailIdentity: identity)
  }
}

class IdentityCreationServiceStub: IdentityCreationServiceInput {
  weak var output: IdentityCreationServiceOutput?
  
  func create(digitalIdentity: DigitalIdentity, withRetailIdentity: RetailIdentity) {
    output?.creationDidSucceed()
  }
}

struct LoginSimpleError: LoginError {
  var message: String
  
  init(_ message: String) {
    self.message = message
  }
}
