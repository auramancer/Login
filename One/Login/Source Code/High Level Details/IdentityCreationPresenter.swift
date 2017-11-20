protocol IdentityCreationPresenterOutput: class {
  func changeCanCreate(to: Bool)
  func changeIsCreating(to: Bool)
  
  func showMessage(_: LoginMessage)
  func clearMessage()
  
  func leave()
}

class IdentityCreationPresenter {
  weak var output: IdentityCreationPresenterOutput?
  
  private let defaultMessage = LoginMessage(text: Wording.defaultMessage, style: .default)
  
  struct Wording {
    static let defaultMessage = "As this is your first time logging in with these details we need to ask for some further information.\n\n" +
      "Please choose a Username and Password, you can login with these details, or continue to use your membership number and PIN."
  }
  
  private func errorMessage(withErrors errors: [IdentityCreationError]) -> LoginMessage {
    let text = errors.map { $0.message }.joined(separator: "\n\n")
    return LoginMessage(text: text, style: .error)
  }
}

extension IdentityCreationPresenter: IdentityCreationInteractorOutput {
  func didLoad(canCreate: Bool) {
    output?.showMessage(defaultMessage)
    output?.changeCanCreate(to: canCreate)
  }
  
  func canCreateDidChange(to canCreate: Bool) {
    output?.changeCanCreate(to: canCreate)
  }
  
  func creationDidBegin() {
    output?.clearMessage()
    output?.changeIsCreating(to: true)
  }
  
  func creationDidEnd() {
    output?.changeIsCreating(to: false)
    output?.leave()
  }
  
  func creationDidFail(withErrors errors: [String]) {
    output?.changeIsCreating(to: false)
    output?.showMessage(LoginMessage(text: errors.joined(separator: "\n\n"), style: .error))
  }
}
