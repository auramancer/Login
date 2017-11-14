class LoginVerificationController: ConsoleController {
  var configurator: Configurator?
  
  var interactor: LoginVerificationInteractor?
  
  var details: CardNumberLoginDetails
  var code = ""
  var verifyIsEnabled = false
  
  init(details: CardNumberLoginDetails) {
    self.details = details
  }
  
  override func start() {
    configurator = Configurator(for: self)
    
    interactor?.reset(withDetails: details, shouldRememberCardNumber: false)
    
    output("📮 Verification Code 📮\n")
    super.start()
  }
  
  override func outputState() {
    output("")
    output("1 Verification Code [\(code)]")
    output("2 Resend Verification Code")
    if verifyIsEnabled {
      output("2 Verify")
    }
    output("")
  }
  
  override func excuteCommand(_ command: Command) {
    switch command.type {
    case "1":
      changeCode()
    case "2":
      interactor?.resendCode()
    case "3":
      interactor?.verify()
    default:
      waitForCommand()
    }
  }
  
  func changeCode() {
    interactor?.changeCode(to: code)
    
    waitForCommand()
  }
  
  func resendCode() {
    interactor?.resendCode()
    
    waitForCommand()
  }
  
  func verify() {
    interactor?.verify()
  }
}

extension LoginVerificationController: LoginVerificationPresenterOutput {
  func enableVerify() {
    verifyIsEnabled = true
  }
  
  func disableVerify() {
    verifyIsEnabled = false
  }
  
  func goTo(_ destination: LoginDestination) {
    
  }
}

extension LoginVerificationController {
  class Configurator {
    var presenter: LoginVerificationPresenter
    var interactor: LoginVerificationInteractor
    var service: LoginVerificationServiceStub
    
    init(for userInterface: LoginVerificationController) {
      interactor = LoginVerificationInteractor()
      presenter = LoginVerificationPresenter()
      service = LoginVerificationServiceStub()
      
      interactor.output = presenter
      interactor.service = service
      presenter.output = userInterface
      service.output = interactor
      userInterface.interactor = interactor
    }
  }
}
