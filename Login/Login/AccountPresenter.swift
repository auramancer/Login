protocol AccountViewInput: class  {
  func showErrorMessage(_ message: String)
}

class AccountPresenter {
  struct Wording {
    static let inputIsEmpty = "Enter an email or phone number"
    static let accountIsNotRecognized = "Couldn't find your account"
    static let serviceIsNotAvailable = "Sorry, something went wrong there. Try again."
  }
  
  weak var view: AccountViewInput?
  
  var errorMessages: [AccountError : String] = [
    .inputIsEmpty : Wording.inputIsEmpty,
    .accountIsNotRecognized : Wording.accountIsNotRecognized,
    .serviceIsNotAvailable : Wording.serviceIsNotAvailable
  ]
  
  func showError(_ error: AccountError) {
    guard let message = errorMessages[error] else { return }
    
    view?.showErrorMessage(message)
  }
}
