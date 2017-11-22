import XCTest

class LoginVerificationPresenterTests: XCTestCase {
  private var presenter: LoginVerificationPresenter!
  private var output: LoginVerificationPresenterOutputSpy!
  
  typealias Data = LoginTestData
  private let error = Data.errorMessage
  private let identity = Data.validRetailIdentity
  
  private let notFoundMessage = "As this is the first time you have logged in with your membership number, we need to validate your account. We have sent you an SMS and eMail with a new verification code, please enter it below. The code will expire after 30 minutes, after which time you will need to request a new code."
  private let expiredMessage = "Login successful, it has been 1 month since we last verified your account. We have sent you an SMS and eMail with a new verification code, please enter it below."
  
  override func setUp() {
    super.setUp()
    
    output = LoginVerificationPresenterOutputSpy()
    
    presenter = LoginVerificationPresenter()
    presenter.output = output
  }
  
  func testDidLoadWhenTokenNotFound() {
    presenter.didLoad(tokenDidExpire: false, canVerify: false)
    
    XCTAssertEqual(output.messageSpy, LoginMessage(text: notFoundMessage, style: .default))
    XCTAssertEqual(output.canVerifySpy, false)
  }
  
  func testDidLoadWhenTokenExpired() {
    presenter.didLoad(tokenDidExpire: true, canVerify: false)
    
    XCTAssertEqual(output.messageSpy, LoginMessage(text: expiredMessage, style: .default))
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
    presenter.showIdentityCreation(withIdentity: identity)
    
    XCTAssertEqual(output.identityCreationIdentitySpy, identity)
  }
  
  func testShowAlert() {
    presenter.showResendConfirmation()
    
    XCTAssertEqual(output.confirmationSpy?.message, "Are you sure you want a new verification code?")
    XCTAssertEqual(output.confirmationSpy?.confirmActionText, "Confirm")
    XCTAssertEqual(output.confirmationSpy?.cancelActionText, "Cancel")
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
  var confirmationSpy: ResendCodeConfirmaiton?
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
  
  func showResendCodeConfirmaiton(_ confirmation: ResendCodeConfirmaiton) {
    confirmationSpy = confirmation
  }
  
  func goToIdentityCreationPage(withIdentity identity: RetailIdentity) {
    identityCreationIdentitySpy = identity
  }
  
  func leave() {
    leaveSpy = true
  }
}
