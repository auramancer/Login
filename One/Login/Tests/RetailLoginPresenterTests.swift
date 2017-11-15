import XCTest

class RetailLoginPresenterTests: XCTestCase {
  private var presenter: RetailLoginPresenter!
  private var output: RetailLoginPresenterOutputSpy!
  
  private let validCardNumber = "12345678"
  private let validPIN = "1234"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = RetailLoginPresenterOutputSpy()
    
    presenter = RetailLoginPresenter()
    presenter.output = output
  }
  
  func testChangeCardNumber() {
    presenter.cardNumberDidChange(to: validCardNumber)
    
    XCTAssertEqual(output.cardNumberSpy, validCardNumber)
  }
  
  func testChangePIN() {
    presenter.pinDidChange(to: validPIN)
    
    XCTAssertEqual(output.pinSpy, validPIN)
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
    let help = LoginHelp.cardNumber
    
    presenter.showHelp(help)
    
    XCTAssertEqual(output.helpSpy, help)
  }
  
  func testInquireVerificationCode() {
    let request = RetailLoginRequest(cardNumber: validCardNumber, pin: validPIN)
    
    presenter.inquireVerificationCode(forRequest: request)
    
    XCTAssertEqual(output.verificationRequestSpy, RetailLoginRequest(cardNumber: validCardNumber, pin: validPIN))
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

class RetailLoginPresenterOutputSpy: RetailLoginPresenterOutput {
  var cardNumberSpy: String?
  var pinSpy: String?
  var canLoginSpy: Bool?
  var isLoggingInSpy: Bool?
  var errorMessageSpy: String?
  var didClearErrorMessageSpy = false
  var helpSpy: LoginHelp?
  var verificationRequestSpy: RetailLoginRequest?
  var didLeaveSpy = false
  
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
  
  func changeErrorMessage(to message: String) {
    errorMessageSpy = message
  }
  
  func clearErrorMessage() {
    didClearErrorMessageSpy = true
  }
  
  func goToHelpPage(for help: LoginHelp) {
    helpSpy = help
  }
  
  func goToVerificationPage(withRequest request: RetailLoginRequest) {
    verificationRequestSpy = request
  }
  
  func leave() {
    didLeaveSpy = true
  }
}
