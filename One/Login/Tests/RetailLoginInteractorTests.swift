import XCTest

class RetailLoginInteractorTests: XCTestCase {
  private var interactor: RetailLoginInteractor!
  private var output: RetailLoginInteractorOutputSpy!
  private var service: RetailLoginServiceSpy!
  private var storage: RetailLoginStorageSpy!
  
  private let validCardNumber = "1234567890"
  private let validPIN = "8888"
  private let validToken = "1QAZ2WSX"
  private let error = "Cannot log in."
  private let session = "12345QWERT"
  private let membershipNumber = "9876543210"
  private var shouldRemember = true
  
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
    
    assertOutputReceived(identity: RetailIdentity(cardNumber: "", pin: ""),
                         canLogin: false)
  }
  
  func testLoadWithRememberedCardNumber() {
    let identity = RetailIdentity(cardNumber: validCardNumber, pin: "")
    storage.identitySpy = identity
    
    interactor.load()
    
    assertOutputReceived(identity: identity,
                         canLogin: false)
  }
  
  func testChangeCardNumber() {
    assertOutputReceived(canLogin: nil, whenChangeCardNumber: "", to: validCardNumber, pinRemains: "")
    assertOutputReceived(canLogin: true, whenChangeCardNumber: "", to: validCardNumber, pinRemains: validPIN)
    assertOutputReceived(canLogin: false, whenChangeCardNumber: validCardNumber, to: "", pinRemains: validPIN)
  }
  
  func testChangePIN() {
    assertOutputReceived(canLogin: nil, whenChangePIN: "", to: validPIN, cardNumberRemains: "")
    assertOutputReceived(canLogin: true, whenChangePIN: "", to: validPIN, cardNumberRemains: validCardNumber)
    assertOutputReceived(canLogin: false, whenChangePIN: validPIN, to: "", cardNumberRemains: validCardNumber)
  }
  
  func testLoginWithNoToken() {
    set(cardNumber: validCardNumber, pin: validPIN)
    output.reset()
    
    interactor.logIn()
    
    assertOutputReceived(identity: nil,
                         canLogin: nil)
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         errors: nil)
    assertServiceReceived(RetailIdentity(cardNumber: validCardNumber,
                                             pin: validPIN))
  }
  
  func testLoginWithToken() {
    storage.tokenSpy = validToken
    set(cardNumber: validCardNumber, pin: validPIN)
    output.reset()
    
    interactor.logIn()
    
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         errors: nil)
    assertServiceReceived(RetailIdentity(cardNumber: validCardNumber,
                                         pin: validPIN,
                                         authenticationToken: validToken))
  }
  
  func testHandleLoginSuccessAndRemember() {
    login()
    output.reset()
    
    interactor.loginDidSucceed(withSession: session, needToCreateDigitalIdentity: false)
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: true,
                         errors: nil)
    assertStorageSaved(identity: RetailIdentity(cardNumber: validCardNumber, pin: ""),
                       session: session)
  }
  
  func testHandleLoginSuccessAndNotRemember() {
    shouldRemember = false
    login()
    output.reset()
    
    interactor.loginDidSucceed(withSession: session, needToCreateDigitalIdentity: false)
    
    assertStorageSaved(identity: nil,
                       session: session)
  }
  
  func testHandleLoginSuccessAndCreateIdentity() {
    login()
    output.reset()
    
    interactor.loginDidSucceed(withSession: session, needToCreateDigitalIdentity: true)
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: false,
                         errors: nil)
    assertStorageSaved(identity: RetailIdentity(cardNumber: validCardNumber, pin: ""),
                       session: session)
    XCTAssertEqual(output.identityCreationIdentitySpy, RetailIdentity(cardNumber: validCardNumber,
                                                                      pin: validPIN,
                                                                      membershipNumber: membershipNumber))
  }
  
  func testHandleLoginFailure() {
    login()
    output.reset()
    
    interactor.loginDidFail(dueTo: [SimpleError(error)])
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: false,
                         errors: [error])
    assertStorageSaved(identity: nil,
                       session: nil)
  }
  
  func testHandleLoginFailureCausedByInvalidToken() {
    login()
    output.reset()
    
    interactor.changeMemebershipNumber(to: membershipNumber)
    interactor.loginDidFailDueToInvalidToken()
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: false,
                         errors: nil)
    assertStorageSaved(identity: RetailIdentity(cardNumber: validCardNumber, pin: ""),
                       session: nil)
    XCTAssertEqual(output.verificationIdentitySpy, RetailIdentity(cardNumber: validCardNumber,
                                                                  pin: validPIN,
                                                                  membershipNumber: membershipNumber))
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
  
  private func set(cardNumber: String, pin: String) {
    interactor.load()
    interactor.changeIdentifier(to: cardNumber)
    interactor.changeCredential(to: pin)
  }
  
  private func login() {
    set(cardNumber: validCardNumber, pin: validPIN)
    interactor.changeShouldRememberIdentity(to: shouldRemember)
    interactor.logIn()
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    whenChangeCardNumber oldCardNumber: String,
                                    to newCardNumber: String,
                                    pinRemains pin: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    set(cardNumber: oldCardNumber, pin: pin)
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
    set(cardNumber: cardNumber, pin: oldPIN)
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

extension RetailIdentity: Equatable {
  init(cardNumber: String, pin: String, membershipNumber: String) {
    self.init(cardNumber: cardNumber,
              pin: pin,
              verificationCode: nil,
              authenticationToken: nil,
              membershipNumber: nil)
  }
  
  static func ==(lhs: RetailIdentity, rhs: RetailIdentity) -> Bool {
    return lhs.cardNumber == rhs.cardNumber &&
      lhs.pin == rhs.pin &&
      lhs.authenticationToken == rhs.authenticationToken &&
      lhs.verificationCode == rhs.verificationCode
  }
}
