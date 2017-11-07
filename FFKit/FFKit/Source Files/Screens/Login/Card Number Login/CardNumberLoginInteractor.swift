struct CardNumberLoginDetails {
  let cardNumber: String
  let pin: String
}

protocol CardNumberLoginInteractorInput: class {
  func updateDetail(_: CardNumberLoginDetails)
  func logIn()
}

enum CardNumberLoginState {
  case notReady
  case ready
  case inProgress
}

enum CardNumberLoginResult {
  case succeeded
  case failed([CardNumberLoginError])
}

protocol CardNumberLoginInteractorOutput: class {
  func updateState(_: CardNumberLoginState)
  func updateResult(_: CardNumberLoginResult)
}

protocol CardNumberLoginServiceInput: class {
  func logIn(withDetails: CardNumberLoginDetails)
}

protocol CardNumberLoginServiceOutput: class {
  func didLogIn()
  func didFailToLogIn(dueTo: [CardNumberLoginError])
}

enum CardNumberLoginError: Error {
  case unrecognized
  case serviceNotAvailable
}

class CardNumberLoginInteractor {
  weak var output: CardNumberLoginInteractorOutput?
  weak var service: CardNumberLoginServiceInput?
  
  var details: CardNumberLoginDetails?
}

extension CardNumberLoginInteractor: CardNumberLoginInteractorInput {
  func updateDetail(_ details: CardNumberLoginDetails) {
    self.details = details
  
    output?.updateState(canLogIn ? .ready : .notReady)
  }
  
  private var canLogIn: Bool {
    return cardNumberIsValid && pinIsValid
  }
  
  private var cardNumberIsValid: Bool {
    guard let cardNumber = details?.cardNumber else { return false }
    
    return cardNumber != ""
  }
  
  private var pinIsValid: Bool {
    guard let pin = details?.pin else { return false }
    
    return pin != ""
  }
  
  func logIn() {
    guard let details = details else { return }
    
    service?.logIn(withDetails: details)
    
    output?.updateState(.inProgress)
  }
}

extension CardNumberLoginInteractor: CardNumberLoginServiceOutput {
  func didLogIn() {
    output?.updateState(.ready)
    output?.updateResult(.succeeded)
  }
  
  func didFailToLogIn(dueTo errors: [CardNumberLoginError]) {
    output?.updateState(.ready)
    output?.updateResult(.failed(errors))
  }
}
