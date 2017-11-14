import XCTest

class UsernameLoginInteractorTests: XCTestCase {
  private var interactor: UsernameLoginInteractor!
  private var output: UsernameLoginInteractorOutputSpy!
  private var service: UsernameLoginServiceSpy!
  private var storage: UsernameLoginStorageSpy!
  
  private let validUsername = "name"
  private let validPassword = "pass"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = UsernameLoginInteractorOutputSpy()
    service = UsernameLoginServiceSpy()
    storage = UsernameLoginStorageSpy()
    
    interactor = UsernameLoginInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
  }
  
  func testResetWithNoRememberedUsername() {
    interactor.reset()
    
    XCTAssertEqual(output.usernameSpy, "")
    XCTAssertEqual(output.passwordSpy, "")
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testResetWithRememberedUsername() {
    storage.usernameSpy = validUsername
    
    interactor.reset()
    
    XCTAssertEqual(output.usernameSpy, validUsername)
    XCTAssertEqual(output.passwordSpy, "")
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testChangeUsername() {
    interactor.changeUsername(to: validUsername)
    
    XCTAssertEqual(output.usernameSpy, validUsername)
    XCTAssertEqual(output.passwordSpy, nil)
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testChangeUsernameToSameValue() {
    interactor.changeUsername(to: validUsername)
    output.usernameSpy = nil
    output.canLoginSpy = nil
    
    interactor.changeUsername(to: validUsername)
    
    XCTAssertEqual(output.usernameSpy, nil)
    XCTAssertEqual(output.passwordSpy, nil)
    XCTAssertEqual(output.canLoginSpy, nil)
  }
  
  func testClearUsername() {
    interactor.changeUsername(to: validUsername)
    output.usernameSpy = nil
    output.canLoginSpy = nil
    
    interactor.changeUsername(to: "")
    
    XCTAssertEqual(output.usernameSpy, "")
    XCTAssertEqual(output.passwordSpy, nil)
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testChangePassword() {
    interactor.changePassword(to: validPassword)
    
    XCTAssertEqual(output.usernameSpy, nil)
    XCTAssertEqual(output.passwordSpy, validPassword)
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testChangePasswordToSameValue() {
    interactor.changePassword(to: validPassword)
    output.passwordSpy = nil
    output.canLoginSpy = nil
    
    interactor.changePassword(to: validPassword)
    
    XCTAssertEqual(output.usernameSpy, nil)
    XCTAssertEqual(output.passwordSpy, nil)
    XCTAssertEqual(output.canLoginSpy, nil)
  }
  
  func testClearPassword() {
    interactor.changePassword(to: validPassword)
    output.passwordSpy = nil
    output.canLoginSpy = nil
    
    interactor.changePassword(to: "")
    
    XCTAssertEqual(output.usernameSpy, nil)
    XCTAssertEqual(output.passwordSpy, "")
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testChangePasswordWhenUsernameIsValid() {
    interactor.changeUsername(to: validUsername)
    
    interactor.changePassword(to: validPassword)
    
    XCTAssertEqual(output.usernameSpy, validUsername)
    XCTAssertEqual(output.passwordSpy, validPassword)
    XCTAssertEqual(output.canLoginSpy, true)
  }
  
  func testChangeUsernameWhenPasswordIsValid() {
    interactor.changePassword(to: validPassword)
    
    interactor.changeUsername(to: validUsername)
    
    XCTAssertEqual(output.usernameSpy, validUsername)
    XCTAssertEqual(output.passwordSpy, validPassword)
    XCTAssertEqual(output.canLoginSpy, true)
  }
  
  func testClearUsernameWhenBothAreValid() {
    interactor.changeUsername(to: validUsername)
    interactor.changePassword(to: validPassword)
    
    interactor.changeUsername(to: "")
    
    XCTAssertEqual(output.usernameSpy, "")
    XCTAssertEqual(output.passwordSpy, validPassword)
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testClearPasswordWhenBothAreValid() {
    interactor.changeUsername(to: validUsername)
    interactor.changePassword(to: validPassword)
    
    interactor.changePassword(to: "")
    
    XCTAssertEqual(output.usernameSpy, validUsername)
    XCTAssertEqual(output.passwordSpy, "")
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testLogInWithNoDetails() {
    interactor.logIn(shouldRememberUsername: false)
    
    XCTAssertEqual(output.canLoginSpy, nil)
    XCTAssertEqual(output.loginDidBeginSpy, false)
    XCTAssertNil(service.detailsSpy)
  }
  
  func testLogin() {
    interactor.changeUsername(to: validUsername)
    interactor.changePassword(to: validPassword)
    
    interactor.logIn(shouldRememberUsername: false)
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.loginDidBeginSpy, true)
  }
  
  func testHandleLoginSuccessAndRemember() {
    interactor.changeUsername(to: validUsername)
    interactor.changePassword(to: validPassword)
    interactor.logIn(shouldRememberUsername: true)
    
    interactor.loginDidSucceed()
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.loginDidEndSpy, true)
    XCTAssertNil(output.errorsSpy)
    XCTAssertEqual(storage.usernameSpy, validUsername)
  }
  
  func testHandleLoginSuccessAndNotRemember() {
    interactor.changeUsername(to: validUsername)
    interactor.changePassword(to: validPassword)
    interactor.logIn(shouldRememberUsername: false)
    
    interactor.loginDidSucceed()
    
    XCTAssertEqual(storage.usernameSpy, nil)
  }
  
  func testHandleLoginFailure() {
    interactor.changeUsername(to: validUsername)
    interactor.changePassword(to: validPassword)
    interactor.logIn(shouldRememberUsername: true)
    
    interactor.loginDidFail(dueTo: [error])
    
    XCTAssertEqual(output.canLoginSpy, true)
    XCTAssertEqual(output.loginDidEndSpy, false)
    XCTAssertEqual(output.errorsSpy!, [error])
    XCTAssertEqual(storage.usernameSpy, nil)
  }
  
  func testHelpWithUsername() {
    interactor.helpWithUsername()
    
    XCTAssertEqual(output.helpSpy, LoginHelp.username)
  }
  
  func testHelpWithPassword() {
    interactor.helpWithPassword()
    
    XCTAssertEqual(output.helpSpy, LoginHelp.password)
  }
}

class UsernameLoginInteractorOutputSpy: UsernameLoginInteractorOutput {
  var usernameSpy: String?
  var passwordSpy: String?
  var canLoginSpy: Bool?
  var loginDidBeginSpy = false
  var loginDidEndSpy = false
  var errorsSpy: [LoginError]?
  var helpSpy: LoginHelp?
  
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
    loginDidBeginSpy = true
  }
  
  func loginDidEnd() {
    loginDidEndSpy = true
  }
  
  func loginDidFail(withErrors errors: [LoginError]) {
    errorsSpy = errors
  }
  
  func showHelp(_ help: LoginHelp) {
    helpSpy = help
  }
}

class UsernameLoginServiceSpy: UsernameLoginServiceInput {
  var detailsSpy: UsernameLoginDetails?
  
  func logIn(withUsernameDetails details: UsernameLoginDetails) {
    detailsSpy = details
  }
}

class UsernameLoginStorageSpy: UsernameLoginStorage {
  var usernameSpy: String?
  
  func saveUsername(_ username: String) {
    usernameSpy = username
  }
  
  func loadUsername() -> String? {
    return usernameSpy
  }
}
