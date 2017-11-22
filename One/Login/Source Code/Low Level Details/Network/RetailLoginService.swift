typealias Session = String

class RetailLoginService: MasService<RetailIdentity, Session>, RetailLoginServiceInput {
  weak var output: RetailLoginServiceOutput?
  
  func logIn(withRetailIdentity identity: RetailIdentity) {
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
  
  override func convertToJson(_ input: RetailIdentity) -> Json? {
    return Json([
      "login": [
        "cardNo": input.identifier,
        "pin": input.credential
      ]
    ])
  }
  
  override func convertToOutput(from response: Json) -> Session? {
    guard let session = response["session"]?.asString() else { return nil }
    
    return session
  }
}
