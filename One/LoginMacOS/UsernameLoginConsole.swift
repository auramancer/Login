import Foundation

class UsernameLoginConsole: Console {
  var configurator: Configurator?
  
  var interactor: LoginInteractorInput?
  var isEnteringUsername = false
  
  func start() {
    configurator = Configurator(for: self)
    
    show("Username Log In")
    enterDetails()
  }
  
  private func enterDetails() {
    enterUsername()
    enterPassword()
  }
  
  private func enterUsername() {
    isEnteringUsername = true
    
    let username = entered("Username")
    if username == "?" {
      askIfForgottenUsername()
    }
    else {
      interactor?.updateId(username)
    }
    
    isEnteringUsername = false
  }
  
  private func askIfForgottenUsername() {
    if confirmed("Forgotton username") {
      interactor?.helpWithId()
    }
    else {
      enterUsername()
    }
  }
  
  private func enterPassword() {
    let password = entered("Password")
    if password == "?" {
      askIfForgottenPassword()
    }
    else {
      interactor?.updateSecret(password)
    }
  }
  
  private func askIfForgottenPassword() {
    if confirmed("Forgotton password") {
      interactor?.helpWithSecret()
    }
    else {
      enterPassword()
    }
  }
  
  private func confirmedLogin() {
    if confirmed("Login") {
      interactor?.logIn()
    }
    else {
      enterDetails()
    }
  }
}

extension UsernameLoginConsole: LoginPresenterOutput {
  func loginWasEnabled() {
    if !isEnteringUsername {
      confirmedLogin()
    }
  }
  
  func loginWasDisabled() {
    if !isEnteringUsername {
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
      enterUsername()
    case .forgottenPassword:
      show("Maybe it's 123?")
      enterPassword()
    default:
      break
    }
  }
}

extension UsernameLoginConsole {
  class Configurator {
    var presenter: LoginPresenter
    var interactor: UsernameLoginInteractor
    var service: UsernameLoginServiceStub
    
    init(for userInterface: UsernameLoginConsole) {
      interactor = UsernameLoginInteractor()
      service = UsernameLoginServiceStub()
      presenter = LoginPresenter()
      
      userInterface.interactor = interactor
      interactor.output = presenter
      interactor.service = service
      service.output = interactor
      presenter.output = userInterface
    }
  }
}
