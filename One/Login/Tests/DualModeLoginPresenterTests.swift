import XCTest

class DualModeLoginPresenterTests: XCTestCase {
  private var presenter: DualModeLoginPresenter!
  private var output: DualModeLoginPresenterOutputSpy!
  
  private let validCardNumber = "12345678"
  private let validPIN = "1234"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = DualModeLoginPresenterOutputSpy()
    
    presenter = DualModeLoginPresenter()
    presenter.output = output
  }
}

class DualModeLoginPresenterOutputSpy: DualModeLoginPresenterOutput {
  func changeIsLoggingIn(to: Bool) {
    
  }
  
  func changeErrorMessage(to: String) {
    
  }
  
  func clearErrorMessage() {
    
  }
  
  func changeIdentifier(to: String) {
  }
  
  func changeCredential(to: String) {
  }
  
  func changeCanLogin(to: Bool) {
  }
  
  func changeWording(to: DualModeLoginWording) {
  }
  
  func showActivityMessage(_: String?) {
  }
  
  func hideActivityMessage() {
  }
  
  func showErrorMessage(_: String) {
  }
  
  func hideErrorMessage() {
  }
  
  func goToHelpPage(for: LoginHelp) {
  }
  
  func goToVerificationPage(withRequest: RetailLoginRequest) {
  }
  
  func leave() {
  }
}
