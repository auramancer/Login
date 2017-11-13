import XCTest

class LoginPresenterTests: XCTestCase {
  private var presenter: LoginPresenter!
  private var output: LoginPresenterOutputSpy!
  
  private let validId = "name"
  private let validSecret = "1234"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = LoginPresenterOutputSpy()
    
    presenter = LoginPresenter()
    presenter.output = output
  }
  
  func testLoginWasEnabled() {
    presenter.loginWasEnabled()
    
    XCTAssertEqual(output.didEnable, true)
  }

  func testLoginWasDisabled() {
    presenter.loginWasDisabled()
    
    XCTAssertEqual(output.didDisable, true)
  }

  func testLoginDidBegin() {
    presenter.loginDidBegin()
    
    XCTAssertEqual(output.didHideErrorMessage, true)
    XCTAssertEqual(output.didShowActivityMessage, true)
    XCTAssertEqual(output.activityMessageSpy, nil)
  }
  
  func testLoginDidEnd() {
    presenter.loginDidEnd()
    
    XCTAssertEqual(output.didHideActivityMessage, true)
    XCTAssertEqual(output.didLeave, true)
  }
  
  func testLoginDidFail() {
    presenter.loginDidFail(dueTo: [error])
    
    XCTAssertEqual(output.didHideActivityMessage, true)
    XCTAssertEqual(output.didShowErrorMessage, true)
    XCTAssertEqual(output.errorMessageSpy, error)
  }
  
  func testShowHelp() {
    let help = "forgottenUsername"
    
    presenter.showHelp(help)
    
    XCTAssertEqual(output.destinationSpy, destination)
  }
}

private class LoginPresenterOutputSpy: LoginPresenterOutput {
  var didEnable = false
  var didDisable = false
  var didShowActivityMessage = false
  var activityMessageSpy: String?
  var didHideActivityMessage = false
  var didShowErrorMessage = false
  var errorMessageSpy: String?
  var didHideErrorMessage = false
  var destinationSpy: LoginDestination?
  var didLeave = false
  
  func loginWasEnabled() {
    didEnable = true
  }
  
  func loginWasDisabled() {
    didDisable = true
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
  
  func navigate(to destination: LoginDestination) {
    destinationSpy = destination
  }
  
  func leave() {
    didLeave = true
  }
}

