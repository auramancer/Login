struct IdentityCreationRequest {
  let membershipNumber: String
  let verificationCode: String
  var username: String?
  var password: String?
}

protocol IdentityCreationError {
  var message: String { get }
}

protocol IdentityCreationInteractorInput: class {
  func load(withRequest: IdentityCreationRequest)
  
  func changeUsername(to: String)
  func changePassword(to: String)
  
  func create()
}

protocol IdentityCreationInteractorOutput: class {
  func didLoad()
  
  func canCreateDidChange(to: Bool)
  
  func creationDidBegin()
  func creationDidEnd()
  func creationDidFail(withErrors: [IdentityCreationError])
}

protocol IdentityCreationServiceInput: class {
  func create(withRequest: IdentityCreationRequest)
}

protocol IdentityCreationServiceOutput: class {
  func creationDidSucceed()
  func creationDidFail(dueTo: [IdentityCreationError])
}

class IdentityCreationInteractor {
  weak var output: IdentityCreationInteractorOutput?
  var service: IdentityCreationServiceInput?
  
  private var request: IdentityCreationRequest!
  
  private var canCreate = false {
    didSet {
      if canCreate != oldValue {
        output?.canCreateDidChange(to: canCreate)
      }
    }
  }
  
  private func updateCanCreate() {
    canCreate = request?.isValid ?? false
  }
}

extension IdentityCreationInteractor: IdentityCreationInteractorInput {
  func load(withRequest request: IdentityCreationRequest) {
    self.request = request
    
    output?.didLoad()
  }
  
  func changeUsername(to username: String) {
    request?.username = username
    
    updateCanCreate()
  }
  
  func changePassword(to password: String) {
    request?.password = password
    
    updateCanCreate()
  }
  
  func create() {
    service?.create(withRequest: request!)
    
    output?.creationDidBegin()
  }
}

extension IdentityCreationInteractor: IdentityCreationServiceOutput {
  func creationDidSucceed() {
    output?.creationDidEnd()
  }
  
  func creationDidFail(dueTo errors: [IdentityCreationError]) {
    output?.creationDidFail(withErrors: errors)
  }
}

extension IdentityCreationRequest {
  init(membershipNumber: String, verificationCode: String) {
    self.init(membershipNumber: membershipNumber,
              verificationCode: verificationCode,
              username: nil,
              password: nil)
  }
  
  var isValid: Bool {
    return usernameIsValid && passwordIsValid
  }
  
  private var usernameIsValid: Bool {
    return username?.containsMatch(of: "^[a-zA-Z0-9]{5,16}?$") ?? false
  }
  
  private var passwordIsValid: Bool {
    return password?.containsMatch(of: "^[a-zA-Z0-9]{5,32}?$") ?? false
  }
}
