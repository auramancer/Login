class DualModeLoginService: DualModeLoginServiceInput {
  weak var output: DualModeLoginServiceOutput?
  
  fileprivate lazy var digitalService = DigitalLoginService()
  fileprivate lazy var retailService = RetailLoginService()
  
  func logIn(withDigitalIdentity identity: DigitalIdentity) {
    digitalService.output = output
    digitalService.logIn(withDigitalIdentity: identity)
  }
  
  func logIn(withRetailIdentity identity: RetailIdentity) {
    retailService.output = output
    retailService.logIn(withRetailIdentity: identity)
  }
}

