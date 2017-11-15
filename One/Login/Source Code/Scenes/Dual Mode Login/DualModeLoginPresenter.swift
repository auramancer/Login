struct DualModeLoginWording {
  let id: String
  let forgottenId: String
  let credential: String
  let forgottenCredential: String
  
  static let undetermined = DualModeLoginWording(id: "Username/Membership Card Number",
                                    forgottenId: "Forgotten Username",
                                    credential: "Password/PIN",
                                    forgottenCredential: "Forgotten Password")
  
  static let username = DualModeLoginWording(id: "Username",
                                             forgottenId: "Forgotten Username",
                                             credential: "Password",
                                             forgottenCredential: "Forgotten Password")
  
  static let membershipCardNumber = DualModeLoginWording(id: "Membership Card Number",
                                                         forgottenId: "Forgotten Membership Card No.",
                                                         credential: "PIN",
                                                         forgottenCredential: "Forgotten PIN")
}

protocol DualModeLoginPresenterOutput: class {
  func changeIdentifier(to: String)
  func changeCredential(to: String)
  func changeWording(to: DualModeLoginWording)
  func changeCanLogin(to: Bool)
  func changeIsLoggingIn(to: Bool)
  func changeErrorMessage(to: String)
  func clearErrorMessage()
  
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
  func idDidChange(to id: String) {
    currentPresenter.idDidChange(to: id)
  }
  
  func credentialDidChange(to credential: String) {
    currentPresenter.credentialDidChange(to: credential)
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
  
  func loginDidFail(withErrors errors: [LoginError]) {
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
  
  func changeErrorMessage(to message: String) {
    output?.changeErrorMessage(to: message)
  }
  
  func clearErrorMessage() {
    output?.clearErrorMessage()
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
  func idDidChange(to id: String) {
    usernameDidChange(to: id)
  }
  
  func credentialDidChange(to credential: String) {
    passwordDidChange(to: credential)
  }
}

extension RetailLoginPresenter: DualModeLoginInteractorOutput {
  func idDidChange(to id: String) {
    cardNumberDidChange(to: id)
  }
  
  func credentialDidChange(to credential: String) {
    pinDidChange(to: credential)
  }
}

extension DualModeLoginInteractorOutput {
  func inquireVerificationCode(forRequest: RetailLoginRequest) {
  }
  
  func loginModeDidChange(to: LoginMode) {
  }
}
