import XCTest

class LoginInteractorTests: XCTestCase {
  private var interactor: LoginInteractorSpy!
  private var output: LoginInteractorOutputSpy!
  
  private let validId = "name"
  private let validSecret = "1234"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = LoginInteractorOutputSpy()
    
    interactor = LoginInteractorSpy()
    interactor.output = output
  }
  
  func testInitializeOutput() {
    assertWasDisabled(is: true)
  }
  
  private func assertWasEnabled(is expected: Bool) {
    XCTAssertEqual(output.loginWasEnabledSpy, expected)
  }
  
  private func assertWasDisabled(is expected: Bool) {
    XCTAssertEqual(output.loginWasDisabledSpy, expected)
  }
  
  func testUpdateId() {
    output.loginWasDisabledSpy = false
    
    interactor.updateId(validId)

    assertWasDisabled(is: true)
    assertWasEnabled(is: false)
  }
  
  func testUpdateIdWithSameValue() {
    interactor.updateId(validId)
    output.loginWasDisabledSpy = false
    
    interactor.updateId(validId)
    
    assertWasDisabled(is: false)
    assertWasEnabled(is: false)
  }
  
  func testUpdateIdWithDifferentValue() {
    interactor.updateId(validId)
    output.loginWasDisabledSpy = false
    
    interactor.updateId(validId + "a")
    
    assertWasDisabled(is: true)
    assertWasEnabled(is: false)
  }
  
  func testUpdateSecret() {
    output.loginWasDisabledSpy = false
    
    interactor.updateSecret(validSecret)
  
    assertWasDisabled(is: true)
    assertWasEnabled(is: false)
  }
  
  func testUpdateSecretWithSameValue() {
    interactor.updateSecret(validSecret)
    output.loginWasDisabledSpy = false
    
    interactor.updateSecret(validSecret)
    
    assertWasDisabled(is: false)
    assertWasEnabled(is: false)
  }
  
  func testUpdateSecretWithDifferentValue() {
    interactor.updateSecret(validSecret)
    output.loginWasDisabledSpy = false
    
    interactor.updateSecret(validSecret + "a")
    
    assertWasDisabled(is: true)
    assertWasEnabled(is: false)
  }
  
  func testUpdateIdThenSecret() {
    interactor.updateId(validId)
    output.loginWasEnabledSpy = false
    
    interactor.updateSecret(validSecret)
    
    assertWasEnabled(is: true)
  }
  
  func testUpdateSecretThenId() {
    interactor.updateSecret(validSecret)
    output.loginWasEnabledSpy = false
    
    interactor.updateId(validId)
    
    assertWasEnabled(is: true)
  }
  
  func testUpdateBothThenRemoveId() {
    interactor.updateId(validId)
    interactor.updateSecret(validSecret)
    output.loginWasDisabledSpy = false
    
    interactor.updateId("")
    
    assertWasDisabled(is: true)
  }
  
  func testUpdateBothThenRemoveSecret() {
    interactor.updateId(validId)
    interactor.updateSecret(validSecret)
    output.loginWasDisabledSpy = false
    
    interactor.updateSecret("")
    
    assertWasDisabled(is: true)
  }
  
  func testLogIn() {
    interactor.logIn()
    
    XCTAssertEqual(interactor.didInvokeService, true)
  }

  func testDidLogIn() {
    logIn()

    interactor.didLogIn()

    XCTAssertEqual(output.loginDidEndSpy, true)
  }
  
  func testDidFailToLogIn() {
    logIn()
    
    interactor.didFailToLogIn(dueTo: [error])
    
    XCTAssertEqual(output.loginDidFailErrorsSpy ?? [], [error])
  }
  
  private func logIn() {
    interactor.updateId("name")
    interactor.updateSecret("1234")
    interactor.logIn()
  }
}

private class LoginInteractorSpy: AbstractLoginInteractor {
  var didInvokeService = false
  
  override func invokeService() {
    didInvokeService = true
  }
}

class LoginInteractorOutputSpy: LoginInteractorOutput {
  var loginWasEnabledSpy = false
  var loginWasDisabledSpy = false
  var loginDidBeginSpy = false
  var loginDidEndSpy = false
  var loginDidFailErrorsSpy: [LoginError]?
  var destinationSpy: LoginDestination?

  func loginWasEnabled() {
    loginWasEnabledSpy = true
  }
  
  func loginWasDisabled() {
    loginWasDisabledSpy = true
  }
  
  func loginDidBegin() {
    loginDidBeginSpy = true
  }
  
  func loginDidEnd() {
    loginDidEndSpy = true
  }
  
  func loginDidFail(dueTo errors: [LoginError]) {
    loginDidFailErrorsSpy = errors
  }
  
  func navigate(to destination: LoginDestination) {
    destinationSpy = destination
  }
}
