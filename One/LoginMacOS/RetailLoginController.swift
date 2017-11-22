class RetailLoginController: ConsoleController {
  var configurator: Configurator?
  
  var interactor: RetailLoginInteractorInput?
  
  var cardNumber = ""
  var pin = ""
  var shouldRemember = false
  var canLogin = false

  var loginVerificationController: LoginVerificationController!
  
  override func load() {
    configurator = Configurator(for: self)
    
    output("🗝 Retail Log In 🗝\n")
    
    interactor?.load()
    super.load()
  }
  
  override func outputState() {
    output("")
    output("1 Membership Card Number [\(cardNumber)]")
    output("2 PIN [\(pin)]")
    output("3 Forgotten Membership Card No.")
    output("4 Forgotten PIN")
    output("5 Remember me [\(shouldRemember ? "Y" : "N")]")
    if canLogin {
      output("6 Login")
    }
    output("")
  }
  
  override func excuteCommand(_ command: Command) {
    switch command.type {
    case "1":
      changeIdentifier(command)
    case "2":
      changeCredential(command)
    case "3":
      forgottenCardNumber()
    case "4":
      forgottenPIN()
    case "5":
      changeRememberMe()
    case "6":
      login()
    default:
      outputAndWaitForCommand()
    }
  }
  
  func changeIdentifier(_ command: Command) {
    cardNumber = command.parameters ?? ""

    interactor?.changeIdentifier(to: cardNumber)
    
    outputAndWaitForCommand()
  }
  
  func changeCredential(_ command: Command) {
    pin = command.parameters ?? ""
    
    interactor?.changeCredential(to: pin)
    
    outputAndWaitForCommand()
  }
  
  func changeRememberMe() {
    shouldRemember = !shouldRemember
    
    interactor?.changeShouldRememberIdentity(to: shouldRemember)
    
    outputAndWaitForCommand()
  }
  
  func login() {
    interactor?.logIn()
  }
  
  func forgottenCardNumber() {
    interactor?.helpWithIdentifier()
  }
  
  func forgottenPIN() {
    interactor?.helpWithCredential()
  }
}

extension RetailLoginController: RetailLoginPresenterOutput {
  func changeIdentifier(to cardNumber: String) {
    self.cardNumber = cardNumber
  }
  
  func changeCredential(to pin: String) {
    self.pin = pin
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
    case .cardNumber:
      output("Maybe it's qwer?")
    case .pin:
      output("Maybe it's 4321?")
    default:
      break
    }
  }
  
  func goToVerificationPage(withIdentity identity: RetailIdentity) {
    loginVerificationController = LoginVerificationController(identity: identity)
    loginVerificationController.load()
  }
}

extension RetailLoginController {
  class Configurator {
    var presenter: RetailLoginPresenter
    var interactor: RetailLoginInteractor
    var service: RetailLoginServiceStub
    
    init(for userInterface: RetailLoginController) {
      interactor = RetailLoginInteractor()
      presenter = RetailLoginPresenter()
      service = RetailLoginServiceStub()
      
      interactor.output = presenter
      interactor.service = service
      presenter.output = userInterface
      service.output = interactor
      userInterface.interactor = interactor
    }
  }
}
