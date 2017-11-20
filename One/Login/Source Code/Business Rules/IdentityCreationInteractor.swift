protocol IdentityCreationError {
  var message: String { get }
}

protocol IdentityCreationInteractorInput: class {
  func load(withRetailIdentity: RetailIdentity)
  
  func changeIdentifier(to: String)
  func changeCredential(to: String)
  
  func create()
}

protocol IdentityCreationInteractorOutput: class {
  func didLoad(canCreate: Bool)
  
  func canCreateDidChange(to: Bool)
  
  func creationDidBegin()
  func creationDidEnd()
  func creationDidFail(withErrors: [String])
}

protocol IdentityCreationServiceInput: class {
  func create(digitalIdentity: DigitalIdentity, withRetailIdentity: RetailIdentity)
}

protocol IdentityCreationServiceOutput: class {
  func creationDidSucceed()
  func creationDidFail(dueTo: [IdentityCreationError])
}

class IdentityCreationInteractor {
  weak var output: IdentityCreationInteractorOutput?
  var service: IdentityCreationServiceInput?
  
  var retailIdentity: RetailIdentity!
  var digitalIdentity = DigitalIdentity(identifier: "", credential: "")
  
  private var canCreate: Bool {
    return digitalIdentity.isValidForCreation
  }
  
  private var canCreateOldValue = false
  
  private func outputCanCreateDidChange() {
    let newValue = canCreate
    
    if newValue != canCreateOldValue {
      output?.canCreateDidChange(to: newValue)
      canCreateOldValue = newValue
    }
  }
}

extension IdentityCreationInteractor: IdentityCreationInteractorInput {
  func load(withRetailIdentity identity: RetailIdentity) {
    retailIdentity = identity
    canCreateOldValue = canCreate
    
    output?.didLoad(canCreate: canCreateOldValue)
  }
  
  func changeIdentifier(to identifier: String) {
    digitalIdentity.identifier = identifier
    
    outputCanCreateDidChange()
  }
  
  func changeCredential(to credential: String) {
    digitalIdentity.credential = credential
    
    outputCanCreateDidChange()
  }
  
  func create() {
    service?.create(digitalIdentity: digitalIdentity, withRetailIdentity: retailIdentity)
    
    output?.creationDidBegin()
  }
}

extension IdentityCreationInteractor: IdentityCreationServiceOutput {
  func creationDidSucceed() {
    output?.creationDidEnd()
  }
  
  func creationDidFail(dueTo errors: [IdentityCreationError]) {
    let messages = errors.map { $0.message }
    output?.creationDidFail(withErrors: messages)
  }
}

extension DigitalIdentity {
  var isValidForCreation: Bool {
    return identifierIsValidForCreation && credentialIsValidForCreation
  }
  
  private var identifierIsValidForCreation: Bool {
    return identifier.containsMatch(of: "^[a-zA-Z0-9]{5,16}?$")
  }
  
  private var credentialIsValidForCreation: Bool {
    return credential.containsMatch(of: "^[a-zA-Z0-9]{5,32}?$")
  }
}
