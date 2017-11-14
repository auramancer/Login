struct DualModeLoginWording {
  let id: String
  let forgottenId: String
  let secret: String
  let forgottenSecret: String
  
  static let undetermined = DualModeLoginWording(id: "Username/Membership Card Number",
                                    forgottenId: "Forgotten Username",
                                    secret: "Password/PIN",
                                    forgottenSecret: "Forgotten Password")
  
  static let username = DualModeLoginWording(id: "Username",
                                             forgottenId: "Forgotten Username",
                                             secret: "Password",
                                             forgottenSecret: "Forgotten Password")
  
  static let membershipCardNumber = DualModeLoginWording(id: "Membership Card Number",
                                                         forgottenId: "Forgotten Membership Card No.",
                                                         secret: "PIN",
                                                         forgottenSecret: "Forgotten PIN")
}

protocol DualModeLoginPresenterOutput: LoginPresenterOutput {
  func updateWording(_: DualModeLoginWording)
}

class DualModeLoginPresenter: DualModeLoginInteractorOutput {
  weak var output: DualModeLoginPresenterOutput? {
    didSet {
      usernamePresenter.output = output
      cardNumberPresenter.output = output
    }
  }
  
  var mode = LoginMode.undetermined
  
  private var usernamePresenter = UsernameLoginPresenter()
  private var cardNumberPresenter = CardNumberLoginPresenter()
  
  private var subPresenter: AbstractLoginPresenter {
    switch mode {
    case .undetermined, .username:
      return usernamePresenter
    case .cardNumber:
      return cardNumberPresenter
    }
  }
  
  func loginWasEnabled() {
    subPresenter.loginWasEnabled()
  }
  
  func loginWasDisabled() {
    subPresenter.loginWasDisabled()
  }
  
  func loginDidBegin() {
    subPresenter.loginDidBegin()
  }
  
  func loginDidEnd() {
    subPresenter.loginDidEnd()
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    subPresenter.loginDidFail(dueTo: errors)
  }
  
  func loginModeDidChange(to mode: LoginMode) {
    self.mode = mode
    
    output?.updateWording(wording)
  }
  
  private var wording: DualModeLoginWording {
    switch mode {
    case .undetermined:
      return .undetermined
    case .username:
      return .username
    case .cardNumber:
      return .membershipCardNumber
    }
  }
  
  func showHelp(_ help: LoginHelp) {
    subPresenter.showHelp(help)
  }
  
  func inquireAuthenticationCode() {
    cardNumberPresenter.inquireAuthenticationCode()
  }
}
