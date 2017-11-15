import XCTest

class DualModeLoginInteractorTests: XCTestCase {
  private var interactor: DualModeLoginInteractor!
  private var output: DualModeLoginInteractorOutputSpy!
  private var service: DualModeLoginServiceSpy!
  private var storage: DualModeLoginStorageSpy!
  
  private let ambiguousIdentifier = "12345"
  private let validUsername = "name"
  private let validCardNumber = "12345678"
  private let validPassword = "1234"
  private let validPIN = "1234"
  private let error = "Cannot log in."
  
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
  
  func testInitialize() {
    interactor.initialize()
    
    assertOutputReceived(identifier: "",
                         credential: "",
                         canLogin: false,
                         mode: .undetermined)
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
    interactor.changeIdentifier(to: validUsername)
    
    assertOutputReceived(identifier: validUsername,
                         credential: nil,
                         canLogin: false,
                         mode: .digital)
  }
  
  func testChangeCredential() {
    interactor.changeCredential(to: validPassword)
    
    assertOutputReceived(identifier: nil,
                         credential: validPassword,
                         canLogin: false,
                         mode: nil)
  }
  
  func testLoginWithUsername() {
    login(withIdentifier: validUsername, credential: validPassword, shouldRemember: true)
    
    assertOutputReceived(canLogin: false,
                         loginDidBegin: true,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(digitalRequest: DigitalLoginRequest(username: validUsername, password: validPassword),
                          retailRequest: nil)
  }
  
  func testLoginWithCardNumber() {
    login(withIdentifier: validCardNumber, credential: validPIN, shouldRemember: true)
    
    assertOutputReceived(canLogin: false,
                         loginDidBegin: true,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(digitalRequest: nil,
                          retailRequest: RetailLoginRequest(cardNumber: validCardNumber, pin: validPIN))
  }
  
  func testHandleLoginSuccessInDigitalMode() {
    login(withIdentifier: validUsername, credential: validPassword, shouldRemember: true)
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertOutputReceived(canLogin: nil,
                         loginDidBegin: false,
                         loginDidEnd: true,
                         loginErrors: nil)
    assertStorageSaved(username: validUsername, cardNumber: nil)
  }
  
  func testHandleLoginSuccessInRetailMode() {
    login(withIdentifier: validCardNumber, credential: validPIN, shouldRemember: true)
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertOutputReceived(canLogin: nil,
                         loginDidBegin: false,
                         loginDidEnd: true,
                         loginErrors: nil)
    assertStorageSaved(username: nil, cardNumber: validCardNumber)
  }
  
  func testHandleLoginFailureInDigitalMode() {
    login(withIdentifier: validUsername, credential: validPassword, shouldRemember: true)
    output.reset()
    
    interactor.loginDidFail(dueTo: [error])
    
    assertOutputReceived(canLogin: true,
                         loginDidBegin: false,
                         loginDidEnd: false,
                         loginErrors: [error])
    assertStorageSaved(username: nil, cardNumber: nil)
  }
  
  func testHandleLoginFailureInRetailMode() {
    login(withIdentifier: validCardNumber, credential: validPIN, shouldRemember: true)
    output.reset()
    
    interactor.loginDidFail(dueTo: [error])
    
    assertOutputReceived(canLogin: true,
                         loginDidBegin: false,
                         loginDidEnd: false,
                         loginErrors: [error])
    assertStorageSaved(username: nil, cardNumber: nil)
  }
  
  func testHandleInvalidToken() {
    login(withIdentifier: validCardNumber, credential: validPIN, shouldRemember: true)
    output.reset()
    
    interactor.loginDidFailDueToInvalidToken()
    
    assertOutputReceived(canLogin: nil,
                         loginDidBegin: false,
                         loginDidEnd: false,
                         loginErrors: nil)
    XCTAssertEqual(output.verificationRequestSpy, RetailLoginRequest(cardNumber: validCardNumber, pin: validPIN))
    assertStorageSaved(username: nil, cardNumber: nil)
  }
  
  func testHelpWithIdentifierInDigitalMode() {
    interactor.changeIdentifier(to: validUsername)
    
    interactor.helpWithIdentifier()
    
    assertHelp(is:.username)
  }
  
  func testHelpWithIdentifierInRetailMode() {
    interactor.changeIdentifier(to: validCardNumber)
    
    interactor.helpWithIdentifier()
    
    assertHelp(is:.cardNumber)
  }
  
  func testHelpWithCredentialInDigitalMode() {
    interactor.changeIdentifier(to: validUsername)
    
    interactor.helpWithCredential()
    
    assertHelp(is:.password)
  }
  
  func testHelpWithCredentialInRetailMode() {
    interactor.changeIdentifier(to: validCardNumber)
    
    interactor.helpWithCredential()
    
    assertHelp(is:.pin)
  }
  
  // MARK: helpers
  
  private func login(withIdentifier identifier: String, credential: String, shouldRemember: Bool) {
    interactor.changeIdentifier(to: identifier)
    interactor.changeCredential(to: credential)
    output.reset()
    interactor.logIn(shouldRememberIdentifier: shouldRemember)
  }
  
  private func assertOutputReceived(identifier: String?,
                                    credential: String?,
                                    canLogin: Bool?,
                                    mode: LoginMode?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.identifierSpy, identifier, "", file: file, line: line)
    XCTAssertEqual(output.credentialSpy, credential, "", file: file, line: line)
    XCTAssertEqual(output.canLoginSpy, canLogin, "", file: file, line: line)
    XCTAssertEqual(output.modeSpy, mode, "", file: file, line: line)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    loginDidBegin: Bool?,
                                    loginDidEnd: Bool?,
                                    loginErrors: [LoginError]?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.canLoginSpy, canLogin, "", file: file, line: line)
    XCTAssertEqual(output.didBeginLoginSpy, loginDidBegin, "", file: file, line: line)
    XCTAssertEqual(output.didEndLoginSpy, loginDidEnd, "", file: file, line: line)
    XCTAssertEqual(output.loginErrorsSpy, loginErrors, "", file: file, line: line)
  }
  
  private func assertOutputReceived(mode: LoginMode?,
                                    whenChangeIdentifier old: String,
                                    to new: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    interactor.changeIdentifier(to: old)
    output.reset()
    
    interactor.changeIdentifier(to: new)
    
    XCTAssertEqual(output.modeSpy, mode, "", file: file, line: line)
  }
  
  private func assertServiceReceived(digitalRequest: DigitalLoginRequest?,
                                     retailRequest: RetailLoginRequest?,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertEqual(service.degitalRequestSpy, digitalRequest, "digitalRequest", file: file, line: line)
    XCTAssertEqual(service.retailRequestSpy, retailRequest, "retailRequest", file: file, line: line)
  }
  
  private func assertStorageSaved(username: String?,
                                  cardNumber: String?,
                                  file: StaticString = #file,
                                  line: UInt = #line) {
    XCTAssertEqual(storage.usernameSpy, username, "username", file: file, line: line)
    XCTAssertEqual(storage.cardNumberSpy, cardNumber, "cardNumber", file: file, line: line)
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
  var didBeginLoginSpy = false
  var didEndLoginSpy = false
  var loginErrorsSpy: [LoginError]?
  var helpSpy: LoginHelp?
  var verificationRequestSpy: RetailLoginRequest?
  
  func reset() {
    identifierSpy = nil
    credentialSpy = nil
    canLoginSpy = nil
    modeSpy = nil
    didBeginLoginSpy = false
    didEndLoginSpy = false
    loginErrorsSpy = nil
    helpSpy = nil
    verificationRequestSpy = nil
  }
  
  func idDidChange(to id: String) {
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
    didBeginLoginSpy = true
  }
  
  func loginDidEnd() {
    didEndLoginSpy = true
  }
  
  func loginDidFail(withErrors errors: [LoginError]) {
    loginErrorsSpy = errors
  }
  
  func showHelp(_ help: LoginHelp) {
    helpSpy = help
  }
  
  func inquireVerificationCode(forRequest request: RetailLoginRequest) {
    verificationRequestSpy = request
  }
}

class DualModeLoginServiceSpy: DualModeLoginServiceInput {
  var degitalRequestSpy: DigitalLoginRequest?
  var retailRequestSpy: RetailLoginRequest?
  
  func logIn(withUsernameRequest request: DigitalLoginRequest) {
    degitalRequestSpy = request
  }
  
  func logIn(withCardNumberRequest request: RetailLoginRequest) {
    retailRequestSpy = request
  }
}

class DualModeLoginStorageSpy: DualModeLoginStorage {
  var usernameSpy: String?
  var cardNumberSpy: String?
  var tokenSpy: String?
  
  func saveUsername(_ username: String) {
    usernameSpy = username
  }
  
  func loadUsername() -> String? {
    return usernameSpy
  }
  
  func saveCardNumber(_ cardNumber: String) {
    cardNumberSpy = cardNumber
  }
  
  func loadCardNumber() -> String? {
    return cardNumberSpy
  }
  
  func saveToken(_ token: String) {
    tokenSpy = token
  }
  
  func loadToken() -> String? {
    return tokenSpy
  }
  
  func removeToken() {
    tokenSpy = nil
  }
}

extension DigitalLoginRequest: Equatable {
  static func ==(lhs: DigitalLoginRequest, rhs: DigitalLoginRequest) -> Bool {
    return lhs.username == rhs.username &&
      lhs.password == rhs.password
  }
}

extension RetailLoginRequest: Equatable {
  static func ==(lhs: RetailLoginRequest, rhs: RetailLoginRequest) -> Bool {
    return lhs.cardNumber == rhs.cardNumber &&
      lhs.pin == rhs.pin &&
      lhs.authenticationToken == rhs.authenticationToken &&
      lhs.verificationCode == rhs.verificationCode
  }
}
