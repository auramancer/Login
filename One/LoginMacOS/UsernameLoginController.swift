class DigitalLoginController: ConsoleController {
  var configurator: Configurator?
  
  var interactor: DigitalLoginInteractorInput?
  
  var username = ""
  var password = ""
  var canLogin = false
  var shouldRemember = false
  
  override func start() {
    configurator = Configurator(for: self)
    
    interactor?.load()
    
    output("🔑 Username Log In 🔑")
    super.start()
  }
  
  override func outputState() {
    output("")
    output("1 Username [\(username)]")
    output("2 Password [\(password)]")
    output("3 Forgotten Username")
    output("4 Forgotten Password")
    output("5 Remember me [\(shouldRemember ? "Y" : "N")]")
    if canLogin {
      output("6 Login")
    }
    output("")
  }
  
  override func excuteCommand(_ command: Command) {
    switch command.type {
    case "1":
      changeUsername(command)
    case "2":
      changePassword(command)
    case "3":
      forgottenUsername()
    case "4":
      forgottenPassword()
    case "5":
      changeRememberMe()
    case "6":
      login()
    default:
      waitForCommand()
    }
  }
  
  func changeUsername(_ command: Command) {
    interactor?.changeUsername(to: command.parameters ?? "")
    
    waitForCommand()
  }
  
  func changePassword(_ command: Command) {
    interactor?.changePassword(to: command.parameters ?? "")
    
    waitForCommand()
  }
  
  func changeRememberMe() {
    shouldRemember = !shouldRemember
    
    waitForCommand()
  }
  
  func login() {
    interactor?.logIn(shouldRememberUsername: shouldRemember)
  }
  
  func forgottenUsername() {
    interactor?.helpWithUsername()
  }
  
  func forgottenPassword() {
    interactor?.helpWithPassword()
  }
}

extension DigitalLoginController: DigitalLoginPresenterOutput {
  func changeUsername(to username: String) {
    self.username = username
  }
  
  func changePassword(to password: String) {
    self.password = password
  }
  
  func changeCanLogin(to canLogin: Bool) {
    self.canLogin = canLogin
  }

  func changeIsLoggingIn(to isLoggingIn: Bool) {
    if isLoggingIn {
      showProgress()
    }
    else {
      hideProgress()
    }
  }
  
  func goToHelpPage(for help: LoginHelp) {
    switch help {
    case .username:
      output("Maybe it's asdf?")
    case .password:
      output("Maybe it's 1234?")
    default:
      break
    }
  }
}

extension DigitalLoginController {
  class Configurator {
    var presenter: DigitalLoginPresenter
    var interactor: DigitalLoginInteractor
    var service: DigitalLoginServiceStub
    
    init(for userInterface: DigitalLoginController) {
      interactor = DigitalLoginInteractor()
      presenter = DigitalLoginPresenter()
      service = DigitalLoginServiceStub()
      
      interactor.output = presenter
      interactor.service = service
      presenter.output = userInterface
      service.output = interactor
      userInterface.interactor = interactor
    }
  }
}
