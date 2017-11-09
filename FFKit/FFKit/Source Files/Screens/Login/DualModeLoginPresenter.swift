protocol DualModeLoginPresenterOutput: LoginPresenterOutput {
  func switchMode(to: LoginMode)
}

class DualModeLoginPresenter {
  weak var output: DualModeLoginPresenterOutput?
}

extension DualModeLoginPresenter: DualModeLoginInteractorOutput {
  func updateMode(_ mode: LoginMode) {
    output?.switchMode(to: mode)
  }
}

