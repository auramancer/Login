protocol UserNameLoginPresenterOutput: class {
  func setLogInEnabled(to: Bool)
  func showActivityMessage(_: String?)
  func hideActivityMessage()
  func showErrorMessage(_: String?)
  func hideErrorMessage()
  func close()
}

class UserNameLoginPresenter {
  weak var output: UserNameLoginPresenterOutput?
}

extension UserNameLoginPresenter: UserNameLoginInteractorOutput {
  func updateState(_ state: UserNameLoginState) {
    output?.setLogInEnabled(to: state == .ready)
    updateActivity(for: state)
  }
  
  private func updateActivity(for state: UserNameLoginState) {
    if state == .inProgress {
      output?.hideErrorMessage()
      output?.showActivityMessage(activityMessage)
    }
    else {
      output?.hideActivityMessage()
    }
  }
  
  private var activityMessage: String? {
    return nil // No text
  }
  
  func updateResult(_ result: UserNameLoginResult) {
    switch result {
    case let .failed(errors):
      let message = errorMessage(for: errors)
      output?.showErrorMessage(message)
    default:
      output?.close()
    }
  }
  
  private func errorMessage(for errors: [UserNameLoginError]) -> String {
    return "" // TBD
  }
}
