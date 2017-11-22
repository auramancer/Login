typealias SessionId = String

class DigitalLoginService: MasService<DigitalIdentity, SessionId>, DigitalLoginServiceInput {
  weak var output: DigitalLoginServiceOutput?
  
  func logIn(withDigitalIdentity identity: DigitalIdentity) {
    invoke(identity, completion: handleResult)
  }
  
  private func handleResult(_ result: Result) {
    switch result {
    case let .succeeded(session):
      output?.loginDidSucceed(withSession: session)
    case let .failed(errors), let .notAvailable(errors):
      output?.loginDidFail(dueTo: errors as! [MasError])
    }
  }
  
  override var method: String {
    return "login"
  }
  
  override func convertToJson(_ input: DigitalIdentity) -> Json? {
    return Json([
      "login": [
        "user": input.identifier,
        "password": input.credential
      ]
    ])
  }
  
  override func convertToOutput(from response: Json) -> SessionId? {
    guard let session = response["session"]?.asString() else { return nil }
    
    return session
  }
}

extension MasError: LoginError {
}
