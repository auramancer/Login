protocol AccountInteractorOutput: class {
  func showError()
}

class AccountInteractor {
  weak var output: AccountInteractorOutput?
  
  func validateAccount(_ id: String) {
    if id == "" {
      output?.showError()
    }
  }
}
