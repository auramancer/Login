import Foundation

class UsernameLoginServiceStub: UsernameLoginServiceInput {
  weak var output: UsernameLoginServiceOutput?
  
  func logIn(withUsernameDetails details: UsernameLoginDetails) {
    print("* Username login service invoked. *")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if details.password == "1234" {
        self.output?.loginDidSucceed()
      }
      else {
        self.output?.loginDidFail(dueTo: ["Wrong password"])
      }
    }
  }
}

class CardNumberLoginServiceStub: CardNumberLoginServiceInput {
  weak var output: CardNumberLoginServiceOutput?

  func logIn(withCardNumberDetails details: CardNumberLoginDetails) {
    print("* Card number login service invoked. *")

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if details.pin == "4321" {
        if details.authenticationToken == nil {
          self.output?.loginDidFailDueToExpiredToken()
        }
        else {
          self.output?.loginDidSucceed()
        }
      }
      else {
        self.output?.loginDidFail(dueTo: ["Wrong pin"])
      }
    }
  }
}

class LoginVerificationServiceStub: CardNumberLoginServiceInput {
  weak var output: LoginVerificationServiceOutput?
  
  func logIn(withCardNumberDetails details: CardNumberLoginDetails) {
    print("* Card number login service invoked. *")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if details.verificationCode == "123456" {
        self.output?.loginDidSucceed(withToken: "1QAZ2WSX")
      }
      else {
        self.output?.loginDidFail(dueTo: ["Wrong code"])
      }
    }
  }
}
//
//class DualModeLoginServiceStub: DualModeLoginServiceInput {
//  weak var output: LoginServiceOutput? {
//    didSet {
//      usernameService.output = output
//      cardNumberService.output = output
//    }
//  }
//
//  private var usernameService = UsernameLoginServiceStub()
//  private var cardNumberService = CardNumberLoginServiceStub()
//
//  func logIn(withUsernameDetails details: UsernameLoginDetails) {
//    usernameService.logIn(withUsernameDetails: details)
//  }
//
//  func logIn(withCardNumberDetails details: CardNumberLoginDetails) {
//    cardNumberService.logIn(withCardNumberDetails: details)
//  }
//}

