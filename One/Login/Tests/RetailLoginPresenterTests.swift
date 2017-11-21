import XCTest

class RetailLoginPresenterTests: XCTestCase {
  private var presenter: RetailLoginPresenter!
  private var output: RetailLoginPresenterOutputSpy!
  
  typealias Data = LoginTestData
  private let error = Data.errorMessage
  private let cardNumber = Data.validCardNumber
  private let identity = Data.validRetailIdentity
  
  override func setUp() {
    super.setUp()
    
    output = RetailLoginPresenterOutputSpy()
    
    presenter = RetailLoginPresenter()
    presenter.output = output
  }
  
  func testDidLoad() {
    presenter.didLoad(identity: Data.retailIdentityIdOnly, canLogin: true)
    
    XCTAssertEqual(output.cardNumberSpy, cardNumber)
    XCTAssertEqual(output.pinSpy, "")
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
    let help = LoginHelp.cardNumber
    
    presenter.showHelp(help)
    
    XCTAssertEqual(output.helpSpy, help)
  }
  
  func testShowVerification() {
    presenter.showVerification(withIdentity: identity)
    
    XCTAssertEqual(output.verificationIdentitySpy, identity)
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
  
  func changeIdentifier(to cardNumber: String) {
    cardNumberSpy = cardNumber
  }
  
  func changeCredential(to pin: String) {
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
