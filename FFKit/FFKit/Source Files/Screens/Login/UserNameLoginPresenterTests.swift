import XCTest
@testable import FFKit

class UserNameLoginPresenterTests: XCTestCase {
  private var presenter: UserNameLoginPresenter!
  private var output: UserNameLoginPresenterOutputSpy!
  
  private let userName = "name"
  private let password = "1234"
  private let error = SimpleError(message: "Some error")
  
  override func setUp() {
    super.setUp()
    
    output = UserNameLoginPresenterOutputSpy()
    
    presenter = UserNameLoginPresenter()
    presenter.output = output
  }
  
  func testShowUserName() {
    
  }
}
private class UserNameLoginPresenterOutputSpy: UserNameLoginPresenterOutput {
  var userNameSpy: String?
  var passwordSpy: String?
  
  func showUserName(_ userName: String) {
    userNameSpy = userName
  }
  
  func showPassword(_ password: String) {
    passwordSpy = password
  }
  
  func showLogInIsEnabled(_ isEnabled: Bool) {
  }
  
  func showActivityMessage(_ message: String) {
  }
  
  func showErrorMessage(_ message: String) {
  }
}
