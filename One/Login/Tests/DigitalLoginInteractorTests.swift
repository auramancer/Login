import XCTest

class DigitalLoginInteractorTests: XCTestCase {
  private var interactor: DigitalLoginInteractor!
  private var output: DigitalLoginInteractorOutputSpy!
  private var service: DigitalLoginServiceSpy!
  private var storage: DigitalLoginStorageSpy!
  
  private let validUsername = "username"
  private let validPassword = "password"
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
  
  func testLoadWithNoRememberedUsername() {
    interactor.load()
    
    XCTAssertEqual(output.loadRequestSpy, DigitalLoginRequest(username: "", password: ""))
  }
  
  func testLoadWithRememberedUsername() {
    storage.usernameSpy = validUsername
    
    interactor.load()
    
    XCTAssertEqual(output.loadRequestSpy, DigitalLoginRequest(username: validUsername, password: ""))
  }
  
  func testChangeUsername() {
    assertOutputReceived(canLogin: nil, whenChangeUsername: "", to: validUsername, passwordRemains: "")
    assertOutputReceived(canLogin: true, whenChangeUsername: "", to: validUsername, passwordRemains: validPassword)
    assertOutputReceived(canLogin: false, whenChangeUsername: validUsername, to: "", passwordRemains: validPassword)
  }
  
  func testChangePassword() {
    assertOutputReceived(canLogin: nil, whenChangePassword: "", to: validPassword, usernameRemains: "")
    assertOutputReceived(canLogin: true, whenChangePassword: "", to: validPassword, usernameRemains: validUsername)
    assertOutputReceived(canLogin: false, whenChangePassword: validPassword, to: "", usernameRemains: validUsername)
  }
  
  func testLogin() {
    set(username: validUsername, password: validPassword)
    output.reset()
    
    interactor.logIn(shouldRememberUsername: true)
    
    assertOutputReceived(canLogin: nil)
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(DigitalLoginRequest(username: validUsername, password: validPassword))
  }
  
  func testHandleLoginSuccessAndRemember() {
    login()
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: true,
                         loginErrors: nil)
    assertStorageSaved(validUsername)
  }
  
  func testHandleLoginSuccessAndNotRemember() {
    login(shouldRemember: false)
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertStorageSaved(nil)
  }
  
  func testHandleLoginFailure() {
    login()
    output.reset()
    
    interactor.loginDidFail(dueTo: [SimpleError(error)])
    
    assertOutputReceived(loginDidBegin: false,
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
  
  private func set(username: String, password: String) {
    interactor.load()
    interactor.changeUsername(to: username)
    interactor.changePassword(to: password)
  }
  
  private func login(shouldRemember: Bool = true) {
    set(username: validUsername, password: validPassword)
    interactor.logIn(shouldRememberUsername: shouldRemember)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    whenChangeUsername oldUsername: String,
                                    to newUsername: String,
                                    passwordRemains password: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    set(username: oldUsername, password: password)
    output.reset()
    
    interactor.changeUsername(to: newUsername)
    
    assertOutputReceived(canLogin: canLogin, file: file, line: line)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    whenChangePassword oldPassword: String,
                                    to newPassword: String,
                                    usernameRemains username: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    set(username: username, password: oldPassword)
    output.reset()
    
    interactor.changePassword(to: newPassword)
    
    assertOutputReceived(canLogin: canLogin, file: file, line: line)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.canLoginSpy, canLogin, "canLogin", file: file, line: line)
  }
  
  private func assertOutputReceived(loginDidBegin: Bool?,
                                    loginDidEnd: Bool?,
                                    loginErrors: [String]?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.loginDidBeginSpy, loginDidBegin, "loginDidBegin", file: file, line: line)
    XCTAssertEqual(output.loginDidEndSpy, loginDidEnd, "loginDidEnd", file: file, line: line)
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
  var loadRequestSpy: DigitalLoginRequest?
  var canLoginSpy: Bool?
  var loginDidBeginSpy = false
  var loginDidEndSpy = false
  var loginErrorsSpy: [String]?
  var helpSpy: LoginHelp?
  
  func reset() {
    canLoginSpy = nil
    loginDidBeginSpy = false
    loginDidEndSpy = false
    loginErrorsSpy = nil
    helpSpy = nil
  }
  
  func didLoad(withRememberedRequest request: DigitalLoginRequest) {
    loadRequestSpy = request
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
