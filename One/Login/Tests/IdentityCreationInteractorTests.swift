import XCTest

class IdentityCreationInteractorTests: XCTestCase {
  private var interactor: IdentityCreationInteractor!
  private var output: IdentityCreationInteractorOutputSpy!
  private var service: IdentityCreationServiceSpy!
  
  private let request = IdentityCreationRequest(membershipNumber: "", verificationCode: "")
  private let validUsername = "username"
  private let validUsername2 = "username0"
  private let shortUsername = "user"
  private let nonAlphanumericUsername = "user_name"
  private let validPassword = "password"
  private let validPassword2 = "password0"
  private let shortPassword = "pass"
  private let nonAlphanumericPassword = "pass_word"
  private let error = IdentityCreationErrorMock(message: "Username taken")
  
  override func setUp() {
    super.setUp()
    
    output = IdentityCreationInteractorOutputSpy()
    service = IdentityCreationServiceSpy()
    
    interactor = IdentityCreationInteractor()
    interactor.output = output
    interactor.service = service
  }
  
  func testLoad() {
    interactor.load(withRequest: request)
    
    XCTAssertEqual(output.didLoadSpy, true)
  }
  
  func testChangeUsernameOnly() {
    interactor.load(withRequest: request)
    output.reset()
    
    interactor.changeUsername(to: validUsername)
    
    XCTAssertEqual(output.canCreateSpy, nil)
  }
  
  func testChangePasswordOnly() {
    interactor.load(withRequest: request)
    output.reset()
    
    interactor.changePassword(to: validPassword)
    
    XCTAssertEqual(output.canCreateSpy, nil)
  }
  
  func testChangeUsername() {
    assertOutputReceived(canCreate: nil, whenChangeUsername: "", to: validUsername, passwordRemains: "")
    assertOutputReceived(canCreate: true, whenChangeUsername: "", to: validUsername, passwordRemains: validPassword)
    assertOutputReceived(canCreate: nil, whenChangeUsername: validUsername, to: validUsername2, passwordRemains: validPassword)
    assertOutputReceived(canCreate: false, whenChangeUsername: validUsername, to: shortUsername, passwordRemains: validPassword)
    assertOutputReceived(canCreate: false, whenChangeUsername: validUsername, to: nonAlphanumericUsername, passwordRemains: validPassword)
  }
  
  func testChangePassword() {
    assertOutputReceived(canCreate: nil, whenChangePassword: "", to: validPassword, usernameRemains: "")
    assertOutputReceived(canCreate: true, whenChangePassword: "", to: validPassword, usernameRemains: validUsername)
    assertOutputReceived(canCreate: nil, whenChangePassword: validPassword, to: validPassword2, usernameRemains: validUsername)
    assertOutputReceived(canCreate: false, whenChangePassword: validPassword, to: shortPassword, usernameRemains: validUsername)
    assertOutputReceived(canCreate: false, whenChangePassword: validPassword, to: nonAlphanumericPassword, usernameRemains: validUsername)
  }
  
  func testCreate() {
    set(username: validUsername, password: validPassword)
    output.reset()
    
    interactor.create()
    
    assertOutputReceived(creationDidBegin: true,
                         creationDidEnd: false,
                         errors: nil)
    assertServiceReceived(IdentityCreationRequest(membershipNumber: "",
                                                  verificationCode: "",
                                                  username: validUsername,
                                                  password: validPassword))
  }
  
  func testCreationDidSucceed() {
    create()
    output.reset()
    
    interactor.creationDidSucceed()
    
    assertOutputReceived(creationDidBegin: false,
                         creationDidEnd: true,
                         errors: nil)
  }
  
  func testCreationDidFail() {
    create()
    output.reset()
    
    interactor.creationDidFail(dueTo: [error])
    
    assertOutputReceived(creationDidBegin: false,
                         creationDidEnd: false,
                         errors: [error])
  }
  
  // Mark: helpers
  
  private func set(username: String, password: String) {
    interactor.load(withRequest: request)
    interactor.changeUsername(to: username)
    interactor.changePassword(to: password)
  }
  
  private func create() {
    set(username: validUsername, password: validPassword)
    interactor.create()
  }
  
  private func assertOutputReceived(canCreate: Bool?,
                                    whenChangeUsername oldUsername: String,
                                    to newUsername: String,
                                    passwordRemains password: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    set(username: oldUsername, password: password)
    output.reset()
    
    interactor.changeUsername(to: newUsername)
    
    XCTAssertEqual(output.canCreateSpy, canCreate, "canCreate", file: file, line: line)
  }
  
  private func assertOutputReceived(canCreate: Bool?,
                                    whenChangePassword oldPassword: String,
                                    to newPassword: String,
                                    usernameRemains username: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    set(username: username, password: oldPassword)
    output.reset()
    
    interactor.changePassword(to: newPassword)
    
    XCTAssertEqual(output.canCreateSpy, canCreate, "canCreate", file: file, line: line)
  }
  
  private func assertOutputReceived(creationDidBegin: Bool?,
                                    creationDidEnd: Bool?,
                                    errors: [IdentityCreationError]?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.creationDidBeginSpy, creationDidBegin, "creationDidBegin", file: file, line: line)
    XCTAssertEqual(output.creationDidEndSpy, creationDidEnd, "creationDidEnd", file: file, line: line)
    assertOutputReceived(errors: errors, file: file, line: line)
  }
  
  private func assertOutputReceived(errors: [IdentityCreationError]?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    let messages = output.errorsSpy?.map { $0.message }
    let expected = errors?.map { $0.message }
    
    XCTAssertEqual(messages, expected, "errors", file: file, line: line)
  }
  
  private func assertServiceReceived(_ request: IdentityCreationRequest?,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertEqual(service.requestSpy, request, "request", file: file, line: line)
  }
}

class IdentityCreationInteractorOutputSpy: IdentityCreationInteractorOutput {
  var didLoadSpy = false
  var canCreateSpy: Bool?
  var creationDidBeginSpy = false
  var creationDidEndSpy = false
  var errorsSpy: [IdentityCreationError]?
  
  func reset() {
    didLoadSpy = false
    canCreateSpy = nil
    creationDidBeginSpy = false
    creationDidEndSpy = false
    errorsSpy = nil
  }
  
  func didLoad() {
    didLoadSpy = true
  }
  
  func canCreateDidChange(to canCreate: Bool) {
    canCreateSpy = canCreate
  }
  
  func creationDidBegin() {
    creationDidBeginSpy = true
  }
  
  func creationDidEnd() {
    creationDidEndSpy = true
  }
  
  func creationDidFail(withErrors errors: [IdentityCreationError]) {
    errorsSpy = errors
  }
}

class IdentityCreationServiceSpy: IdentityCreationServiceInput {
  var requestSpy: IdentityCreationRequest?
  
  func create(withRequest request: IdentityCreationRequest) {
    requestSpy = request
  }
}

struct IdentityCreationErrorMock: IdentityCreationError {
  var message: String
}

extension IdentityCreationRequest: Equatable {
  static func ==(lhs: IdentityCreationRequest, rhs: IdentityCreationRequest) -> Bool {
    return lhs.membershipNumber == rhs.membershipNumber &&
     lhs.verificationCode == rhs.verificationCode &&
     lhs.username == rhs.username &&
     lhs.password == rhs.password
  }
}
