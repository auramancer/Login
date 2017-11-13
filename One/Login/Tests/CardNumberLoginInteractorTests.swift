import XCTest

class CardNumberLoginInteractorTests: XCTestCase {
  private var interactor: CardNumberLoginInteractor!
  private var output: CardNumberLoginInteractorOutputSpy!
  private var service: CardNumberLoginServiceInputSpy!
  
  private let validId = "name"
  private let validSecret = "1234"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = CardNumberLoginInteractorOutputSpy()
    service = CardNumberLoginServiceInputSpy()
    
    interactor = CardNumberLoginInteractor()
    interactor.output = output
    interactor.service = service
  }
  
  func testValidateCardNumber() {
    assert(cardNumber: "", isValid: false)
    assert(cardNumber: "a", isValid: true)
    assert(cardNumber: "1", isValid: true)
  }
  
  private func assert(cardNumber: String, isValid: Bool, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(interactor.validateId(cardNumber), isValid, "", file: file, line: line)
  }
  
  func testValidatePIN() {
    assert(pin: "", isValid: false)
    assert(pin: "a", isValid: true)
    assert(pin: "1", isValid: true)
  }
  
  private func assert(pin: String, isValid: Bool, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(interactor.validateSecret(pin), isValid, "", file: file, line: line)
  }
  
  func testInvokeService() {
    interactor.id = validId
    interactor.secret = validSecret
    
    interactor.invokeService()
    
    XCTAssertEqual(service.detailsSpy?.membershipCardNumber, validId)
    XCTAssertEqual(service.detailsSpy?.pin, validSecret)
  }
  
  func testHelpWithCardNumber() {
    interactor.helpWithId()
    
    XCTAssertEqual(output.destinationSpy, LoginDestination.forgottenCardNumber)
  }
  
  func testHelpWithPIN() {
    interactor.helpWithSecret()
    
    XCTAssertEqual(output.destinationSpy, LoginDestination.forgottenPIN)
  }
  
  func testDidNot() {
    interactor.didFailToLogInDueToInvalidToken()
    
    XCTAssertTrue(output.inquireAuthenticationCodeSpy)
  }
}

class CardNumberLoginServiceInputSpy: CardNumberLoginServiceInput {
  var detailsSpy: CardNumberLoginDetails?
  
  func logIn(withCardNumberDetails details: CardNumberLoginDetails) {
    detailsSpy = details
  }
}

class CardNumberLoginInteractorOutputSpy: LoginInteractorOutputSpy, CardNumberLoginInteractorOutput {
  var inquireAuthenticationCodeSpy = false
  
  func inquireAuthenticationCode() {
    inquireAuthenticationCodeSpy = true
  }
}
