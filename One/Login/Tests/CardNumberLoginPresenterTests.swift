import XCTest

class CardNumberLoginPresenterTests: XCTestCase {
  private var presenter: CardNumberLoginPresenter!
  private var output: CardNumberLoginPresenterOutputSpy!
  
  private let validCardNumber = "12345678"
  private let validPIN = "1234"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = CardNumberLoginPresenterOutputSpy()
    
    presenter = CardNumberLoginPresenter()
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
    let help = LoginHelp.cardNumber
    
    presenter.showHelp(help)
    
    XCTAssertEqual(output.helpSpy, help)
  }
  
  func testInquireVerificationCode() {
//    let details = CardNumberLoginDetails(cardNumber: validCardNumber,
//                                         pin: validPIN,
//                                         authenticationToken: validToken)
    
//    presenter.inquireVerificationCode(for: details)
    
//    XCTAssertEqual(output.detailsSpy?.cardNumber, validCardNumber)
//    XCTAssertEqual(output.detailsSpy?.pin, validPIN)
  }
}

class CardNumberLoginPresenterOutputSpy: CardNumberLoginPresenterOutput {
  var cardNumberSpy: String?
  var pinSpy: String?
  var enableLoginSpy = false
  var disableLoginSpy = false
  var showActivityMessageSpy = false
  var activityMessageSpy: String?
  var hideActivityMessageSpy = false
  var errorMessageSpy: String?
  var hideErrorMessageSpy = false
  var helpSpy: LoginHelp?
  var detailsSpy: CardNumberLoginDetails?
  var leaveSpy = false
  
  func showCardNumber(_ cardNumber: String) {
    cardNumberSpy = cardNumber
  }
  
  func showPIN(_ pin: String) {
    pinSpy = pin
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
  
  func goToVerificationPage(withDetails details: CardNumberLoginDetails) {
    detailsSpy = details
  }
  
  func leave() {
    leaveSpy = true
  }
}
