import XCTest
@testable import Login

class AccountInteractorTests: XCTestCase {
  var interactor: AccountInteractor!
  var output: AccountInteractorOutputSpy!
  
  override func setUp() {
    super.setUp()
    
    output = AccountInteractorOutputSpy()
    
    interactor = AccountInteractor()
    interactor.output = output
  }
  
  func testShowErrorWhenValidateWithNoInput() {
    interactor.validateAccount("")
    
    XCTAssertTrue(output.errorIsShowed)
  }
}

class AccountInteractorOutputSpy: AccountInteractorOutput {
  var errorIsShowed = false
  
  func showError() {
    errorIsShowed = true
  }
}
