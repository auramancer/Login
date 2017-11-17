import Foundation

class DigitalLoginServiceStub: DigitalLoginServiceInput {
  weak var output: DigitalLoginServiceOutput?
  
  func logIn(withUsernameRequest request: DigitalLoginRequest) {
    print("* Username login service invoked. *")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if request.password == "1234" {
        self.output?.loginDidSucceed()
      }
      else {
        self.output?.loginDidFail(dueTo: [SimpleError("Wrong password")])
      }
    }
  }
}

class RetailLoginServiceStub: RetailLoginServiceInput {
  weak var output: RetailLoginServiceOutput?

  func logIn(withCardNumberRequest request: RetailLoginRequest) {
    print("* Card number login service invoked. *")

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if request.pin == "4321" {
        if request.authenticationToken == nil {
          self.output?.loginDidFailDueToInvalidToken()
        }
        else {
          self.output?.loginDidSucceed()
        }
      }
      else {
        self.output?.loginDidFail(dueTo: [SimpleError("Wrong pin")])
      }
    }
  }
}

class LoginVerificationServiceStub: LoginVerificationServiceInput {
  weak var output: LoginVerificationServiceOutput?
  
  func logIn(withCardNumberRequest request: RetailLoginRequest) {
    print("* Card number login service invoked. *")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if request.verificationCode == "123456" {
        self.output?.loginDidSucceed(withToken: "1QAZ2WSX")
      }
      else {
        self.output?.loginDidFail(dueTo: [SimpleError("Wrong code")])
      }
    }
  }
  
  func resendCode(withCardNumberRequest: RetailLoginRequest) {
    
  }
}

class DualModeLoginServiceStub: DualModeLoginServiceInput {
  weak var output: DualModeLoginServiceOutput? {
    didSet {
      usernameService.output = output
      cardNumberService.output = output
    }
  }

  private var usernameService = DigitalLoginServiceStub()
  private var cardNumberService = RetailLoginServiceStub()

  func logIn(withUsernameRequest request: DigitalLoginRequest) {
    usernameService.logIn(withUsernameRequest: request)
  }

  func logIn(withCardNumberRequest request: RetailLoginRequest) {
    cardNumberService.logIn(withCardNumberRequest: request)
  }
}

extension SimpleError: LoginError {
}
