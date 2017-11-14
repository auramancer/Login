class UsernameLoginController: ConsoleController {
  var configurator: Configurator?
  
  var interactor: UsernameLoginInteractorInput?
  
  var username = ""
  var password = ""
  var shouldRemember = false
  var loginIsEnabled = false
  
  override func start() {
    configurator = Configurator(for: self)
    
    interactor?.reset()
    
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
    if loginIsEnabled {
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

extension UsernameLoginController: UsernameLoginPresenterOutput {
  func showUsername(_ username: String) {
    self.username = username
  }
  
  func showPassword(_ password: String) {
    self.password = password
  }
  
  func enableLogin() {
    loginIsEnabled = true
  }
  
  func disableLogin() {
    loginIsEnabled = false
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

extension UsernameLoginController {
  class Configurator {
    var presenter: UsernameLoginPresenter
    var interactor: UsernameLoginInteractor
    var service: UsernameLoginServiceStub
    
    init(for userInterface: UsernameLoginController) {
      interactor = UsernameLoginInteractor()
      presenter = UsernameLoginPresenter()
      service = UsernameLoginServiceStub()
      
      interactor.output = presenter
      interactor.service = service
      presenter.output = userInterface
      service.output = interactor
      userInterface.interactor = interactor
    }
  }
}
