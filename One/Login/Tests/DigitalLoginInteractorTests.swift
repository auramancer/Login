import XCTest

class DigitalLoginInteractorTests: XCTestCase {
  private var interactor: DigitalLoginInteractor!
  private var output: DigitalLoginInteractorOutputSpy!
  private var service: DigitalLoginServiceSpy!
  private var storage: DigitalLoginStorageSpy!
  
  private let validUsername = "username"
  private let validPassword = "password"
  private let error = "Cannot log in."
  private let session = "12345QWERT"
  private var shouldRemember = true
  private var validIdentity: DigitalIdentity {
    return DigitalIdentity(identifier: validUsername, credential: validPassword)
  }
  
  override func setUp() {
    super.setUp()
    
    output = DigitalLoginInteractorOutputSpy()
    service = DigitalLoginServiceSpy()
    storage = DigitalLoginStorageSpy()
    
    interactor = DigitalLoginInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
    
    shouldRemember = true
  }
  
  func testLoadWithNoRememberedUsername() {
    interactor.load()
    
    assertOutputReceived(identity: DigitalIdentity(identifier: "", credential: ""),
                         canLogin: false)
  }
  
  func testLoadWithRememberedUsername() {
    let identity = DigitalIdentity(identifier: validUsername, credential: "")
    storage.identitySpy = identity
    
    interactor.load()
    
    assertOutputReceived(identity: identity,
                         canLogin: false)
  }
  
  func testChangeUsername() {
    assertOutputReceived(canLogin: nil, whenChangeUsername: "", to: validUsername, passwordRemains: "")
    assertOutputReceived(canLogin: true, whenChangeUsername: "", to: validUsername, passwordRemains: validPassword)
    assertOutputReceived(canLogin: false, whenChangeUsername: validUsername, to: "", passwordRemains: validPassword)
  }
  
  func testChangePassword() {
    assertOutputReceived(canLogin: nil, whenChangePassword: "", to: validPassword, identityRemains: "")
    assertOutputReceived(canLogin: true, whenChangePassword: "", to: validPassword, identityRemains: validUsername)
    assertOutputReceived(canLogin: false, whenChangePassword: validPassword, to: "", identityRemains: validUsername)
  }
  
  func testLogin() {
    set(identity: validUsername, password: validPassword)
    output.reset()
    
    interactor.logIn()
    
    assertOutputReceived(identity: nil,
                         canLogin: nil)
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         errors: nil)
    assertServiceReceived(validIdentity)
  }
  
  func testHandleLoginSuccessAndRemember() {
    login()
    output.reset()
    
    interactor.loginDidSucceed(withSession: session)
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: true,
                         errors: nil)
    assertStorageSaved(identity: DigitalIdentity(identifier: validUsername, credential: ""),
                       session: session)
  }
  
  func testHandleLoginSuccessAndNotRemember() {
    login(shouldRemember: false)
    output.reset()
    
    interactor.loginDidSucceed(withSession: session)
    
    assertStorageSaved(identity: nil,
                       session: session)
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
  
  func testHelpWithUsername() {
    interactor.helpWithIdentifier()
    
    assertHelp(is: .username)
  }
  
  func testHelpWithPassword() {
    interactor.helpWithCredential()
    
    assertHelp(is: .password)
  }
  
  // MARK: helpers
  
  private func set(identity: String, password: String) {
    interactor.load()
    interactor.changeIdentifier(to: identity)
    interactor.changeCredential(to: password)
  }
  
  private func login(shouldRemember: Bool = true) {
    set(identity: validUsername, password: validPassword)
    interactor.changeShouldRememberIdentity(to: shouldRemember)
    interactor.logIn()
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    whenChangeUsername oldUsername: String,
                                    to newUsername: String,
                                    passwordRemains password: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    set(identity: oldUsername, password: password)
    output.reset()
    
    interactor.changeIdentifier(to: newUsername)
    
    assertOutputReceived(identity: nil, canLogin: canLogin, file: file, line: line)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    whenChangePassword oldPassword: String,
                                    to newPassword: String,
                                    identityRemains identity: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    set(identity: identity, password: oldPassword)
    output.reset()
    
    interactor.changeCredential(to: newPassword)
    
    assertOutputReceived(identity: nil, canLogin: canLogin, file: file, line: line)
  }
  
  private func assertOutputReceived(identity: DigitalIdentity?,
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
  
  private func assertServiceReceived(_ request: DigitalIdentity?,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertEqual(service.requestSpy, request, "request", file: file, line: line)
  }
  
  private func assertStorageSaved(identity: DigitalIdentity?,
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

public func XCTAssertEqual<T>(_ expression1: [T]?,
                              _ expression2: [T]?,
                              _ message: String = "",
                              file: StaticString = #file,
                              line: UInt = #line) where T : Equatable {
  if let e1 = expression1, let e2 = expression2 {
    XCTAssertEqual(e1, e2, message, file: file, line: line)
  }
  else {
    XCTAssertTrue(expression1 == nil && expression2 == nil)
  }
}

class DigitalLoginInteractorOutputSpy: DigitalLoginInteractorOutput {
  var identitySpy: DigitalIdentity?
  var canLoginSpy: Bool?
  var loginDidBeginSpy = false
  var loginDidEndSpy = false
  var errorsSpy: [String]?
  var helpSpy: LoginHelp?
  
  func reset() {
    identitySpy = nil
    canLoginSpy = nil
    loginDidBeginSpy = false
    loginDidEndSpy = false
    errorsSpy = nil
    helpSpy = nil
  }
  
  func didLoad(identity: DigitalIdentity, canLogin: Bool) {
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
}

class DigitalLoginServiceSpy: DigitalLoginServiceInput {
  var requestSpy: DigitalIdentity?
  
  func logIn(withDigitalIdentity request: DigitalIdentity) {
    requestSpy = request
  }
}

class DigitalLoginStorageSpy: DigitalLoginStorage {
  var identitySpy: DigitalIdentity?
  var sessionSpy: String?
  
  func saveIdentity(_ identity: DigitalIdentity) {
    identitySpy = identity
  }
  
  func loadIdentity() -> DigitalIdentity? {
    return identitySpy
  }
  
  func saveSession(_ session: String) {
    sessionSpy = session
  }
}

extension DigitalIdentity: Equatable {
  static func ==(lhs: DigitalIdentity, rhs: DigitalIdentity) -> Bool {
    return lhs.identifier == rhs.identifier &&
           lhs.credential == rhs.credential
  }
}
