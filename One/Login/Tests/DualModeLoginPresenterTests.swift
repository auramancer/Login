import XCTest

class DualModeLoginPresenterTests: XCTestCase {
  private var presenter: DualModeLoginPresenter!
  private var output: DualModeLoginPresenterOutputSpy!
  
  typealias Data = LoginTestData
  private let errorMessage = Data.errorMessage
  private let retailIdentity = Data.validRetailIdentity
  
  override func setUp() {
    super.setUp()
    
    output = DualModeLoginPresenterOutputSpy()
    
    presenter = DualModeLoginPresenter()
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
    presenter.loginDidFail(withErrors: [errorMessage])
    
    assertOutputReceived(isLoggingIn: false,
                         message: LoginMessage(text: errorMessage, style: .error),
                         clearMessage: false,
                         leave: false)
  }
  
  func testShowHelp() {
    let help = LoginHelp.cardNumber
    
    presenter.showHelp(help)
    
    XCTAssertEqual(output.helpSpy, help)
  }
  
  func testInquireLoginVerification() {
    presenter.loginModeDidChange(to: .retail)
    
    presenter.showVerification(withIdentity: retailIdentity)
    
    XCTAssertEqual(output.verificationIdentitySpy, retailIdentity)
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

class DualModeLoginPresenterOutputSpy: DualModeLoginPresenterOutput {
  var identifierSpy: String?
  var credentialSpy: String?
  var wordingSpy: DualModeLoginWording?
  var canLoginSpy: Bool?
  var isLoggingInSpy: Bool?
  var messageSpy: LoginMessage?
  var clearMessageSpy = false
  var helpSpy: LoginHelp?
  var verificationIdentitySpy: RetailIdentity?
  var identityCreationIdentitySpy: RetailIdentity?
  var leaveSpy = false
  
  func changeIdentifier(to identifier: String) {
    identifierSpy = identifier
  }
  
  func changeCredential(to credential: String) {
    credentialSpy = credential
  }
  
  func changeWording(to wording: DualModeLoginWording) {
    wordingSpy = wording
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
