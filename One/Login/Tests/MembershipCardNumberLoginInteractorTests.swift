import XCTest

class UsernameLoginInteractorTests: XCTestCase {
  private var interactor: UsernameLoginInteractor!
  private var output: LoginInteractorOutputSpy!
  private var service: UsernameLoginServiceInputSpy!
  
  private let validId = "name"
  private let validSecret = "1234"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = LoginInteractorOutputSpy()
    service = UsernameLoginServiceInputSpy()
    
    interactor = UsernameLoginInteractor()
    interactor.output = output
    interactor.service = service
  }
  
  func testValidateUsername() {
    assert(username: "", isValid: false)
    assert(username: "a", isValid: true)
    assert(username: "1", isValid: true)
  }
  
  private func assert(username: String, isValid: Bool, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(interactor.validateId(username), isValid, "", file: file, line: line)
  }
  
  func testValidatePassword() {
    assert(password: "", isValid: false)
    assert(password: "a", isValid: true)
    assert(password: "1", isValid: true)
  }
  
  private func assert(password: String, isValid: Bool, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(interactor.validateSecret(password), isValid, "", file: file, line: line)
  }
  
  func testInvokeService() {
    interactor.id = validId
    interactor.secret = validSecret
    
    interactor.invokeService()
    
    XCTAssertEqual(service.detailsSpy?.username, validId)
    XCTAssertEqual(service.detailsSpy?.password, validSecret)
  }
  
  func testHelpWithUsername() {
    interactor.helpWithId()
    
    XCTAssertEqual(output.destinationSpy, LoginDestination.forgottenUsername)
  }
  
  func testHelpWithPassword() {
    interactor.helpWithSecret()
    
    XCTAssertEqual(output.destinationSpy, LoginDestination.forgottenPassword)
  }
}

class UsernameLoginServiceInputSpy: UsernameLoginServiceInput {
  var detailsSpy: UsernameLoginDetails?
  
  func logIn(withUsernameDetails details: UsernameLoginDetails) {
    detailsSpy = details
  }
}
