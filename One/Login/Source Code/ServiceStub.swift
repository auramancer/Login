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

class MembershipCardNumberLoginServiceStub: MembershipCardNumberLoginServiceInput {
  weak var output: LoginServiceOutput?
  
  func logIn(withMembershipCardNumberDetails details: MembershipCardNumberLoginDetails) {
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
  private var cardNumberService = MembershipCardNumberLoginServiceStub()
  
  func logIn(withUsernameDetails details: UsernameLoginDetails) {
    usernameService.logIn(withUsernameDetails: details)
  }
  
  func logIn(withMembershipCardNumberDetails details: MembershipCardNumberLoginDetails) {
    cardNumberService.logIn(withMembershipCardNumberDetails: details)
  }
}
