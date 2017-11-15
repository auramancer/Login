import XCTest

class DigitalLoginInteractorTests: XCTestCase {
  private var interactor: DigitalLoginInteractor!
  private var output: DigitalLoginInteractorOutputSpy!
  private var service: DigitalLoginServiceSpy!
  private var storage: DigitalLoginStorageSpy!
  
  private let validUsername = "name"
  private let validPassword = "pass"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = DigitalLoginInteractorOutputSpy()
    service = DigitalLoginServiceSpy()
    storage = DigitalLoginStorageSpy()
    
    interactor = DigitalLoginInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
  }
  
  func testInitializeWithNoRememberedUsername() {
    interactor.initialize()
    
    assertOutputReceived(username: "",
                         password: "",
                         canLogin: false)
  }
  
  func testInitializeWithRememberedUsername() {
    storage.usernameSpy = validUsername
    
    interactor.initialize()
    
    assertOutputReceived(username: validUsername,
                         password: "",
                         canLogin: false)
  }
  
  func testChangeUsername() {
    assertOutputReceived(username: validUsername, canLogin: false, whenChangeUsername: "", to: validUsername, passwordRemains: "")
    assertOutputReceived(username: validUsername, canLogin: true, whenChangeUsername: "", to: validUsername, passwordRemains: validPassword)
    assertOutputReceived(username: nil, canLogin: nil, whenChangeUsername: validUsername, to: validUsername, passwordRemains: "")
    assertOutputReceived(username: "", canLogin: false, whenChangeUsername: validUsername, to: "", passwordRemains: "")
  }
  
  func testChangePassword() {
    assertOutputReceived(password: validPassword, canLogin: false, whenChangePassword: "", to: validPassword, usernameRemains: "")
    assertOutputReceived(password: validPassword, canLogin: true, whenChangePassword: "", to: validPassword, usernameRemains: validUsername)
    assertOutputReceived(password: nil, canLogin: nil, whenChangePassword: validPassword, to: validPassword, usernameRemains: "")
    assertOutputReceived(password: "", canLogin: false, whenChangePassword: validPassword, to: "", usernameRemains: "")
  }
  
  func testLogInWhenRequestNotValid() {
    login(withUsername: "", password: "", shouldRemember: true)
    
    assertOutputReceived(canLogin: nil,
                         loginDidBegin: false,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(nil)
  }
  
  func testLogin() {
    login(withUsername: validUsername, password: validPassword, shouldRemember: true)
    
    assertOutputReceived(canLogin: false,
                         loginDidBegin: true,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(DigitalLoginRequest(username: validUsername, password: validPassword))
  }
  
  func testHandleLoginSuccessAndRemember() {
    login(withUsername: validUsername, password: validPassword, shouldRemember: true)
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertOutputReceived(canLogin: nil,
                         loginDidBegin: false,
                         loginDidEnd: true,
                         loginErrors: nil)
    assertStorageSaved(validUsername)
  }
  
  func testHandleLoginSuccessAndNotRemember() {
    login(withUsername: validUsername, password: validPassword, shouldRemember: false)
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertStorageSaved(nil)
  }
  
  func testHandleLoginFailure() {
    login(withUsername: validUsername, password: validPassword, shouldRemember: true)
    output.reset()
    
    interactor.loginDidFail(dueTo: [error])
    
    assertOutputReceived(canLogin: true,
                         loginDidBegin: false,
                         loginDidEnd: false,
                         loginErrors: [error])
    assertStorageSaved(nil)
  }
  
  func testHelpWithUsername() {
    interactor.helpWithUsername()
    
    assertHelp(is: .username)
  }
  
  func testHelpWithPassword() {
    interactor.helpWithPassword()
    
    assertHelp(is: .password)
  }
  
  // MARK: helpers
  
  private func login(withUsername username: String, password: String, shouldRemember: Bool) {
    interactor.changeUsername(to: username)
    interactor.changePassword(to: password)
    output.reset()
    interactor.logIn(shouldRememberUsername: shouldRemember)
  }
  
  private func assertOutputReceived(username: String?,
                                    canLogin: Bool?,
                                    whenChangeUsername oldUsername: String,
                                    to newUsername: String,
                                    passwordRemains password: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    interactor.changeUsername(to: oldUsername)
    interactor.changePassword(to: password)
    output.reset()
    
    interactor.changeUsername(to: newUsername)
    
    assertOutputReceived(username: username, password: nil, canLogin: canLogin)
  }
  
  private func assertOutputReceived(password: String?,
                                    canLogin: Bool?,
                                    whenChangePassword oldPassword: String,
                                    to newPassword: String,
                                    usernameRemains username: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    interactor.changeUsername(to: username)
    interactor.changePassword(to: oldPassword)
    output.reset()
    
    interactor.changePassword(to: newPassword)
    
    assertOutputReceived(username: nil, password: password, canLogin: canLogin)
  }
  
  private func assertOutputReceived(username: String?,
                                    password: String?,
                                    canLogin: Bool?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.usernameSpy, username, "username", file: file, line: line)
    XCTAssertEqual(output.passwordSpy, password, "password", file: file, line: line)
    XCTAssertEqual(output.canLoginSpy, canLogin, "canLogin", file: file, line: line)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    loginDidBegin: Bool?,
                                    loginDidEnd: Bool?,
                                    loginErrors: [LoginError]?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.canLoginSpy, canLogin, "canLogin", file: file, line: line)
    XCTAssertEqual(output.didBeginLoginSpy, loginDidBegin, "loginDidBegin", file: file, line: line)
    XCTAssertEqual(output.didEndLoginSpy, loginDidEnd, "loginDidEnd", file: file, line: line)
    XCTAssertEqual(output.loginErrorsSpy, loginErrors, "loginErrors", file: file, line: line)
  }
  
  private func assertServiceReceived(_ request: DigitalLoginRequest?,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertEqual(service.requestSpy, request, "request", file: file, line: line)
  }
  
  private func assertStorageSaved(_ username: String?,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertEqual(storage.usernameSpy, username, "username", file: file, line: line)
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
  var usernameSpy: String?
  var passwordSpy: String?
  var canLoginSpy: Bool?
  var didBeginLoginSpy = false
  var didEndLoginSpy = false
  var loginErrorsSpy: [LoginError]?
  var helpSpy: LoginHelp?
  
  func reset() {
    usernameSpy = nil
    passwordSpy = nil
    canLoginSpy = nil
    didBeginLoginSpy = false
    didEndLoginSpy = false
    loginErrorsSpy = nil
    helpSpy = nil
  }
  
  func usernameDidChange(to username: String) {
    usernameSpy = username
  }
  
  func passwordDidChange(to password: String) {
    passwordSpy = password
  }
  
  func canLoginDidChange(to canLogin: Bool) {
    canLoginSpy = canLogin
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
}

class DigitalLoginServiceSpy: DigitalLoginServiceInput {
  var requestSpy: DigitalLoginRequest?
  
  func logIn(withUsernameRequest request: DigitalLoginRequest) {
    requestSpy = request
  }
}

class DigitalLoginStorageSpy: DigitalLoginStorage {
  var usernameSpy: String?
  
  func saveUsername(_ username: String) {
    usernameSpy = username
  }
  
  func loadUsername() -> String? {
    return usernameSpy
  }
}
