import Foundation

class DualModeLoginConsole: Console {
  var configurator: Configurator?
  
  var interactor: LoginInteractorInput?
  var wording = DualModeLoginWording.undetermined
  var inEnteringId = false
  
  func start() {
    configurator = Configurator(for: self)
    
    show("Dual Mode Log In")
    enterDetails()
  }
  
  private func enterDetails() {
    enterId()
    enterSecret()
  }
  
  private func enterId() {
    inEnteringId = true
    
    let id = entered(wording.id)
    if id == "?" {
      askIfForgottenId()
    }
    else {
      interactor?.updateId(id)
    }
    
    inEnteringId = false
  }
  
  private func askIfForgottenId() {
    if confirmed(wording.forgottenId) {
      interactor?.helpWithId()
    }
    else {
      enterId()
    }
  }
  
  private func enterSecret() {
    let secret = entered(wording.secret)
    if secret == "?" {
      askIfForgottenSecret()
    }
    else {
      interactor?.updateSecret(secret)
    }
  }
  
  private func askIfForgottenSecret() {
    if confirmed(wording.forgottenSecret)  {
      interactor?.helpWithSecret()
    }
    else {
      enterSecret()
    }
  }
  
  private func confirmLogin() {
    if confirmed("Login") {
      askIfRemember()
      interactor?.logIn(shouldRememberDetails: shouldRemember)
    }
    else {
      enterDetails()
    }
  }
  
  var shouldRemember = false
  
  private func askIfRemember() {
    shouldRemember = confirmed("Remember me")
  }
}

extension DualModeLoginConsole: DualModeLoginPresenterOutput {
  func loginWasEnabled() {
    if !inEnteringId {
      confirmLogin()
    }
  }
  
  func loginWasDisabled() {
    if !inEnteringId {
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
    case .forgottenUsername:
      show("Maybe it's asdf?")
      enterId()
    case .forgottenPassword:
      show("Maybe it's 123?")
      enterSecret()
    case .forgottenCardNumber:
      show("Maybe it's 12345678")
      enterId()
    case .forgottenPIN:
      show("Maybe it's 321?")
      enterSecret()
    default:
      break
    }
  }
  
  func updateWording(_ wording: DualModeLoginWording) {
    self.wording = wording
  }
}

extension DualModeLoginConsole {
  class Configurator {
    var presenter: DualModeLoginPresenter
    var interactor: DualModeLoginInteractor
    var service: DualModeLoginServiceStub
    
    init(for userInterface: DualModeLoginConsole) {
      interactor = DualModeLoginInteractor()
      service = DualModeLoginServiceStub()
      presenter = DualModeLoginPresenter()
      
      userInterface.interactor = interactor
      interactor.output = presenter
      interactor.service = service
      service.output = interactor
      presenter.output = userInterface
    }
  }
}


