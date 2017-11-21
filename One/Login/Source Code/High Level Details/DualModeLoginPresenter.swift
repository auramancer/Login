struct DualModeLoginWording {
  let id: String
  let forgottenIdentifier: String
  let credential: String
  let forgottenCredential: String
  
  static let undetermined = DualModeLoginWording(id: "Username/Membership Card Number",
                                    forgottenIdentifier: "Forgotten Username",
                                    credential: "Password/PIN",
                                    forgottenCredential: "Forgotten Password")
  
  static let username = DualModeLoginWording(id: "Username",
                                             forgottenIdentifier: "Forgotten Username",
                                             credential: "Password",
                                             forgottenCredential: "Forgotten Password")
  
  static let membershipCardNumber = DualModeLoginWording(id: "Membership Card Number",
                                                         forgottenIdentifier: "Forgotten Membership Card No.",
                                                         credential: "PIN",
                                                         forgottenCredential: "Forgotten PIN")
}

protocol DualModeLoginPresenterOutput: class {
  func changeIdentifier(to: String)
  func changeCredential(to: String)
  func changeWording(to: DualModeLoginWording)
  func changeCanLogin(to: Bool)
  func changeIsLoggingIn(to: Bool)
  
  func showMessage(_: LoginMessage)
  func clearMessage()
  
  func goToHelpPage(for: LoginHelp)
  func goToVerificationPage(withIdentity: RetailIdentity)
  func leave()
}

class DualModeLoginPresenter {
  weak var output: DualModeLoginPresenterOutput?

  private var mode = LoginMode.undetermined

  private var digitalPresenter = DigitalLoginPresenter()
  private var retailPresenter = RetailLoginPresenter()
  private var currentPresenter: DualModeLoginInteractorOutput!
  
  init() {
    digitalPresenter.output = self
    currentPresenter = digitalPresenter
  }
  
  private func switchSubPresenter() {
    switch mode {
    case .undetermined, .digital:
      digitalPresenter.output = self
      retailPresenter.output = nil
      currentPresenter = digitalPresenter
    case .retail:
      retailPresenter.output = self
      digitalPresenter.output = nil
      currentPresenter = retailPresenter
    }
  }

  private var wording: DualModeLoginWording {
    switch mode {
    case .undetermined:
      return .undetermined
    case .digital:
      return .username
    case .retail:
      return .membershipCardNumber
    }
  }
}

extension DualModeLoginPresenter: DualModeLoginInteractorOutput {
  func didLoad(identifier: String, credential: String, canLogin: Bool, mode: LoginMode) {
    output?.changeIdentifier(to: identifier)
    output?.changeCredential(to: credential)
    output?.changeCanLogin(to: false)
    loginModeDidChange(to: mode)
  }
  
  func canLoginDidChange(to canLogin: Bool) {
    currentPresenter.canLoginDidChange(to: canLogin)
  }
  
  func loginModeDidChange(to mode: LoginMode) {
    self.mode = mode
    switchSubPresenter()
    
    output?.changeWording(to: wording)
  }

  func loginDidBegin() {
    currentPresenter.loginDidBegin()
  }
  
  func loginDidEnd() {
    currentPresenter.loginDidEnd()
  }
  
  func loginDidFail(withErrors errors: [String]) {
    currentPresenter.loginDidFail(withErrors: errors)
  }
  
  func showHelp(_ help: LoginHelp) {
    currentPresenter.showHelp(help)
  }
  
  func showVerification(withIdentity identity: RetailIdentity) {
    currentPresenter.showVerification(withIdentity: identity)
  }
}

extension DualModeLoginPresenter: DigitalLoginPresenterOutput, RetailLoginPresenterOutput {
  func goToIdentityCreationPage(withIdentity: RetailIdentity) {

  }
  
  func changeIdentifier(to identifier: String) {
    output?.changeIdentifier(to: identifier)
  }
  
  func changeCredential(to credential: String) {
    output?.changeCredential(to: credential)
  }
  
  func changeCanLogin(to canLogin: Bool) {
    output?.changeCanLogin(to: canLogin)
  }
  
  func changeIsLoggingIn(to isLogginIn: Bool) {
    output?.changeIsLoggingIn(to: isLogginIn)
  }
  
  func showMessage(_ message: LoginMessage) {
    output?.showMessage(message)
  }
  
  func clearMessage() {
    output?.clearMessage()
  }
  
  func goToHelpPage(for help: LoginHelp) {
    output?.goToHelpPage(for: help)
  }
  
  func goToVerificationPage(withIdentity identity: RetailIdentity) {
    output?.goToVerificationPage(withIdentity: identity)
  }
  
  func leave() {
    output?.leave()
  }
}

extension DigitalLoginPresenter: DualModeLoginInteractorOutput {
  func showVerification(withIdentity: RetailIdentity) {
    
  }
  
  func showIdentityCreation(withIdentity: RetailIdentity) {
    
  }
  
  func didLoad(identifier: String, credential: String, canLogin: Bool, mode: LoginMode) {
  }
}

extension RetailLoginPresenter: DualModeLoginInteractorOutput {
  func didLoad(identifier: String, credential: String, canLogin: Bool, mode: LoginMode) {
  }
}

extension DualModeLoginInteractorOutput {
  func showVerificationForm(withRequest: RetailIdentity) {
  }
  
  func loginModeDidChange(to: LoginMode) {
  }
}
