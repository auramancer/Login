import XCTest

class LoginVerificationPresenterTests: XCTestCase {
  private var presenter: LoginVerificationPresenter!
  private var output: LoginVerificationPresenterOutputSpy!
  
  private let validCardNumber = "1234567890"
  private let validPIN = "8888"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = LoginVerificationPresenterOutputSpy()
    
    presenter = LoginVerificationPresenter()
    presenter.output = output
  }
  
  func testDidLoad() {
    presenter.didLoad(canVerify: false)
    
    XCTAssertEqual(output.canVerifySpy, false)
  }
  
  func testCanVerifyDidChange() {
    presenter.canVerifyDidChange(to: true)
    
    XCTAssertEqual(output.canVerifySpy, true)
  }

  func testVerificationDidBegin() {
    presenter.verificationDidBegin()
    
    assertOutputReceived(isVerifying: true,
                         message: nil,
                         clearMessage: true,
                         leave: false)
  }
  
  func testVerificationDidEnd() {
    presenter.verificationDidEnd()
    
    assertOutputReceived(isVerifying: false,
                         message: nil,
                         clearMessage: false,
                         leave: true)
  }
  
  func testVerificationDidFail() {
    presenter.verificationDidFail(dueTo: [error])
    
    assertOutputReceived(isVerifying: false,
                         message: LoginMessage(text: error, style: .error),
                         clearMessage: false,
                         leave: false)
  }
  
  func testShowIdentityCreation() {
    let identity = RetailIdentity(cardNumber: "", pin: "")
    
    presenter.showIdentityCreation(withIdentity: identity)
    
    XCTAssertEqual(output.identityCreationIdentitySpy, identity)
  }
  
  func testShowAlert() {
    presenter.showResendConfirmation()
    
    XCTAssertEqual(output.alertSpy?.message, "Are you sure you want a new verification code?")
    XCTAssertEqual(output.alertSpy?.confirmActionTitle, "Confirm")
  }
  
  // MARK: helpers
  
  private func assertOutputReceived(isVerifying: Bool?,
                                    message: LoginMessage?,
                                    clearMessage: Bool,
                                    leave: Bool,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.isVerifyingSpy, isVerifying, "isVerifying", file: file, line: line)
    XCTAssertEqual(output.messageSpy, message, "message", file: file, line: line)
    XCTAssertEqual(output.clearMessageSpy, clearMessage, "clearMessage", file: file, line: line)
    XCTAssertEqual(output.leaveSpy, leave, "leave", file: file, line: line)
  }
}

class LoginVerificationPresenterOutputSpy: LoginVerificationPresenterOutput {
  var canVerifySpy: Bool?
  var isVerifyingSpy: Bool?
  var messageSpy: LoginMessage?
  var clearMessageSpy = false
  var alertSpy: ResendCodeConfirmaitonAlert?
  var identityCreationIdentitySpy: RetailIdentity?
  var leaveSpy = false
  
  func changeCanVerify(to canVerify: Bool) {
    canVerifySpy = canVerify
  }
  
  func changeIsVerifying(to isVerifying: Bool) {
    isVerifyingSpy = isVerifying
  }
  
  func showMessage(_ message: LoginMessage) {
    messageSpy = message
  }
  
  func clearMessage() {
    clearMessageSpy = true
  }
  
  func showResendCodeConfirmaitonAlert(_ alert: ResendCodeConfirmaitonAlert) {
    alertSpy = alert
  }
  
  func goToIdentityCreationPage(withIdentity identity: RetailIdentity) {
    identityCreationIdentitySpy = identity
  }
  
  func leave() {
    leaveSpy = true
  }
}
