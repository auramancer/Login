import XCTest

class MembershipCardNumberLoginInteractorTests: XCTestCase {
  private var interactor: MembershipCardNumberLoginInteractor!
  private var output: LoginInteractorOutputSpy!
  private var service: MembershipCardNumberLoginServiceInputSpy!
  
  private let validId = "name"
  private let validSecret = "1234"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = LoginInteractorOutputSpy()
    service = MembershipCardNumberLoginServiceInputSpy()
    
    interactor = MembershipCardNumberLoginInteractor()
    interactor.output = output
    interactor.service = service
  }
  
  func testValidateMembershipCardNumber() {
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
  
  func testHelpWithMembershipCardNumber() {
    interactor.helpWithId()
    
    XCTAssertEqual(output.destinationSpy, LoginDestination.forgottenMembershipCardNumber)
  }
  
  func testHelpWithPIN() {
    interactor.helpWithSecret()
    
    XCTAssertEqual(output.destinationSpy, LoginDestination.forgottenPIN)
  }
}

class MembershipCardNumberLoginServiceInputSpy: MembershipCardNumberLoginServiceInput {
  var detailsSpy: MembershipCardNumberLoginDetails?
  
  func logIn(withMembershipCardNumberDetails details: MembershipCardNumberLoginDetails) {
    detailsSpy = details
  }
}
