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
  func goToVerificationPage(withRequest: RetailLoginRequest)
  func leave()
}

class DualModeLoginPresenter {
  weak var output: DualModeLoginPresenterOutput?

  private var mode = LoginMode.undetermined

  private var usernamePresenter = DigitalLoginPresenter()
  private var cardNumberPresenter = RetailLoginPresenter()
  private var currentPresenter: DualModeLoginInteractorOutput!
  
  init() {
    switchSubPresenter()
  }
  
  private func switchSubPresenter() {
    switch mode {
    case .undetermined, .digital:
      usernamePresenter.output = self
      cardNumberPresenter.output = nil
      currentPresenter = usernamePresenter
    case .retail:
      cardNumberPresenter.output = self
      usernamePresenter.output = nil
      currentPresenter = cardNumberPresenter
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
  func didLoad(withIdentifier identifier: String, credential: String) {
    output?.changeIdentifier(to: identifier)
    output?.changeCredential(to: credential)
    output?.changeCanLogin(to: false)
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
  
  func inquireVerificationCode(forRequest request: RetailLoginRequest) {
    currentPresenter.inquireVerificationCode(forRequest: request)
  }
}

extension DualModeLoginPresenter: DigitalLoginPresenterOutput, RetailLoginPresenterOutput {
  
  func changeUsername(to username: String) {
    output?.changeIdentifier(to: username)
  }
  
  func changePassword(to password: String) {
    output?.changeCredential(to: password)
  }
  
  func changeCardNumber(to cardNumber: String) {
    output?.changeIdentifier(to: cardNumber)
  }
  
  func changePIN(to pin: String) {
    output?.changeCredential(to: pin)
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
  
  func goToVerificationPage(withRequest request: RetailLoginRequest) {
    output?.goToVerificationPage(withRequest: request)
  }
  
  func leave() {
    output?.leave()
  }
}

extension DigitalLoginPresenter: DualModeLoginInteractorOutput {
  func didLoad(withIdentifier identifier: String, credential: String) {
    didLoad(withRememberedRequest: DigitalLoginRequest(username: identifier, password: credential))
  }
}

extension RetailLoginPresenter: DualModeLoginInteractorOutput {
  func didLoad(withIdentifier identifier: String, credential: String) {
    didLoad(withRememberedRequest: RetailLoginRequest(cardNumber: identifier, pin: credential))
  }
}

extension DualModeLoginInteractorOutput {
  func inquireVerificationCode(forRequest: RetailLoginRequest) {
  }
  
  func loginModeDidChange(to: LoginMode) {
  }
}
