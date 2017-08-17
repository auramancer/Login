protocol AccountInteractorOutput: class {
  func showError(_ error: AccountError)
  func showPasswordInput()
}

protocol AccountInteractorService {
  func validateAccount(_ id: String, completionHandler: (Bool)->Void)
}

enum AccountError {
  case inputIsEmpty
  case accountIsNotRecognized
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
  
  func didValidateAccount(isValid: Bool) {
    if isValid {
      output?.showPasswordInput()
    }
    else {
      output?.showError(.accountIsNotRecognized)
    }
  }
}
