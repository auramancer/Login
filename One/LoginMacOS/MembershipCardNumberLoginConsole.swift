import Foundation

class MembershipCardNumberLoginConsole: Console {
  var configurator: Configurator?
  
  var interactor: LoginInteractorInput?
  var isEnteringCardNumber = false
  
  func start() {
    configurator = Configurator(for: self)
    
    show("Membership Card Number Log In")
    enterDetails()
  }
  
  private func enterDetails() {
    enterCardNumber()
    enterPin()
  }
  
  private func enterCardNumber() {
    isEnteringCardNumber = true
    
    let cardNumber = entered("Membership Card Number")
    if cardNumber == "?" {
      askIfForgottenCardNumber()
    }
    else {
      interactor?.updateId(cardNumber)
    }
    
    isEnteringCardNumber = false
  }
  
  private func askIfForgottenCardNumber() {
    if confirmed("Forgotton Membership Card No.") {
      interactor?.helpWithId()
    }
    else {
      enterCardNumber()
    }
  }
  
  private func enterPin() {
    let pin = entered("PIN")
    if pin == "?" {
      askIfForgottenPin()
    }
    else {
      interactor?.updateSecret(pin)
    }
  }
  
  private func askIfForgottenPin() {
    if confirmed("Forgotton PIN") {
      interactor?.helpWithSecret()
    }
    else {
      enterPin()
    }
  }
  
  private func confirmLogin() {
    if confirmed("Login") {
      interactor?.logIn()
    }
    else {
      enterDetails()
    }
  }
}

extension MembershipCardNumberLoginConsole: LoginPresenterOutput {
  func loginWasEnabled() {
    if !isEnteringCardNumber {
      confirmLogin()
    }
  }
  
  func loginWasDisabled() {
    if !isEnteringCardNumber {
      enterDetails()
    }
  }
  
  func showActivityMessage(_: String?) {
    show("......")
  }
  
  func hideActivityMessage() {
  }
  
  func showErrorMessage(_ error: String?) {
    show("Fail!")
  }
  
  func hideErrorMessage() {
  }
  
  func leave() {
    show("Logged in!")
    exit(0)
  }
  
  func navigate(to destination: LoginDestination) {
    switch destination {
    case .forgottenMembershipCardNumber:
      print("Maybe it's 12345678")
      enterCardNumber()
    case .forgottenPIN:
      print("Maybe it's 321?")
      enterPin()
    default:
      break
    }
  }
}

extension MembershipCardNumberLoginConsole {
  class Configurator {
    var presenter: LoginPresenter
    var interactor: MembershipCardNumberLoginInteractor
    var service: MembershipCardNumberLoginServiceStub
    
    init(for userInterface: MembershipCardNumberLoginConsole) {
      interactor = MembershipCardNumberLoginInteractor()
      service = MembershipCardNumberLoginServiceStub()
      presenter = LoginPresenter()
      
      userInterface.interactor = interactor
      interactor.output = presenter
      interactor.service = service
      service.output = interactor
      presenter.output = userInterface
    }
  }
}

