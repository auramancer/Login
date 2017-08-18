import XCTest
@testable import Login

class AccountPresenterTests: XCTestCase {
  var presenter: AccountPresenter!
  var view: AccountViewInputSpy!
  
  override func setUp() {
    super.setUp()
    
    view = AccountViewInputSpy()
    
    presenter = AccountPresenter()
    presenter.view = view
  }
  
  func testShowError() {
    assertErrorMessage("Enter an email or phone number", isShowedForError: .inputIsEmpty)
    assertErrorMessage("Couldn't find your account", isShowedForError: .accountIsNotRecognized)
    assertErrorMessage("Sorry, something went wrong there. Try again.", isShowedForError: .serviceIsNotAvailable)
  }
  
  private func assertErrorMessage(_ message: String?, isShowedForError error: AccountError) {
    presenter.showError(error)
    
    XCTAssertEqual(view.errorMessage, message)
  }
}

class AccountViewInputSpy: AccountViewInput {
  var errorMessage: String?
  
  func showErrorMessage(_ message: String) {
    errorMessage = message
  }
}



