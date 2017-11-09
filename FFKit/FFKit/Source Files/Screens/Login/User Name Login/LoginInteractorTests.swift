import XCTest
@testable import FFKit

class LoginInteractorTests: XCTestCase {
  private var interactor: LoginInteractor!
  private var output: LoginInteractorOutputSpy!
  private var service: LoginServiceSpy!
  
  private let validDetails = LoginDetails(id: "name", secret: "1234")
  private let invalidDetails = LoginDetails(id: "name", secret: "")
  private let error = LoginError.unrecognized
  
  override func setUp() {
    super.setUp()
    
    output = LoginInteractorOutputSpy()
    service = LoginServiceSpy()
    
    interactor = LoginInteractor()
    interactor.output = output
    interactor.service = service
  }
  
  func testUpdateWithValidDetails() {
    interactor.updateDetail(validDetails)
    
    XCTAssertEqual(output.stateSpy, .ready)
  }
  
  func testUpdateWithInvalidDetails() {
    interactor.updateDetail(invalidDetails)
    
    XCTAssertEqual(output.stateSpy, .notReady)
  }
  
  func testLogIn() {
    interactor.updateDetail(validDetails)
    
    interactor.logIn()

    XCTAssertEqual(output.stateSpy, .inProgress)
    XCTAssertEqual(service.detailsSpy, validDetails)
  }
  
  func testLogInWithNoDetails() {
    interactor.logIn()
    
    XCTAssertEqual(output.stateSpy, nil)
    XCTAssertNil(service.detailsSpy)
  }

  func testDidLogIn() {
    interactor.updateDetail(validDetails)
    interactor.logIn()

    interactor.didLogIn()

    XCTAssertEqual(output.stateSpy, .ready)
    XCTAssertEqual(output.resultSpy, .succeeded)
  }

  func testDidFailToLogIn() {
    interactor.updateDetail(validDetails)
    interactor.logIn()

    interactor.didFailToLogIn(dueTo: [error])

    XCTAssertEqual(output.stateSpy, .ready)
    XCTAssertEqual(output.resultSpy, .failed([error]))
  }
}

extension LoginDetails: Equatable {
  public static func ==(lhs: LoginDetails, rhs: LoginDetails) -> Bool {
    return lhs.id == rhs.id &&
      lhs.secret == rhs.secret
  }
}

class LoginInteractorOutputSpy: LoginInteractorOutput {
  var stateSpy: LoginState?
  var resultSpy: LoginResult?

  func updateState(_ state: LoginState) {
    stateSpy = state
  }
  
  func updateResult(_ result: LoginResult) {
    resultSpy = result
  }
}

extension LoginResult: Equatable {
  public static func ==(lhs: LoginResult, rhs: LoginResult) -> Bool {
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

class LoginServiceSpy: LoginServiceInput {
  var detailsSpy: LoginDetails?
  
  func logIn(withDetails details: LoginDetails) {
    detailsSpy = details
  }
}
