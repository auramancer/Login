protocol AccountInteractorOutput: class {
  func showError()
  func showPasswordInput()
}

protocol AccountInteractorService {
  func validateAccount(_ id: String, completionHandler: (Bool)->Void)
}

class AccountInteractor {
  weak var output: AccountInteractorOutput?
  var service: AccountInteractorService!
  
  func validateAccount(_ id: String) {
    if id == "" {
      output?.showError()
    }
    else {
      service.validateAccount(id, completionHandler: didValidateAccount)
    }
  }
  
  func didValidateAccount(isValid: Bool) {
    if isValid {
      output?.showPasswordInput()
    }
  }
}
