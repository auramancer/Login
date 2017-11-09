import XCTest
@testable import FFKit

class UserNameLoginInteractorTests: XCTestCase {
  private var interactor: UserNameLoginInteractor!
  private var output: UserNameLoginInteractorOutputSpy!
  private var service: UserNameLoginServiceSpy!
  
  private let userName = "name"
  private let password = "1234"
  private let error = UserNameLoginError.unrecognized
  
  override func setUp() {
    super.setUp()
    
    output = UserNameLoginInteractorOutputSpy()
    service = UserNameLoginServiceSpy()
    
    interactor = UserNameLoginInteractor()
    interactor.output = output
    interactor.service = service
  }
  
  func testUpdateDetails() {
    assertState(is: .notReady, whenChangeUserNameTo: "", passwordTo: "")
    assertState(is: .notReady, whenChangeUserNameTo: userName, passwordTo: "")
    assertState(is: .notReady, whenChangeUserNameTo: "", passwordTo: "1234")
    assertState(is: .ready, whenChangeUserNameTo: userName, passwordTo: "1234")
  }

  private func assertState(is expected: UserNameLoginState,
                           whenChangeUserNameTo userName: String,
                           passwordTo password: String,
                           file: StaticString = #file,
                           line: UInt = #line) {
    interactor.details = nil
    output.stateSpy = nil

    interactor.updateDetail(UserNameLoginDetails(userName: userName, password: password))

    XCTAssertEqual(output.stateSpy, expected, "", file: file, line: line)
  }
  
  func testLogIn() {
    logIn(withUserName: userName, password: password)

    XCTAssertEqual(output.stateSpy, .inProgress)
    XCTAssertEqual(service.userNameSpy, userName)
    XCTAssertEqual(service.passwordSpy, password)
  }
  
  private func logIn(withUserName userName: String, password: String) {
    interactor.details = UserNameLoginDetails(userName: userName, password: password)
    
    interactor.logIn()
  }
  
  func testLogInWithNoDetails() {
    interactor.logIn()
    
    XCTAssertEqual(output.stateSpy, nil)
    XCTAssertEqual(service.userNameSpy, nil)
  }

  func testDidLogIn() {
    logIn(withUserName: userName, password: password)

    interactor.didLogIn()

    XCTAssertEqual(output.stateSpy, .ready)
    XCTAssertEqual(output.resultSpy, .succeeded)
  }

  func testDidFailToLogIn() {
    logIn(withUserName: userName, password: password)

    interactor.didFailToLogIn(dueTo: [error])

    XCTAssertEqual(output.stateSpy, .ready)
    XCTAssertEqual(output.resultSpy, .failed([error]))
  }
}

private class UserNameLoginInteractorOutputSpy: UserNameLoginInteractorOutput {
  var stateSpy: UserNameLoginState?
  var resultSpy: UserNameLoginResult?

  func updateState(_ state: UserNameLoginState) {
    stateSpy = state
  }
  
  func updateResult(_ result: UserNameLoginResult) {
    resultSpy = result
  }
}

extension UserNameLoginResult: Equatable {
  public static func ==(lhs: UserNameLoginResult, rhs: UserNameLoginResult) -> Bool {
    switch (lhs, rhs) {
    case let (.failed(errors1), .failed(errors2)):
      return errors1 == errors2
    case (.succeeded, .succeeded):
      return true
    default:
      return false
    }
  }
}

private class UserNameLoginServiceSpy: UserNameLoginServiceInput {
  var userNameSpy: String?
  var passwordSpy: String?
  
  func logIn(withDetails details: UserNameLoginDetails) {
    userNameSpy = details.userName
    passwordSpy = details.password
  }
}
