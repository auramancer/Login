class IdentityCreationController: ConsoleController {
  var configurator: Configurator?
  
  var interactor: IdentityCreationInteractor?
  
  var identity: RetailIdentity
  var username = ""
  var password = ""
  var canCreate = false
  
  var identityCreationController: IdentityCreationController!
  
  init(identity: RetailIdentity) {
    self.identity = identity
  }
  
  override func load() {
    configurator = Configurator(for: self)
    
    output("🔧 Create Identity 🔧\n")
    
    interactor?.load(withRetailIdentity: identity)
    super.load()
  }
  
  override func outputState() {
    output("")
    output("1 Username [\(username)]")
    output("2 Password [\(password)]")
    if canCreate {
      output("4 Save")
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
      create()
    default:
      outputAndWaitForCommand()
    }
  }
  
  func changeIdentifier(_ command: Command) {
    username = command.parameters ?? ""
    
    interactor?.changeIdentifier(to: username)
    
    outputAndWaitForCommand()
  }
  
  func changeCredential(_ command: Command) {
    password = command.parameters ?? ""
    
    interactor?.changeCredential(to: password)
    
    outputAndWaitForCommand()
  }
  
  func create() {
    interactor?.create()
  }
}

extension IdentityCreationController: IdentityCreationPresenterOutput {
  func changeCanCreate(to canCreate: Bool) {
    self.canCreate = canCreate
  }
  
  func changeIsCreating(to isCreating: Bool) {
    if isCreating {
      showProgress()
    }
    else {
      hideProgress()
    }
  }
}

extension IdentityCreationController {
  class Configurator {
    var presenter: IdentityCreationPresenter
    var interactor: IdentityCreationInteractor
    var service: IdentityCreationServiceStub
    
    init(for userInterface: IdentityCreationController) {
      interactor = IdentityCreationInteractor()
      presenter = IdentityCreationPresenter()
      service = IdentityCreationServiceStub()
      
      interactor.output = presenter
      interactor.service = service
      presenter.output = userInterface
      service.output = interactor
      userInterface.interactor = interactor
    }
  }
}

