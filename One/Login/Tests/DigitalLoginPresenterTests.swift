import XCTest

class DigitalLoginPresenterTests: XCTestCase {
  private var presenter: DigitalLoginPresenter!
  private var output: DigitalLoginPresenterOutputSpy!
  
  typealias Data = LoginTestData
  private let username = Data.validUsername
  private let identity = Data.validDigitalIdentity
  private let error = Data.errorMessage
  
  override func setUp() {
    super.setUp()
    
    output = DigitalLoginPresenterOutputSpy()
    
    presenter = DigitalLoginPresenter()
    presenter.output = output
  }
  
  func testDidLoad() {
    presenter.didLoad(identity: Data.digitalIdentityIdOnly, canLogin: true)
    
    XCTAssertEqual(output.usernameSpy, username)
    XCTAssertEqual(output.passwordSpy, "")
    XCTAssertEqual(output.canLoginSpy, true)
  }
  
  func testChangeCanLogin() {
    assertOutputReceived(canLogin: true, whenChangeCanLoginTo: true)
    assertOutputReceived(canLogin: false, whenChangeCanLoginTo: false)
  }
  
  func testLoginDidBegin() {
    presenter.loginDidBegin()

    assertOutputReceived(isLoggingIn: true,
                         message: nil,
                         clearMessage: true,
                         leave: false)
  }

  func testLoginDidEnd() {
    presenter.loginDidEnd()

    assertOutputReceived(isLoggingIn: false,
                         message: nil,
                         clearMessage: false,
                         leave: true)
  }

  func testLoginDidFail() {
    presenter.loginDidFail(withErrors: [error])

    assertOutputReceived(isLoggingIn: false,
                         message: LoginMessage(text: error, style: .error),
                         clearMessage: false,
                         leave: false)
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
                                    message: LoginMessage?,
                                    clearMessage: Bool,
                                    leave: Bool,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.isLoggingInSpy, isLoggingIn, "isLoggingIn", file: file, line: line)
    XCTAssertEqual(output.messageSpy, message, "message", file: file, line: line)
    XCTAssertEqual(output.clearMessageSpy, clearMessage, "clearMessage", file: file, line: line)
    XCTAssertEqual(output.leaveSpy, leave, "leave", file: file, line: line)
  }
}

class DigitalLoginPresenterOutputSpy: DigitalLoginPresenterOutput {
  var usernameSpy: String?
  var passwordSpy: String?
  var canLoginSpy: Bool?
  var isLoggingInSpy: Bool?
  var messageSpy: LoginMessage?
  var clearMessageSpy = false
  var helpSpy: LoginHelp?
  var leaveSpy = false
  
  func changeIdentifier(to username: String) {
    usernameSpy = username
  }
  
  func changeCredential(to password: String) {
    passwordSpy = password
  }
  
  func changeCanLogin(to canLogin: Bool) {
    canLoginSpy = canLogin
  }
  
  func changeIsLoggingIn(to isLoggingIn: Bool) {
    isLoggingInSpy = isLoggingIn
  }
  
  func showMessage(_ message: LoginMessage) {
    messageSpy = message
  }
  
  func clearMessage() {
    clearMessageSpy = true
  }
  
  func goToHelpPage(for help: LoginHelp) {
    helpSpy = help
  }
  
  func leave() {
    leaveSpy = true
  }
}
