import XCTest

class UsernameLoginPresenterTests: XCTestCase {
  private var presenter: UsernameLoginPresenter!
  private var output: UsernameLoginPresenterOutputSpy!
  
  private let validUsername = "name"
  private let validPassword = "pass"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = UsernameLoginPresenterOutputSpy()
    
    presenter = UsernameLoginPresenter()
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
  
  func testCanLogin() {
    presenter.canLoginDidChange(to: true)
    
    XCTAssertEqual(output.enableLoginSpy, true)
    XCTAssertEqual(output.disableLoginSpy, false)
  }
  
  func testCannotLogin() {
    presenter.canLoginDidChange(to: false)
    
    XCTAssertEqual(output.enableLoginSpy, false)
    XCTAssertEqual(output.disableLoginSpy, true)
  }
  
  func testLoginDidBegin() {
    presenter.loginDidBegin()
    
    XCTAssertEqual(output.hideErrorMessageSpy, true)
    XCTAssertEqual(output.showActivityMessageSpy, true)
    XCTAssertEqual(output.activityMessageSpy, nil)
  }
  
  func testLoginDidEnd() {
    presenter.loginDidEnd()
    
    XCTAssertEqual(output.hideActivityMessageSpy, true)
    XCTAssertEqual(output.leaveSpy, true)
  }
  
  func testLoginDidFail() {
    presenter.loginDidFail(withErrors: [error])
    
    XCTAssertEqual(output.hideActivityMessageSpy, true)
    XCTAssertEqual(output.errorMessageSpy, error)
  }
  
  func testShowHelp() {
    let help = LoginHelp.username
    
    presenter.showHelp(help)
    
    XCTAssertEqual(output.helpSpy, help)
  }
}

class UsernameLoginPresenterOutputSpy: UsernameLoginPresenterOutput {
  var usernameSpy: String?
  var passwordSpy: String?
  var enableLoginSpy = false
  var disableLoginSpy = false
  var showActivityMessageSpy = false
  var activityMessageSpy: String?
  var hideActivityMessageSpy = false
  var errorMessageSpy: String?
  var hideErrorMessageSpy = false
  var helpSpy: LoginHelp?
  var leaveSpy = false
  
  func showUsername(_ username: String) {
    usernameSpy = username
  }
  
  func showPassword(_ password: String) {
    passwordSpy = password
  }
  
  func enableLogin() {
    enableLoginSpy = true
  }
  
  func disableLogin() {
    disableLoginSpy = true
  }
  
  func showActivityMessage(_ message: String?) {
    showActivityMessageSpy = true
    activityMessageSpy = message
  }
  
  func hideActivityMessage() {
    hideActivityMessageSpy = true
  }
  
  func showErrorMessage(_ message: String) {
    errorMessageSpy = message
  }
  
  func hideErrorMessage() {
    hideErrorMessageSpy = true
  }
  
  func goToHelpPage(for help: LoginHelp) {
    helpSpy = help
  }
  
  func leave() {
    leaveSpy = true
  }
}
