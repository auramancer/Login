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
  private let validPIN = "888888"
  private let validToken = "1QAZ2WSX"
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
  
  func testLoad() {
    interactor.load()
    
    assertOutputReceived(canLogin: false,  mode: .undetermined)
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
    
    interactor.changeIdentifier(to: validUsername)
    
    assertOutputReceived(canLogin: false,
                         mode: .digital)
  }
  
  func testChangeCredential() {
    interactor.load()
    
    interactor.changeCredential(to: validPassword)
    
    assertOutputReceived(canLogin: false,
                         mode: nil)
  }
  
  func testLoginWithUsername() {
    set(identifier: validUsername, credential: validPassword)
    output.reset()
    
    interactor.logIn(shouldRememberIdentifier: true)
    
    assertOutputReceived(canLogin: false,
                         loginDidBegin: true,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(digitalRequest: DigitalLoginRequest(username: validUsername, password: validPassword),
                          retailRequest: nil)
  }
  
  func testLoginWithCardNumber() {
    set(identifier: validCardNumber, credential: validPIN)
    output.reset()
    
    interactor.logIn(shouldRememberIdentifier: true)
    
    assertOutputReceived(canLogin: false,
                         loginDidBegin: true,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(digitalRequest: nil,
                          retailRequest: RetailLoginRequest(cardNumber: validCardNumber, pin: validPIN))
  }
  
  func testHandleLoginSuccessInDigitalMode() {
    login(identifier: validUsername, credential: validPassword)
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertOutputReceived(canLogin: nil,
                         loginDidBegin: false,
                         loginDidEnd: true,
                         loginErrors: nil)
    assertStorageSaved(username: validUsername, cardNumber: nil)
  }
  
  func testHandleLoginSuccessInRetailMode() {
    login(identifier: validCardNumber, credential: validPIN)
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertOutputReceived(canLogin: nil,
                         loginDidBegin: false,
                         loginDidEnd: true,
                         loginErrors: nil)
    assertStorageSaved(username: nil, cardNumber: validCardNumber)
  }
  
  func testHandleLoginFailureInDigitalMode() {
    login(identifier: validUsername, credential: validPassword)
    output.reset()
    
    interactor.loginDidFail(dueTo: [error])
    
    assertOutputReceived(canLogin: true,
                         loginDidBegin: false,
                         loginDidEnd: false,
                         loginErrors: ["Cannot log in."])
    assertStorageSaved(username: nil, cardNumber: nil)
  }
  
  func testHandleLoginFailureInRetailMode() {
    login(identifier: validCardNumber, credential: validPIN)
    output.reset()
    
    interactor.loginDidFail(dueTo: [error])
    
    assertOutputReceived(canLogin: true,
                         loginDidBegin: false,
                         loginDidEnd: false,
                         loginErrors: ["Cannot log in."])
    assertStorageSaved(username: nil, cardNumber: nil)
  }
  
  func testHandleInvalidToken() {
    login(identifier: validCardNumber, credential: validPIN)
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
  
  private func assertOutputReceived(canLogin: Bool?,
                                    mode: LoginMode?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.canLoginSpy, canLogin, "", file: file, line: line)
    XCTAssertEqual(output.modeSpy, mode, "", file: file, line: line)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    loginDidBegin: Bool?,
                                    loginDidEnd: Bool?,
                                    loginErrors: [String]?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.canLoginSpy, canLogin, "", file: file, line: line)
    XCTAssertEqual(output.loginDidBeginSpy, loginDidBegin, "", file: file, line: line)
    XCTAssertEqual(output.loginDidEndSpy, loginDidEnd, "", file: file, line: line)
    XCTAssertEqual(output.loginErrorsSpy, loginErrors, "", file: file, line: line)
  }
  
  private func assertOutputReceived(mode: LoginMode?,
                                    whenChangeIdentifier old: String,
                                    to new: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    set(identifier: old, credential: "")
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
  var loginDidBeginSpy = false
  var loginDidEndSpy = false
  var loginErrorsSpy: [String]?
  var helpSpy: LoginHelp?
  var verificationRequestSpy: RetailLoginRequest?
  
  func reset() {
    identifierSpy = nil
    credentialSpy = nil
    canLoginSpy = nil
    modeSpy = nil
    loginDidBeginSpy = false
    loginDidEndSpy = false
    loginErrorsSpy = nil
    helpSpy = nil
    verificationRequestSpy = nil
  }
  
  func didLoad(withIdentifier identifier: String, credential: String) {
    identifierSpy = identifier
    credentialSpy = credential
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
