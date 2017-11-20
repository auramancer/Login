import XCTest

class RetailLoginPresenterTests: XCTestCase {
  private var presenter: RetailLoginPresenter!
  private var output: RetailLoginPresenterOutputSpy!
  
  private let validCardNumber = "1234567890"
  private let validPIN = "8888"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = RetailLoginPresenterOutputSpy()
    
    presenter = RetailLoginPresenter()
    presenter.output = output
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
    let help = LoginHelp.cardNumber
    
    presenter.showHelp(help)
    
    XCTAssertEqual(output.helpSpy, help)
  }
  
  func testShowVerification() {
    let identity = RetailIdentity(cardNumber: validCardNumber, pin: validPIN)
    
    presenter.showVerification(withIdentity: identity)
    
    XCTAssertEqual(output.verificationIdentitySpy, RetailIdentity(cardNumber: validCardNumber, pin: validPIN))
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

class RetailLoginPresenterOutputSpy: RetailLoginPresenterOutput {
  var cardNumberSpy: String?
  var pinSpy: String?
  var canLoginSpy: Bool?
  var isLoggingInSpy: Bool?
  var messageSpy: LoginMessage?
  var clearMessageSpy = false
  var helpSpy: LoginHelp?
  var verificationIdentitySpy: RetailIdentity?
  var identityCreationIdentitySpy: RetailIdentity?
  var leaveSpy = false
  
  func changeCardNumber(to cardNumber: String) {
    cardNumberSpy = cardNumber
  }
  
  func changePIN(to pin: String) {
    pinSpy = pin
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
  
  func goToVerificationPage(withIdentity identity: RetailIdentity) {
    verificationIdentitySpy = identity
  }
  
  func goToIdentityCreationPage(withIdentity identity: RetailIdentity) {
    identityCreationIdentitySpy = identity
  }
  
  func leave() {
    leaveSpy = true
  }
}
