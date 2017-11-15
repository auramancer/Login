import XCTest

class DigitalLoginPresenterTests: XCTestCase {
  private var presenter: DigitalLoginPresenter!
  private var output: DigitalLoginPresenterOutputSpy!
  
  private let validUsername = "name"
  private let validPassword = "pass"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = DigitalLoginPresenterOutputSpy()
    
    presenter = DigitalLoginPresenter()
    presenter.output = output
  }
  
  func testChangeUsername() {
    presenter.usernameDidChange(to: validUsername)
  
    XCTAssertEqual(output.usernameSpy, validUsername)
  }
  
  func testChangePassword() {
    presenter.passwordDidChange(to: validPassword)
    
    XCTAssertEqual(output.passwordSpy, validPassword)
  }
  
  func testChangeCanLogin() {
    assertOutputReceived(canLogin: true, whenChangeCanLoginTo: true)
    assertOutputReceived(canLogin: false, whenChangeCanLoginTo: false)
  }
  
  func testLoginDidBegin() {
    presenter.loginDidBegin()

    assertOutputReceived(isLoggingIn: true,
                         errorMessage: nil,
                         didClearErrorMessage: true,
                         didLeave: false)
  }

  func testLoginDidEnd() {
    presenter.loginDidEnd()

    assertOutputReceived(isLoggingIn: false,
                         errorMessage: nil,
                         didClearErrorMessage: false,
                         didLeave: true)
  }

  func testLoginDidFail() {
    presenter.loginDidFail(withErrors: [error])

    assertOutputReceived(isLoggingIn: false,
                         errorMessage: error,
                         didClearErrorMessage: false,
                         didLeave: false)
  }
  
  func testShowHelp() {
    let help = LoginHelp.username
    
    presenter.showHelp(help)
    
    XCTAssertEqual(output.helpSpy, help)
  }
  
  // MARK: helpers
  
  private func assertOutputReceived(canLogin expected: Bool?,
                                    whenChangeCanLoginTo canLogin: Bool,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    presenter.canLoginDidChange(to: canLogin)
    
    XCTAssertEqual(output.canLoginSpy, expected, "canLogin", file: file, line: line)
  }
  
  private func assertOutputReceived(isLoggingIn: Bool?,
                                    errorMessage: String?,
                                    didClearErrorMessage: Bool,
                                    didLeave: Bool,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.isLoggingInSpy, isLoggingIn, "isLoggingIn", file: file, line: line)
    XCTAssertEqual(output.errorMessageSpy, errorMessage, "errorMessage", file: file, line: line)
    XCTAssertEqual(output.didClearErrorMessageSpy, didClearErrorMessage, "didClearErrorMessage", file: file, line: line)
    XCTAssertEqual(output.didLeaveSpy, didLeave, "didLeave", file: file, line: line)
  }
}

class DigitalLoginPresenterOutputSpy: DigitalLoginPresenterOutput {
  var usernameSpy: String?
  var passwordSpy: String?
  var canLoginSpy: Bool?
  var isLoggingInSpy: Bool?
  var errorMessageSpy: String?
  var didClearErrorMessageSpy = false
  var helpSpy: LoginHelp?
  var didLeaveSpy = false
  
  func changeUsername(to username: String) {
    usernameSpy = username
  }
  
  func changePassword(to password: String) {
    passwordSpy = password
  }
  
  func changeCanLogin(to canLogin: Bool) {
    canLoginSpy = canLogin
  }
  
  func changeIsLoggingIn(to isLoggingIn: Bool) {
    isLoggingInSpy = isLoggingIn
  }
  
  func changeErrorMessage(to message: String) {
    errorMessageSpy = message
  }
  
  func clearErrorMessage() {
    didClearErrorMessageSpy = true
  }
  
  func goToHelpPage(for help: LoginHelp) {
    helpSpy = help
  }
  
  func leave() {
    didLeaveSpy = true
  }
}
