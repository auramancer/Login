class LoginVerificationController: ConsoleController {
  var configurator: Configurator?
  
  var interactor: LoginVerificationInteractor?
  
  var identity: RetailIdentity
  var code = ""
  var canVerify = false
  
  var identityCreationController: IdentityCreationController!
  
  init(identity: RetailIdentity) {
    self.identity = identity
  }
  
  override func load() {
    configurator = Configurator(for: self)
    
    output("📮 Verify Identity 📮\n")
    
    interactor?.load(withIdentity: identity)
  }
  
  override func outputState() {
    output("")
    output("1 Verification Code [\(code)]")
    output("2 Resend Verification Code")
    if canVerify {
      output("3 Verify")
    }
    output("")
  }
  
  override func excuteCommand(_ command: Command) {
    switch command.type {
    case "1":
      changeCode(command)
    case "2":
      interactor?.resendCode(confirmed: false)
    case "3":
      interactor?.verify()
    case "4":
      resendCode()
    default:
      outputAndWaitForCommand()
    }
  }
  
  func changeCode(_ command: Command) {
    code = command.parameters ?? ""
    
    interactor?.changeCode(to: code)
    
    outputAndWaitForCommand()
  }
  
  func resendCode() {
    interactor?.resendCode(confirmed: true)
    
    outputAndWaitForCommand()
  }
  
  func verify() {
    interactor?.verify()
  }
}

extension LoginVerificationController: LoginVerificationPresenterOutput {
  func changeCanVerify(to canVerify: Bool) {
    self.canVerify = canVerify
  }
  
  func changeIsVerifying(to isVerifying: Bool) {
    if isVerifying {
      showProgress()
    }
    else {
      hideProgress()
    }
  }
  
  func showResendCodeConfirmaiton(_ confirmation: ResendCodeConfirmaiton) {
    output("")
    output("\(confirmation.message)")
    output("4 \(confirmation.confirmActionText)")
    output("5 \(confirmation.cancelActionText)")
    output("")
    
    waitForCommand()
  }
  
  func goToIdentityCreationPage(withIdentity identity: RetailIdentity) {
    identityCreationController = IdentityCreationController(identity: identity)
    identityCreationController.load()
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
      interactor.loginService = service
      presenter.output = userInterface
      service.output = interactor
      userInterface.interactor = interactor
    }
  }
}
