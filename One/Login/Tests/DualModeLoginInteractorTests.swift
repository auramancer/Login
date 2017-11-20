import XCTest

class DualModeLoginInteractorTests: XCTestCase {
  private var interactor: DualModeLoginInteractor!
  private var output: DualModeLoginInteractorOutputSpy!
  private var service: DualModeLoginServiceSpy!
  private var storage: DualModeLoginStorageSpy!
  
  private let ambiguousIdentifier = "12345"
  private let validUsername = "username"
  private let validPassword = "password"
  private let validCardNumber = "1234567890"
  private let validPIN = "8888"
  private let validToken = "1QAZ2WSX"
  private let error = "Cannot log in."
  private let session = "123456QWERT"
  
  override func setUp() {
    super.setUp()
    
    output = DualModeLoginInteractorOutputSpy()
    service = DualModeLoginServiceSpy()
    storage = DualModeLoginStorageSpy()
    
    interactor = DualModeLoginInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
  }
  
  func testLoad() {
    interactor.load()
    
    assertOutputReceived(identifier: "",
                         credential: "",
                         canLogin: false,
                         mode: .undetermined)
  }
  
  func testLoadWithRememberedUsername() {
    storage.identifierSpy = validUsername
    
    interactor.load()
    
    assertOutputReceived(identifier: validUsername,
                         credential: "",
                         canLogin: false,
                         mode: .digital)
  }
  
  func testLoadWithRememberedCardNumber() {
    storage.identifierSpy = validCardNumber
    
    interactor.load()
    
    assertOutputReceived(identifier: validCardNumber,
                         credential: "",
                         canLogin: false,
                         mode: .retail)
  }
  
  func testSwitchMode() {
    assertOutputReceived(mode: nil, whenChangeIdentifier: ambiguousIdentifier, to: ambiguousIdentifier)
    assertOutputReceived(mode: .digital, whenChangeIdentifier: ambiguousIdentifier, to: validUsername)
    assertOutputReceived(mode: .retail, whenChangeIdentifier: ambiguousIdentifier, to: validCardNumber)
    assertOutputReceived(mode: .undetermined, whenChangeIdentifier: validUsername, to: ambiguousIdentifier)
    assertOutputReceived(mode: nil, whenChangeIdentifier: validUsername, to: validUsername)
    assertOutputReceived(mode: .retail, whenChangeIdentifier: validUsername, to: validCardNumber)
    assertOutputReceived(mode: .undetermined, whenChangeIdentifier: validCardNumber, to: ambiguousIdentifier)
    assertOutputReceived(mode: .digital, whenChangeIdentifier: validCardNumber, to: validUsername)
    assertOutputReceived(mode: nil, whenChangeIdentifier: validCardNumber, to: validCardNumber)
  }
  
  func testChangeIdentifier() {
    interactor.load()
    output.reset()
    
    interactor.changeIdentifier(to: validUsername)
    
    assertOutputReceived(identifier: nil,
                         credential: nil,
                         canLogin: nil,
                         mode: .digital)
  }
  
  func testChangeCredential() {
    interactor.load()
    output.reset()
    
    interactor.changeCredential(to: validPassword)
    
    assertOutputReceived(identifier: nil,
                         credential: nil,
                         canLogin: nil,
                         mode: nil)
  }
  
  func testLoginWithUsername() {
    set(identifier: validUsername, credential: validPassword)
    output.reset()
    
    interactor.logIn(shouldRememberIdentifier: true)
    
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         errors: nil)
    assertServiceReceived(digitalRequest: DigitalIdentity(identifier: validUsername, credential: validPassword),
                          retailRequest: nil)
  }
  
  func testLoginWithCardNumber() {
    set(identifier: validCardNumber, credential: validPIN)
    output.reset()
    
    interactor.logIn(shouldRememberIdentifier: true)
    
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         errors: nil)
    assertServiceReceived(digitalRequest: nil,
                          retailRequest: RetailIdentity(cardNumber: validCardNumber, pin: validPIN))
  }
  
  func testHandleLoginSuccessInDigitalMode() {
    login(identifier: validUsername, credential: validPassword)
    output.reset()
    
    interactor.loginDidSucceed(withSession: session)
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: true,
                         errors: nil)
    assertStorageSaved(identifier: validUsername)
  }
  
  func testHandleLoginSuccessInRetailMode() {
    login(identifier: validCardNumber, credential: validPIN)
    output.reset()
    
    interactor.loginDidSucceed(withSession: session)
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: true,
                         errors: nil)
    assertStorageSaved(identifier: validCardNumber)
  }
  
  func testHandleLoginFailureInDigitalMode() {
    login(identifier: validUsername, credential: validPassword)
    output.reset()
    
    interactor.loginDidFail(dueTo: [SimpleError(error)])
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: false,
                         errors: [error])
    assertStorageSaved(identifier: nil)
  }
  
  func testHandleLoginFailureInRetailMode() {
    login(identifier: validCardNumber, credential: validPIN)
    output.reset()
    
    interactor.loginDidFail(dueTo: [SimpleError(error)])
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: false,
                         errors: [error])
    assertStorageSaved(identifier: nil)
  }
  
  func testHandleInvalidToken() {
    login(identifier: validCardNumber, credential: validPIN)
    output.reset()
    
    interactor.loginDidFailDueToInvalidToken()
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: false,
                         errors: nil)
    XCTAssertEqual(output.verificationIdentitySpy, RetailIdentity(cardNumber: validCardNumber, pin: validPIN))
    assertStorageSaved(identifier: nil)
  }
  
  func testHelpWithIdentifierInDigitalMode() {
    set(identifier: validUsername, credential: "")
    
    interactor.helpWithIdentifier()
    
    assertHelp(is:.username)
  }
  
  func testHelpWithIdentifierInRetailMode() {
    set(identifier: validCardNumber, credential: "")
    
    interactor.helpWithIdentifier()
    
    assertHelp(is:.cardNumber)
  }
  
  func testHelpWithCredentialInDigitalMode() {
    set(identifier: validUsername, credential: "")
    
    interactor.helpWithCredential()
    
    assertHelp(is:.password)
  }
  
  func testHelpWithCredentialInRetailMode() {
    set(identifier: validCardNumber, credential: "")
    
    interactor.helpWithCredential()
    
    assertHelp(is:.pin)
  }
  
  // MARK: helpers
  
  private func set(identifier: String, credential: String) {
    interactor.load()
    interactor.changeIdentifier(to: identifier)
    interactor.changeCredential(to: credential)
  }
  
  private func login(identifier: String, credential: String, shouldRemember: Bool = true) {
    set(identifier: identifier, credential: credential)
    interactor.logIn(shouldRememberIdentifier: shouldRemember)
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
  
  private func assertStorageSaved(identifier: String?,
                                  file: StaticString = #file,
                                  line: UInt = #line) {
    XCTAssertEqual(storage.identifierSpy, identifier, "identifier", file: file, line: line)
  }
  
  private func assertHelp(is help: LoginHelp,
                          file: StaticString = #file,
                          line: UInt = #line) {
    XCTAssertEqual(output.helpSpy, help, "", file: file, line: line)
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
  
  func showVerificationForm(withRequest request: RetailIdentity) {
    verificationIdentitySpy = request
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
  var identifierSpy: String?
  var tokenSpy: String?
  var sessionSpy: String?
  
  func saveIdentifier(_ identifier: String) {
    identifierSpy = identifier
  }
  
  func loadIdentifier() -> String? {
    return identifierSpy
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
