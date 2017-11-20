protocol BiometricsLoginInteractorInput: class {
  func load()
  
  func enableBiometricsLogin(for identity: DigitalIdentity)
}

protocol BiometricsLoginInteractorOutput: class {
  func showEnableBiometricsLoginPrompt()
  func didEnableBiometricsLogin()
}

class BiometricsLoginInteractor {
  var shouldShowEnablePrompt: Bool {
    return true
  }
  
  var shouldShowLoginPrompt: Bool {
    return true
  }
}
