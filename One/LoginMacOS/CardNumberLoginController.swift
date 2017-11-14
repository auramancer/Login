class CardNumberLoginController: ConsoleController {
  var configurator: Configurator?
  
  var interactor: CardNumberLoginInteractorInput?
  
  var cardNumber = ""
  var pin = ""
  var shouldRemember = false
  var loginIsEnabled = false

  var verificationCodePage: LoginVerificationController!
  
  override func start() {
    configurator = Configurator(for: self)
    
    interactor?.reset()
    
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
    if loginIsEnabled {
      output("6 Login")
    }
    output("")
  }
  
  override func excuteCommand(_ command: Command) {
    switch command.type {
    case "1":
      changeCardNumber(command)
    case "2":
      changePIN(command)
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
  
  func changeCardNumber(_ command: Command) {
    cardNumber = command.parameters ?? ""
    
    interactor?.changeCardNumber(to: cardNumber)
    
    waitForCommand()
  }
  
  func changePIN(_ command: Command) {
    pin = command.parameters ?? ""
    
    interactor?.changePIN(to: pin)
    
    waitForCommand()
  }
  
  func changeRememberMe() {
    shouldRemember = !shouldRemember
    
    waitForCommand()
  }
  
  func login() {
    interactor?.logIn(shouldRememberCardNumber: shouldRemember)
  }
  
  func forgottenCardNumber() {
    interactor?.helpWithCardNumber()
  }
  
  func forgottenPIN() {
    interactor?.helpWithPIN()
  }
}

extension CardNumberLoginController: CardNumberLoginPresenterOutput {
  func showCardNumber(_ cardNumber: String) {
    self.cardNumber = cardNumber
  }
  
  func showPIN(_ pin: String) {
    self.pin = pin
  }
  
  func enableLogin() {
    loginIsEnabled = true
  }
  
  func disableLogin() {
    loginIsEnabled = false
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
  
  func goToVerificationPage(withDetails details: CardNumberLoginDetails) {
    verificationCodePage = LoginVerificationController(details: details)
    verificationCodePage.start()
    
    waitForCommand()
  }
}

extension CardNumberLoginController {
  class Configurator {
    var presenter: CardNumberLoginPresenter
    var interactor: CardNumberLoginInteractor
    var service: CardNumberLoginServiceStub
    
    init(for userInterface: CardNumberLoginController) {
      interactor = CardNumberLoginInteractor()
      presenter = CardNumberLoginPresenter()
      service = CardNumberLoginServiceStub()
      
      interactor.output = presenter
      interactor.service = service
      presenter.output = userInterface
      service.output = interactor
      userInterface.interactor = interactor
    }
  }
}
