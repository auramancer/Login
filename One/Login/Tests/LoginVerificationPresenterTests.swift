import XCTest

class LoginVerificationPresenterTests: XCTestCase {
  private var presenter: LoginVerificationPresenter!
  private var output: LoginVerificationPresenterOutputSpy!
  
  private let validCardNumber = "12345678"
  private let validPIN = "1234"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = LoginVerificationPresenterOutputSpy()
    
    presenter = LoginVerificationPresenter()
    presenter.output = output
  }
  
  func testCanVerify() {
    presenter.canVerifyDidChange(to: true)
    
    XCTAssertEqual(output.enableVerifySpy, true)
    XCTAssertEqual(output.disableVerifySpy, false)
  }
  
  func testCannotVerify() {
    presenter.canVerifyDidChange(to: false)
    
    XCTAssertEqual(output.enableVerifySpy, false)
    XCTAssertEqual(output.disableVerifySpy, true)
  }
  
  func testVerifyDidBegin() {
    presenter.verificationDidBegin()
    
    XCTAssertEqual(output.hideErrorMessageSpy, true)
    XCTAssertEqual(output.showActivityMessageSpy, true)
    XCTAssertEqual(output.activityMessageSpy, nil)
  }
  
  func testVerifyDidEnd() {
    presenter.verificationDidEnd()
    
    XCTAssertEqual(output.hideActivityMessageSpy, true)
    XCTAssertEqual(output.leaveSpy, true)
  }
  
  func testVerifyDidFail() {
    presenter.verificationDidFail(dueTo: [error])
    
    XCTAssertEqual(output.hideActivityMessageSpy, true)
    XCTAssertEqual(output.errorMessageSpy, error)
  }
}

class LoginVerificationPresenterOutputSpy: LoginVerificationPresenterOutput {
  var enableVerifySpy = false
  var disableVerifySpy = false
  var showActivityMessageSpy = false
  var activityMessageSpy: String?
  var hideActivityMessageSpy = false
  var errorMessageSpy: String?
  var hideErrorMessageSpy = false
  var leaveSpy = false
  
  func enableVerify() {
    enableVerifySpy = true
  }
  
  func disableVerify() {
    disableVerifySpy = true
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
  
  func leave() {
    leaveSpy = true
  }
}
