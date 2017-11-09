import XCTest
@testable import FFKit

class DualModeLoginInteractorTests: XCTestCase {
  private var interactor: DualModeLoginInteractor!
  private var output: DualModeLoginInteractorOutputSpy!
  private var subInteractor: LoginInteractorInputSpy!
  
  override func setUp() {
    super.setUp()
    
    output = DualModeLoginInteractorOutputSpy()
    subInteractor = LoginInteractorInputSpy()
    
    interactor = DualModeLoginInteractor()
    interactor.output = output
  }
  
  func testUpdateDetails() {
    assertModeOutputIs(.undetermined, whenSetIdTo: "1")
    assertModeOutputIs(.undetermined, whenSetIdTo: "12345")
    assertModeOutputIs(.membershipNumber, whenSetIdTo: "123456")
    assertModeOutputIs(.membershipNumber, whenSetIdTo: "123456a")
    assertModeOutputIs(.membershipNumber, whenSetIdTo: "1234567")
    assertModeOutputIs(.username, whenSetIdTo: "a")
  }
  
  private func assertModeOutputIs(_ expected: LoginMode?,
                                  whenSetIdTo id: String,
                                  file: StaticString = #file,
                                  line: UInt = #line) {
    interactor.mode = nil
    output.modeSpy = nil
    
    interactor.updateDetail(LoginDetails(id: id, secret: ""))
    
    XCTAssertEqual(output.modeSpy, expected, "", file: file, line: line)
  }
  
  func testLogin() {
    interactor.subInteractor = subInteractor
    
    interactor.logIn()
    
    XCTAssertTrue(subInteractor.didLogIn)
  }
}

private class DualModeLoginInteractorOutputSpy: LoginInteractorOutputSpy, DualModeLoginInteractorOutput {
  var modeSpy: LoginMode?

  func updateMode(_ mode: LoginMode) {
    modeSpy = mode
  }
}

private class LoginInteractorInputSpy: LoginInteractor {
  var didLogIn = false

  override func logIn() {
    didLogIn = true
  }
}
