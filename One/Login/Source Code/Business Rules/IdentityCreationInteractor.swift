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
  func creationDidFail(dueTo: [LoginError])
}

class IdentityCreationInteractor {
  weak var output: IdentityCreationInteractorOutput?
  var service: IdentityCreationServiceInput?
  var storage: RetailLoginStorage?
  
  var retailIdentity: RetailIdentity!
  var digitalIdentity = DigitalIdentity(identifier: "", credential: "")
  
  fileprivate var canCreate: Bool {
    return digitalIdentity.isValidForCreation
  }
  
  fileprivate var canCreateOldValue = false
  
  fileprivate func outputCanCreateDidChange() {
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
    if let token = retailIdentity.authenticationToken {
      storage?.saveToken(token)
    }
    
    output?.creationDidEnd()
  }
  
  func creationDidFail(dueTo errors: [LoginError]) {
    let messages = errors.map { $0.message }
    output?.creationDidFail(withErrors: messages)
  }
}

extension DigitalIdentity {
  var isValidForCreation: Bool {
    return identifierIsValidForCreation && credentialIsValidForCreation
  }
  
  fileprivate var identifierIsValidForCreation: Bool {
    return identifier.containsMatch(of: "^[a-zA-Z0-9]{5,16}?$")
  }
  
  fileprivate var credentialIsValidForCreation: Bool {
    return credential.containsMatch(of: "^[a-zA-Z0-9]{5,32}?$")
  }
}
