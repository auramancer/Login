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
      subPresenter.output = output
    }
  }
  
  private var subPresenter = LoginPresenter()
  
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
    output?.updateWording(wording(for: mode))
  }
  
  private func wording(for mode: LoginMode) -> DualModeLoginWording {
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
  }
}
