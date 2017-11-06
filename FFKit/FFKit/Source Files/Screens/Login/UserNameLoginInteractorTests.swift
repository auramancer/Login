import XCTest
@testable import FFKit

class UserNameLoginInteractorTests: XCTestCase {
  private var interactor: UserNameLoginInteractor!
  private var output: UserNameLoginInteractorOutputSpy!
  private var service: UserNameLoginServiceSpy!
  
  private let userName = "name"
  private let password = "1234"
  private let error = SimpleError(message: "Some error")
  
  override func setUp() {
    super.setUp()
    
    output = UserNameLoginInteractorOutputSpy()
    service = UserNameLoginServiceSpy()
    
    interactor = UserNameLoginInteractor()
    interactor.output = output
    interactor.service = service
  }
  
  func testRefresh() {
    interactor.refresh()
    
    XCTAssertEqual(output.userNameSpy, "")
    XCTAssertEqual(output.passwordSpy, "")
    XCTAssertEqual(output.canLogInSpy, false)
  }
  
  func testChangeUserName() {
    assertUserNameOutput(is: "n", whenAttemptToChangeItFrom: "", to: "n")
    assertUserNameOutput(is: "name", whenAttemptToChangeItFrom: "n", to: "name")
    assertUserNameOutput(is: "nam", whenAttemptToChangeItFrom: "name", to: "nam")
    assertUserNameOutput(is: nil, whenAttemptToChangeItFrom: "nam", to: "nam")
  }
  
  private func assertUserNameOutput(is expectedOne: String?,
                                    whenAttemptToChangeItFrom oldOne: String,
                                    to newOne: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    interactor.userName = oldOne
    output.userNameSpy = nil
  
    interactor.attempToChangeUserName(to: newOne)
    
    XCTAssertEqual(output.userNameSpy, expectedOne, "", file: file, line: line)
  }
  
  func testChangePassword() {
    assertPasswordOutput(is: "1", whenAttemptToChangeItFrom: "", to: "1")
    assertPasswordOutput(is: "1234", whenAttemptToChangeItFrom: "1", to: "1234")
    assertPasswordOutput(is: "123", whenAttemptToChangeItFrom: "1234", to: "123")
    assertPasswordOutput(is: nil, whenAttemptToChangeItFrom: "123", to: "123")
  }
  
  private func assertPasswordOutput(is expectedOne: String?,
                                    whenAttemptToChangeItFrom oldOne: String,
                                    to newOne: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    interactor.password = oldOne
    output.passwordSpy = nil
    
    interactor.attempToChangePassword(to: newOne)
    
    XCTAssertEqual(output.passwordSpy, expectedOne, "", file: file, line: line)
  }
  
  func testCanLogInChangedWithUserNameAndPassword() {
    assertCanLogInOutput(is: nil, whenChangeUserNameTo: "", passwordTo: "")
    assertCanLogInOutput(is: false, whenChangeUserNameTo: userName, passwordTo: "")
    assertCanLogInOutput(is: false, whenChangeUserNameTo: "", passwordTo: "1234")
    assertCanLogInOutput(is: true, whenChangeUserNameTo: userName, passwordTo: "1234")
  }
  
  private func assertCanLogInOutput(is expectedOne: Bool?,
                                    whenChangeUserNameTo userName: String,
                                    passwordTo password: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    interactor.userName = ""
    interactor.password = ""
    output.canLogInSpy = nil
    
    interactor.attempToChangeUserName(to: userName)
    interactor.attempToChangePassword(to: password)
    
    XCTAssertEqual(output.canLogInSpy, expectedOne, "", file: file, line: line)
  }
  
  func testLogIn() {
    logIn(withUserName: userName, password: password)
    
    XCTAssertEqual(output.isLogggingInSpy, true)
    XCTAssertEqual(service.userNameSpy, userName)
    XCTAssertEqual(service.passwordSpy, password)
  }
  
  func testLogInWithNoPassword() {
    logIn(withUserName: userName, password: "")
    
    XCTAssertEqual(output.isLogggingInSpy, nil)
    XCTAssertEqual(service.userNameSpy, nil)
  }
  
  private func logIn(withUserName userName: String, password: String) {
    interactor.userName = userName
    interactor.password = password
    
    interactor.logIn()
  }
  
  func testDidLogIn() {
    logIn(withUserName: userName, password: password)
    
    interactor.didLogIn()
    
    XCTAssertEqual(output.isLogggingInSpy, false)
    XCTAssertEqual(output.didLogInSpy, true)
  }
  
  func testDidFailToLogIn() {
    logIn(withUserName: userName, password: password)
    
    interactor.didFailToLogIn(dueTo: [error])
    
    XCTAssertEqual(output.isLogggingInSpy, false)
    XCTAssertEqual(output.errorsSpy as? [SimpleError] ?? [], [error])
  }
}

struct SimpleError: Error, Equatable {
  var message: String
  
  static func ==(lhs: SimpleError, rhs: SimpleError) -> Bool {
    return lhs.message == rhs.message
  }
}

private class UserNameLoginInteractorOutputSpy: UserNameLoginInteractorOutput {
  var userNameSpy: String?
  var passwordSpy: String?
  var canLogInSpy: Bool?
  var isLogggingInSpy: Bool?
  var didLogInSpy = false
  var errorsSpy: [Error]?
  
  func showUserName(_ userName: String) {
    userNameSpy = userName
  }
  
  func showPassword(_ password: String) {
    passwordSpy = password
  }
  
  func showCanLogIn(_ canLogIn: Bool) {
    canLogInSpy = canLogIn
  }
  
  func showIsLoggingIn(_ isLogggingIn: Bool) {
    isLogggingInSpy = isLogggingIn
  }
  
  func showDidLogIn() {
    didLogInSpy = true
  }
  
  func showDidFailToLogIn(dueTo errors: [Error]) {
    errorsSpy = errors
  }
}

private class UserNameLoginServiceSpy: UserNameLoginServiceInput {
  var userNameSpy: String?
  var passwordSpy: String?
  
  func logIn(withUserName userName: String, password: String) {
    userNameSpy = userName
    passwordSpy = password
  }
}
