/*
Story: Log in

As a user
In order to sign in into my account
I need to enter my userid.

Scenario 1: User enters nothing
Given that user in on the login userid screen
And userid field is empty
When he press next
Then a prompt will ask him to enter his userid

Scenario 2: User enters his userid correctly
Given that user in on the login userid screen
And userid field is filled with a recognized userid
When he press next
Then user will be taken to the password screen.

Scenario 3: User enters his userid incorrectly
Given that user in on the login userid screen
And userid field is filled with a userid that cannot be recognized
When he press next
Then a prompt will tell him the userid cannot be recognized

Scenario 4: User forgets his userid
Given that user in on the login userid screen
And userid don't know his userif
When he press forgot userid
Then user will be taken to the userid recovery screen.

Scenario 5: Service is not available
Given that user in on the login userid screen
And userid field is filled with a userid
And service is not available
When he press next
Then a prompt will tell him to try again later.
*/

import XCTest
@testable import Login

class AccountInteractorTests: XCTestCase {
  var interactor: AccountInteractor!
  var output: AccountInteractorOutputSpy!
  var service: AccountInteractorServiceSpy!
  
  override func setUp() {
    super.setUp()
    
    output = AccountInteractorOutputSpy()
    service = AccountInteractorServiceSpy()
    
    interactor = AccountInteractor()
    interactor.output = output
    interactor.service = service
  }
  
  func testShowErrorWhenValidateWithNoInput() {
    interactor.validateAccount("")
    
    assertOutputReceived(error: .inputIsEmpty)
  }
  
  func testShowPasswordInputWhenAccountIsValid() {
    service.validAccounts = ["xf01", "cy02"]
    
    interactor.validateAccount("xf01")
    
    XCTAssertTrue(output.passwordInputIsShowed)
    XCTAssertEqual(output.errors.count, 0)
  }
  
  func testShowErrorWhenAccountIsInvalid() {
    service.validAccounts = ["xf01", "cy02"]
    
    interactor.validateAccount("zxs03")
    
    XCTAssertFalse(output.passwordInputIsShowed)
    assertOutputReceived(error: .accountIsNotRecognized)
  }
  
  func testShowErrorWhenServiceIsNotAvailable() {
    service.isAvailable = false
    service.validAccounts = ["xf01", "cy02"]
    
    interactor.validateAccount("xf01")
    
    XCTAssertFalse(output.passwordInputIsShowed)
    assertOutputReceived(error: .serviceIsNotAvailable)
  }
  
  private func assertOutputReceived(error: AccountError) {
    XCTAssertEqual(output.errors.count, 1)
    XCTAssertEqual(output.errors.first, error)
  }
}

class AccountInteractorOutputSpy: AccountInteractorOutput {
  var errors = [AccountError]()
  var passwordInputIsShowed = false
  
  func showError(_ error: AccountError) {
    errors.append(error)
  }
  
  func showPasswordInput() {
    passwordInputIsShowed = true
  }
}

class AccountInteractorServiceSpy: AccountInteractorService {
  var isAvailable = true
  var validAccounts: [String]!
  
  func validateAccount(_ id: String, completionHandler: (Bool?, AccountError?) -> Void) {
    if isAvailable {
      let isValid = validAccounts.contains(id)
      completionHandler(isValid, nil)
    }
    else {
      completionHandler(nil, .serviceIsNotAvailable)
    }
  }
}
