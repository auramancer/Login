import XCTest

class DualModeLoginInteractorTests: XCTestCase {
  private var interactor: DualModeLoginInteractor!
  private var output: DualModeLoginInteractorOutputSpy!
  private var service: DualModeLoginServiceSpy!
  private var storage: DualModeLoginStorageSpy!
  
  private var shouldRemember = true
  
  typealias Data = LoginTestData
  private let username = Data.validUsername
  private let password = Data.validPassword
  private let cardNumber = Data.validCardNumber
  private let pin = Data.validPIN
  private let digitalIdentity = Data.validDigitalIdentity
  private let digitalIdentityIdOnly = Data.digitalIdentityIdOnly
  private let retailIdentity = Data.validRetailIdentity
  private let retailIdentityIdOnly = Data.retailIdentityIdOnly
  private let session = Data.session
  private let ambiguousId = Data.ambiguousIdentifier
  private let error = Data.error
  private let errorMessage = Data.errorMessage
  
  override func setUp() {
    super.setUp()
    
    output = DualModeLoginInteractorOutputSpy()
    service = DualModeLoginServiceSpy()
    storage = DualModeLoginStorageSpy()
    
    interactor = DualModeLoginInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
    
    shouldRemember = true
  }
  
  func testLoad() {
    interactor.load()
    
    assertOutputReceived(identifier: "",
                         credential: "",
                         canLogin: false,
                         mode: .undetermined)
  }
  
  func testLoadWithRememberedUsername() {
    storage.identitySpy = digitalIdentityIdOnly
    
    interactor.load()
    
    assertOutputReceived(identifier: username,
                         credential: "",
                         canLogin: false,
                         mode: .digital)
  }
  
  func testLoadWithRememberedCardNumber() {
    storage.identitySpy = retailIdentityIdOnly
    
    interactor.load()
    
    assertOutputReceived(identifier: cardNumber,
                         credential: "",
                         canLogin: false,
                         mode: .retail)
  }
  
  func testSwitchMode() {
    assertOutputReceived(mode: nil, whenChangeIdentifier: ambiguousId, to: ambiguousId)
    assertOutputReceived(mode: .digital, whenChangeIdentifier: ambiguousId, to: username)
    assertOutputReceived(mode: .retail, whenChangeIdentifier: ambiguousId, to: cardNumber)
    assertOutputReceived(mode: .undetermined, whenChangeIdentifier: username, to: ambiguousId)
    assertOutputReceived(mode: nil, whenChangeIdentifier: username, to: username)
    assertOutputReceived(mode: .retail, whenChangeIdentifier: username, to: cardNumber)
    assertOutputReceived(mode: .undetermined, whenChangeIdentifier: cardNumber, to: ambiguousId)
    assertOutputReceived(mode: .digital, whenChangeIdentifier: cardNumber, to: username)
    assertOutputReceived(mode: nil, whenChangeIdentifier: cardNumber, to: cardNumber)
  }
  
  func testChangeIdentifier() {
    interactor.load()
    output.reset()
    
    interactor.changeIdentifier(to: username)
    
    assertOutputReceived(identifier: nil,
                         credential: nil,
                         canLogin: nil,
                         mode: .digital)
  }
  
  func testChangeCredential() {
    interactor.load()
    output.reset()
    
    interactor.changeCredential(to: password)
    
    assertOutputReceived(identifier: nil,
                         credential: nil,
                         canLogin: nil,
                         mode: nil)
  }
  
  func testLoginWithUsername() {
    set(identifier: username, credential: password)
    output.reset()
    
    interactor.logIn()
    
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         errors: nil)
    assertServiceReceived(digitalRequest: digitalIdentity,
                          retailRequest: nil)
  }
  
  func testLoginWithCardNumber() {
    set(identifier: cardNumber, credential: pin)
    output.reset()
    
    interactor.logIn()
    
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         errors: nil)
    assertServiceReceived(digitalRequest: nil,
                          retailRequest: retailIdentity)
  }
  
  func testHandleLoginSuccessInDigitalMode() {
    login(identifier: username, credential: password)
    output.reset()
    
    interactor.loginDidSucceed(withSession: session)
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: true,
                         errors: nil)
    assertStorageSaved(identity: digitalIdentityIdOnly,
                       session: session,
                       token: nil)
  }
  
  func testHandleLoginSuccessInRetailMode() {
    login(identifier: cardNumber, credential: pin)
    output.reset()
    
    interactor.loginDidSucceed(withSession: session)
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: true,
                         errors: nil)
    assertStorageSaved(identity: retailIdentityIdOnly,
                       session: session,
                       token: nil)
  }

  func testHandleLoginFailureInDigitalMode() {
    login(identifier: username, credential: password)
    output.reset()
    
    interactor.loginDidFail(dueTo: [error])
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: false,
                         errors: [errorMessage])
    assertStorageSaved(identity: nil,
                       session: nil,
                       token: nil)
  }
  
  func testHandleLoginFailureInRetailMode() {
    login(identifier: cardNumber, credential: pin)
    output.reset()
    
    interactor.loginDidFail(dueTo: [error])
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: false,
                         errors: [errorMessage])
    assertStorageSaved(identity: nil,
                       session: nil,
                       token: nil)
  }
  
  func testHandleInvalidToken() {
    login(identifier: cardNumber, credential: pin)
    output.reset()
    
    interactor.changeMemebershipNumber(to: Data.membershipNumber)
    interactor.loginDidFailDueToInvalidToken()
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: false,
                         errors: nil)
    assertOutputGoesToVerification(with: Data.retailIdentityWithMembershipNumber)
    assertStorageSaved(identity: retailIdentityIdOnly,
                       session: nil,
                       token: nil)
  }
  
  func testHelpWithIdentifierInDigitalMode() {
    set(identifier: username, credential: "")
    
    interactor.helpWithIdentifier()
    
    assertHelp(is:.username)
  }
  
  func testHelpWithIdentifierInRetailMode() {
    set(identifier: cardNumber, credential: "")
    
    interactor.helpWithIdentifier()
    
    assertHelp(is:.cardNumber)
  }
  
  func testHelpWithCredentialInDigitalMode() {
    set(identifier: username, credential: "")
    
    interactor.helpWithCredential()
    
    assertHelp(is:.password)
  }
  
  func testHelpWithCredentialInRetailMode() {
    set(identifier: cardNumber, credential: "")
    
    interactor.helpWithCredential()
    
    assertHelp(is:.pin)
  }
  
  // MARK: helpers
  
  private func set(identifier: String, credential: String) {
    interactor.load()
    interactor.changeIdentifier(to: identifier)
    interactor.changeCredential(to: credential)
  }
  
  private func login(identifier: String, credential: String) {
    set(identifier: identifier, credential: credential)
    interactor.changeShouldRememberIdentity(to: shouldRemember)
    interactor.logIn()
  }
  
  private func assertOutputReceived(identifier: String?,
                                    credential: String?,
                                    canLogin: Bool?,
                                    mode: LoginMode?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.identifierSpy, identifier, "identifier", file: file, line: line)
    XCTAssertEqual(output.credentialSpy, credential, "credential", file: file, line: line)
    XCTAssertEqual(output.canLoginSpy, canLogin, "canLogin", file: file, line: line)
    XCTAssertEqual(output.modeSpy, mode, "mode", file: file, line: line)
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
  
  private func assertOutputReceived(mode: LoginMode?,
                                    whenChangeIdentifier old: String,
                                    to new: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    set(identifier: old, credential: "")
    output.reset()
    
    interactor.changeIdentifier(to: new)
    
    XCTAssertEqual(output.modeSpy, mode, "mode", file: file, line: line)
  }
  
  private func assertServiceReceived(digitalRequest: DigitalIdentity?,
                                     retailRequest: RetailIdentity?,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertEqual(service.degitalIdentitySpy, digitalRequest, "digitalRequest", file: file, line: line)
    XCTAssertEqual(service.retailIdentitySpy, retailRequest, "retailRequest", file: file, line: line)
  }
  
  private func assertStorageSaved(identity: Identity?,
                                  session: String?,
                                  token: String?,
                                  file: StaticString = #file,
                                  line: UInt = #line) {
    XCTAssertEqual(storage.identitySpy?.identifier, identity?.identifier, "identifier", file: file, line: line)
    XCTAssertEqual(storage.identitySpy?.credential, identity?.credential, "credential", file: file, line: line)
    XCTAssertEqual(storage.sessionSpy, session, "session", file: file, line: line)
    XCTAssertEqual(storage.tokenSpy, token, "token", file: file, line: line)
  }
  
  private func assertHelp(is help: LoginHelp,
                          file: StaticString = #file,
                          line: UInt = #line) {
    XCTAssertEqual(output.helpSpy, help, "", file: file, line: line)
  }
  
  private func assertOutputGoesToVerification(with identity: RetailIdentity) {
    XCTAssertEqual(output.verificationIdentitySpy, identity)
  }
}

class DualModeLoginInteractorOutputSpy: DualModeLoginInteractorOutput {
  
  var identifierSpy: String?
  var credentialSpy: String?
  var canLoginSpy: Bool?
  var modeSpy: LoginMode?
  var loginDidBeginSpy = false
  var loginDidEndSpy = false
  var errorsSpy: [String]?
  var helpSpy: LoginHelp?
  var verificationIdentitySpy: RetailIdentity?
  var identityCreationIdentitySpy: RetailIdentity?
  
  func reset() {
    identifierSpy = nil
    credentialSpy = nil
    canLoginSpy = nil
    modeSpy = nil
    loginDidBeginSpy = false
    loginDidEndSpy = false
    errorsSpy = nil
    helpSpy = nil
    verificationIdentitySpy = nil
    identityCreationIdentitySpy = nil
  }
  
  func didLoad(identifier: String, credential: String, canLogin: Bool, mode: LoginMode) {
    identifierSpy = identifier
    credentialSpy = credential
    canLoginSpy = canLogin
    modeSpy = mode
  }
  
  func identifierDidChange(to id: String) {
    identifierSpy = id
  }
  
  func credentialDidChange(to credential: String) {
    credentialSpy = credential
  }
  
  func canLoginDidChange(to canLogin: Bool) {
    canLoginSpy = canLogin
  }
  
  func loginModeDidChange(to mode: LoginMode) {
    modeSpy = mode
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

class DualModeLoginServiceSpy: DualModeLoginServiceInput {
  var degitalIdentitySpy: DigitalIdentity?
  var retailIdentitySpy: RetailIdentity?
  
  func logIn(withDigitalIdentity identity: DigitalIdentity) {
    degitalIdentitySpy = identity
  }
  
  func logIn(withRetailIdentity identity: RetailIdentity) {
    retailIdentitySpy = identity
  }
}

class DualModeLoginStorageSpy: DualModeLoginStorage {
  var identitySpy: Identity?
  var tokenSpy: String?
  var sessionSpy: String?
  
  func saveIdentity(_ identity: Identity) {
    identitySpy = identity
  }
  
  func loadIdentity() -> Identity? {
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
