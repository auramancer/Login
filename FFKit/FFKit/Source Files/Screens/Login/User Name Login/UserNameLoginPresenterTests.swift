import XCTest
@testable import FFKit

class UserNameLoginPresenterTests: XCTestCase {
  private var presenter: UserNameLoginPresenter!
  private var output: UserNameLoginPresenterOutputSpy!
  
  private let userName = "name"
  private let password = "1234"
  private let error = UserNameLoginError.unrecognized
  
  override func setUp() {
    super.setUp()
    
    output = UserNameLoginPresenterOutputSpy()
    
    presenter = UserNameLoginPresenter()
    presenter.output = output
  }
  
  func testUpdateStateToReady() {
    presenter.updateState(.ready)
    
    XCTAssertEqual(output.logInEnabledSpy, true)
  }
  
  func testUpdateStateToNotReady() {
    presenter.updateState(.notReady)
    
    XCTAssertEqual(output.logInEnabledSpy, false)
  }
  
  func testUpdateStateToInProgress() {
    presenter.updateState(.inProgress)
    
    XCTAssertEqual(output.logInEnabledSpy, false)
    XCTAssertEqual(output.didShowActivityMessage, true)
    XCTAssertEqual(output.activityMessageSpy, nil)
  }
  
  func testUpdateStateToReadyFromInProgress() {
    presenter.updateState(.inProgress)
    presenter.updateState(.ready)
    
    XCTAssertEqual(output.didHideActivityMessage, true)
    XCTAssertEqual(output.didHideErrorMessage, true)
  }
  
  func testUpdateResultToSucceeded() {
    presenter.updateResult(.succeeded)
    
    XCTAssertEqual(output.didClose, true)
  }
  
  func testUpdateResultToFailed() {
    presenter.updateResult(.failed([error]))
    
    XCTAssertEqual(output.didShowErrorMessage, true)
    XCTAssertEqual(output.didClose, false)
  }
}

private class UserNameLoginPresenterOutputSpy: UserNameLoginPresenterOutput {
  var logInEnabledSpy: Bool?
  var activityMessageSpy: String?
  var didShowActivityMessage = false
  var didHideActivityMessage = false
  var errorMessageSpy: String?
  var didShowErrorMessage = false
  var didHideErrorMessage = false
  var didClose = false
  
  func setLogInEnabled(to isEnabled: Bool) {
    logInEnabledSpy = isEnabled
  }
  
  func showActivityMessage(_ message: String?) {
    didShowActivityMessage = true
    activityMessageSpy = message
  }
  
  func hideActivityMessage() {
    didHideActivityMessage = true
  }
  
  func showErrorMessage(_ message: String?) {
    didShowErrorMessage = true
    errorMessageSpy = message
  }
  
  func hideErrorMessage() {
    didHideErrorMessage = true
  }
  
  func close() {
    didClose = true
  }
}
