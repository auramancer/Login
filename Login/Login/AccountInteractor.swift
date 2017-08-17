protocol AccountInteractorOutput: class {
  func showError(_ error: AccountError)
  func showPasswordInput()
}

protocol AccountInteractorService {
  func validateAccount(_ id: String, completionHandler: (Bool?, AccountError?) -> Void)
}

enum AccountError {
  case inputIsEmpty
  case accountIsNotRecognized
  case serviceIsNotAvailable
}

class AccountInteractor {
  weak var output: AccountInteractorOutput?
  var service: AccountInteractorService!
  
  func validateAccount(_ id: String) {
    if id == "" {
      output?.showError(.inputIsEmpty)
    }
    else {
      service.validateAccount(id, completionHandler: didValidateAccount)
    }
  }
  
  func didValidateAccount(isValid: Bool?, error: AccountError?) {
    if let error = error {
      output?.showError(error)
      return
    }
    
    didValidateAccount(isValid: isValid!)
  }
  
  func didValidateAccount(isValid: Bool) {
    if isValid {
      output?.showPasswordInput()
    }
    else {
      output?.showError(.accountIsNotRecognized)
    }
  }
}
