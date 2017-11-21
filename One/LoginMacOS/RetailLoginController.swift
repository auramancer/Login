class RetailLoginController: ConsoleController {
  var configurator: Configurator?
  
  var interactor: RetailLoginInteractorInput?
  
  var cardNumber = ""
  var pin = ""
  var shouldRemember = false
  var canLogin = false

//  var verificationCodePage: LoginVerificationController!
  
  override func start() {
    configurator = Configurator(for: self)
    
    interactor?.load()
    
    output("🗝 CardNumber Log In 🗝\n")
    super.start()
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
      waitForCommand()
    }
  }
  
  func changeIdentifier(_ command: Command) {
    cardNumber = command.parameters ?? ""
    
    interactor?.changeIdentifier(to: cardNumber)
    
    waitForCommand()
  }
  
  func changeCredential(_ command: Command) {
    pin = command.parameters ?? ""
    
    interactor?.changeCredential(to: pin)
    
    waitForCommand()
  }
  
  func changeRememberMe() {
    shouldRemember = !shouldRemember
    interactor?.changeShouldRememberIdentity(to: shouldRemember)
    
    waitForCommand()
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
  
  func goToVerificationPage(withRequest request: RetailIdentity) {
//    verificationCodePage = LoginVerificationController(request: request)
//    verificationCodePage.start()
    
    waitForCommand()
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
