import Foundation

class UsernameLoginServiceStub: UsernameLoginServiceInput {
  weak var output: LoginServiceOutput?
  
  func logIn(withUsernameDetails details: UsernameLoginDetails) {
    print("* Username login service invoked. *")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if details.password == "123" {
        self.output?.didLogIn()
      }
      else {
        self.output?.didFailToLogIn(dueTo: ["Unknown"])
      }
    }
  }
}

class CardNumberLoginServiceStub: CardNumberLoginServiceInput {
  weak var output: LoginServiceOutput?
  
  func logIn(withCardNumberDetails details: CardNumberLoginDetails) {
    print("* Card number login service invoked. *")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      if details.pin == "321" {
        self.output?.didLogIn()
      }
      else {
        self.output?.didFailToLogIn(dueTo: ["Unknown"])
      }
    }
  }
}

class DualModeLoginServiceStub: DualModeLoginServiceInput {
  weak var output: LoginServiceOutput? {
    didSet {
      usernameService.output = output
      cardNumberService.output = output
    }
  }
  
  private var usernameService = UsernameLoginServiceStub()
  private var cardNumberService = CardNumberLoginServiceStub()
  
  func logIn(withUsernameDetails details: UsernameLoginDetails) {
    usernameService.logIn(withUsernameDetails: details)
  }
  
  func logIn(withCardNumberDetails details: CardNumberLoginDetails) {
    cardNumberService.logIn(withCardNumberDetails: details)
  }
}
