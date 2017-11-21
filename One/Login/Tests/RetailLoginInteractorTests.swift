import XCTest

class RetailLoginInteractorTests: XCTestCase {
  private var interactor: RetailLoginInteractor!
  private var output: RetailLoginInteractorOutputSpy!
  private var service: RetailLoginServiceSpy!
  private var storage: RetailLoginStorageSpy!
  
  private var shouldRemember = true
  
  typealias Data = LoginTestData
  private let cardNumber = Data.validCardNumber
  private let pin = Data.validPIN
  private let idOnlyIdentity = Data.retailIdentityIdOnly
  private let session = Data.session
  
  override func setUp() {
    super.setUp()
    
    output = RetailLoginInteractorOutputSpy()
    service = RetailLoginServiceSpy()
    storage = RetailLoginStorageSpy()
    
    interactor = RetailLoginInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
    
    shouldRemember = true
  }
  
  func testLoadWithNoRememberedCardNumber() {
    interactor.load()
    
    assertOutputReceived(identity: Data.emptyRetailIdentity,
                         canLogin: false)
  }
  
  func testLoadWithRememberedCardNumber() {
    storage.identitySpy = idOnlyIdentity
    
    interactor.load()
    
    assertOutputReceived(identity: idOnlyIdentity,
                         canLogin: false)
  }
  
  func testChangeCardNumber() {
    assertOutputReceived(canLogin: nil, whenChangeCardNumber: "", to: cardNumber, pinRemains: "")
    assertOutputReceived(canLogin: true, whenChangeCardNumber: "", to: cardNumber, pinRemains: pin)
    assertOutputReceived(canLogin: false, whenChangeCardNumber: cardNumber, to: "", pinRemains: pin)
  }
  
  func testChangePIN() {
    assertOutputReceived(canLogin: nil, whenChangePIN: "", to: pin, cardNumberRemains: "")
    assertOutputReceived(canLogin: true, whenChangePIN: "", to: pin, cardNumberRemains: cardNumber)
    assertOutputReceived(canLogin: false, whenChangePIN: pin, to: "", cardNumberRemains: cardNumber)
  }
  
  func testLoginWithNoToken() {
    setIdentity()
    output.reset()
    
    interactor.logIn()
    
    assertOutputReceived(identity: nil,
                         canLogin: nil)
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         errors: nil)
    assertServiceReceived(Data.validRetailIdentity)
  }
  
  func testLoginWithToken() {
    storage.tokenSpy = Data.validToken
    setIdentity()
    output.reset()
    
    interactor.logIn()
    
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         errors: nil)
    assertServiceReceived(Data.retailIdentityWithToken)
  }
  
  func testHandleLoginSuccessAndRemember() {
    login()
    output.reset()
    
    interactor.loginDidSucceed(withSession: session)
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: true,
                         errors: nil)
    assertStorageSaved(identity: idOnlyIdentity,
                       session: session)
  }
  
  func testHandleLoginSuccessAndNotRemember() {
    shouldRemember = false
    login()
    output.reset()
    
    interactor.loginDidSucceed(withSession: session)
    
    assertStorageSaved(identity: nil,
                       session: session)
  }
  
  func testHandleLoginFailure() {
    login()
    output.reset()
    
    interactor.loginDidFail(dueTo: [Data.error])
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: false,
                         errors: [Data.errorMessage])
    assertStorageSaved(identity: nil,
                       session: nil)
  }
  
  func testHandleLoginFailureCausedByInvalidToken() {
    login()
    output.reset()
    
    interactor.changeMemebershipNumber(to: Data.membershipNumber)
    interactor.loginDidFailDueToInvalidToken()
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: false,
                         errors: nil)
    assertOutputGoesToVerification(with: Data.retailIdentityWithMembershipNumber)
    assertStorageSaved(identity: idOnlyIdentity,
                       session: nil)
  }
  
  func testHelpWithCardNumber() {
    interactor.helpWithIdentifier()
    
    assertHelp(is: .cardNumber)
  }
  
  func testHelpWithPIN() {
    interactor.helpWithCredential()
    
    assertHelp(is: .pin)
  }
  
  // MARK: helpers
  
  private func setIdentity(_ identity: RetailIdentity = Data.validRetailIdentity) {
    interactor.load()
    interactor.changeIdentifier(to: identity.identifier)
    interactor.changeCredential(to: identity.credential)
  }
  
  private func login() {
    setIdentity()
    interactor.changeShouldRememberIdentity(to: shouldRemember)
    interactor.logIn()
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    whenChangeCardNumber oldCardNumber: String,
                                    to newCardNumber: String,
                                    pinRemains pin: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    setIdentity(RetailIdentity(identifier: oldCardNumber, credential: pin))
    output.reset()
    
    interactor.changeIdentifier(to: newCardNumber)
    
    assertOutputReceived(identity: nil, canLogin: canLogin, file: file, line: line)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    whenChangePIN oldPIN: String,
                                    to newPIN: String,
                                    cardNumberRemains cardNumber: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    setIdentity(RetailIdentity(identifier: cardNumber, credential: oldPIN))
    output.reset()
    
    interactor.changeCredential(to: newPIN)
    
    assertOutputReceived(identity: nil, canLogin: canLogin, file: file, line: line)
  }
  
  private func assertOutputReceived(identity: RetailIdentity?,
                                    canLogin: Bool?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.identitySpy, identity, "identity", file: file, line: line)
    XCTAssertEqual(output.canLoginSpy, canLogin, "canLogin", file: file, line: line)
  }
  
  private func assertOutputReceived(loginDidBegin: Bool?,
                                    loginDidEnd: Bool?,
                                    errors: [String]?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.loginDidBeginSpy, loginDidBegin, "loginDidBegin", file: file, line: line)
    XCTAssertEqual(output.loginDidEndSpy, loginDidEnd, "loginDidEnd", file: file, line: line)
    XCTAssertEqual(output.errorsSpy, errors, "errors", file: file, line: line)
  }
  
  private func assertOutputGoesToVerification(with identity: RetailIdentity) {
    XCTAssertEqual(output.verificationIdentitySpy, identity)
  }
  
  private func assertServiceReceived(_ identity: RetailIdentity?,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertEqual(service.identitySpy, identity, "identity", file: file, line: line)
  }
  
  private func assertStorageSaved(identity: RetailIdentity?,
                                  session: String?,
                                  file: StaticString = #file,
                                  line: UInt = #line) {
    XCTAssertEqual(storage.identitySpy, identity, "identity", file: file, line: line)
    XCTAssertEqual(storage.sessionSpy, session, "session", file: file, line: line)
  }
  
  private func assertHelp(is help: LoginHelp,
                          file: StaticString = #file,
                          line: UInt = #line) {
    XCTAssertEqual(output.helpSpy, help, "", file: file, line: line)
  }
}

class RetailLoginInteractorOutputSpy: RetailLoginInteractorOutput {
  var identitySpy: RetailIdentity?
  var canLoginSpy: Bool?
  var loginDidBeginSpy = false
  var loginDidEndSpy = false
  var errorsSpy: [String]?
  var helpSpy: LoginHelp?
  var verificationIdentitySpy: RetailIdentity?
  var identityCreationIdentitySpy: RetailIdentity?
  
  func reset() {
    identitySpy = nil
    canLoginSpy = nil
    loginDidBeginSpy = false
    loginDidEndSpy = false
    errorsSpy = nil
    helpSpy = nil
    verificationIdentitySpy = nil
  }
  
  func didLoad(identity: RetailIdentity, canLogin: Bool) {
    identitySpy = identity
    canLoginSpy = canLogin
  }
  
  func canLoginDidChange(to canLogin: Bool) {
    canLoginSpy = canLogin
  }
  
  func loginDidBegin() {
    loginDidBeginSpy = true
  }
  
  func loginDidEnd() {
    loginDidEndSpy = true
  }
  
  func loginDidFail(withErrors errors: [String]) {
    errorsSpy = errors
  }
  
  func showHelp(_ help: LoginHelp) {
    helpSpy = help
  }
  
  func showVerification(withIdentity identity: RetailIdentity) {
    verificationIdentitySpy = identity
  }
  
  func showIdentityCreation(withIdentity identity: RetailIdentity) {
    identityCreationIdentitySpy = identity
  }
}

class RetailLoginServiceSpy: RetailLoginServiceInput {
  var identitySpy: RetailIdentity?
  
  func logIn(withRetailIdentity identity: RetailIdentity) {
    identitySpy = identity
  }
}

class RetailLoginStorageSpy: RetailLoginStorage {
  var identitySpy: RetailIdentity?
  var tokenSpy: String?
  var sessionSpy: String?
  
  func saveIdentity(_ identity: RetailIdentity) {
    identitySpy = identity
  }
  
  func loadIdentity() -> RetailIdentity? {
    return identitySpy
  }
  
  func saveToken(_ token: String) {
    tokenSpy = token
  }
  
  func loadToken() -> String? {
    return tokenSpy
  }
  
  func saveSession(_ session: String) {
    sessionSpy = session
  }
}
