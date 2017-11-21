import XCTest

class LoginVerificationInteractorTests: XCTestCase {
  private var interactor: LoginVerificationInteractor!
  private var output: LoginVerificationInteractorOutputSpy!
  private var service: LoginVerificationServiceSpy!
  private var storage: RetailLoginStorageSpy!
  
  typealias Data = LoginTestData
  private let identity = Data.validRetailIdentity
  private let session = Data.session
  private let code = Data.validCode
  private let token = Data.validToken
  
  override func setUp() {
    super.setUp()
    
    output = LoginVerificationInteractorOutputSpy()
    service = LoginVerificationServiceSpy()
    storage = RetailLoginStorageSpy()
    
    interactor = LoginVerificationInteractor()
    interactor.output = output
    interactor.loginService = service
    interactor.codeService = service
    interactor.storage = storage
  }
  
  func testLoad() {
    load()
    
    assertOutputReceived(canVerify: false)
  }
  
  func testChangeCode() {
    load()
    output.reset()

    interactor.changeCode(to: code)

    assertOutputReceived(canVerify: true)
  }
  
  func testClearCode() {
    changeCode()
    output.reset()
    
    interactor.changeCode(to: "")
    
    assertOutputReceived(canVerify: false)
  }

  func testVerify() {
    changeCode()
    output.reset()

    interactor.verify()

    assertOutputReceived(canVerify: nil)
    assertOutputReceived(verificationDidBegin: true,
                         verificationDidEnd: false,
                         errors: nil)
    assertServiceReceived(loginRequest: Data.retailIdentityWithCode,
                          codeRequest: nil)
  }

  func testHandleSuccess() {
    verify()
    output.reset()

    interactor.loginDidSucceed(withSession: session, token: token, needToCreateDigitalIdentity: false)

    assertOutputReceived(verificationDidBegin: false,
                         verificationDidEnd: true,
                         errors: nil)
    assertStorageSaved(session: session,
                       token: token)
  }
  
  func testHandleSuccessThenCreateIdentity() {
    verify()
    output.reset()
    
    interactor.loginDidSucceed(withSession: session, token: token, needToCreateDigitalIdentity: true)
    
    assertOutputReceived(verificationDidBegin: false,
                         verificationDidEnd: false,
                         errors: nil)
    assertOutputGoesToIdentityCreation(with: Data.retailIdentityWithTokenAndCode)
    assertStorageSaved(session: session,
                       token: nil)
  }

  func testHandleFailure() {
    verify()
    output.reset()

    interactor.loginDidFail(dueTo: [Data.error])

    assertOutputReceived(verificationDidBegin: false,
                         verificationDidEnd: false,
                         errors: [Data.errorMessage])
    assertStorageSaved(session: nil,
                       token: nil)
  }
  
  func testResendCode() {
    load()
    output.reset()
    
    interactor.resendCode(confirmed: false)
    
    XCTAssertEqual(output.showResendConfirmationSpy, true)
  }
  
  func testResendCodeAfterConfirmation() {
    load()
    interactor.resendCode(confirmed: false)
    output.reset()
    
    interactor.resendCode(confirmed: true)
    
    XCTAssertEqual(output.showResendConfirmationSpy, false)
    XCTAssertEqual(service.codeIdentitySpy, identity)
  }
  
  // MARK: helpers
  
  private func load() {
    interactor.load(withIdentity: identity)
  }
  
  private func changeCode() {
    load()
    interactor.changeCode(to: code)
  }
  
  private func verify() {
    changeCode()
    interactor.verify()
  }
  
  private func assertOutputReceived(canVerify: Bool?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.canVerifySpy, canVerify, "canVerify", file: file, line: line)
  }
  
  private func assertOutputReceived(verificationDidBegin: Bool?,
                                    verificationDidEnd: Bool?,
                                    errors: [String]?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.verificationDidBeginSpy, verificationDidBegin, "verificationDidBegin", file: file, line: line)
    XCTAssertEqual(output.verificationDidEndSpy, verificationDidEnd, "verificationDidEnd", file: file, line: line)
    XCTAssertEqual(output.errorsSpy, errors, "errors", file: file, line: line)
  }
  
  private func assertOutputGoesToIdentityCreation(with identity: RetailIdentity) {
    XCTAssertEqual(output.identityCreationIdentitySpy, identity)
  }
  
  private func assertServiceReceived(loginRequest: RetailIdentity?,
                                     codeRequest: RetailIdentity?,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertEqual(service.loginIdentitySpy, loginRequest, "loginRequest", file: file, line: line)
    XCTAssertEqual(service.codeIdentitySpy, codeRequest, "codeRequest", file: file, line: line)
  }
  
  private func assertStorageSaved(session: String?,
                                  token: String?,
                                  file: StaticString = #file,
                                  line: UInt = #line) {
    XCTAssertEqual(storage.sessionSpy, session, "session", file: file, line: line)
    XCTAssertEqual(storage.tokenSpy, token, "token", file: file, line: line)
  }
}

class LoginVerificationInteractorOutputSpy: LoginVerificationInteractorOutput {
  var canVerifySpy: Bool?
  var verificationDidBeginSpy = false
  var verificationDidEndSpy = false
  var errorsSpy: [String]?
  var showResendConfirmationSpy = false
  var identityCreationIdentitySpy: RetailIdentity?
  
  func reset() {
    canVerifySpy = nil
    verificationDidBeginSpy = false
    verificationDidEndSpy = false
    errorsSpy = nil
    showResendConfirmationSpy = false
    identityCreationIdentitySpy = nil
  }
  
  func didLoad(canVerify: Bool) {
    canVerifySpy = canVerify
  }
  
  func canVerifyDidChange(to canVerify: Bool) {
    canVerifySpy = canVerify
  }
  
  func verificationDidBegin() {
    verificationDidBeginSpy = true
  }
  
  func verificationDidEnd() {
    verificationDidEndSpy = true
  }
  
  func verificationDidFail(dueTo errors: [String]) {
    errorsSpy = errors
  }
  
  func showResendConfirmation() {
    showResendConfirmationSpy = true
  }
  
  func showIdentityCreation(withIdentity identity: RetailIdentity) {
    identityCreationIdentitySpy = identity
  }
}

class LoginVerificationServiceSpy: RetailLoginServiceInput, VerificationCodeServiceInput {
  var loginIdentitySpy: RetailIdentity?
  var codeIdentitySpy: RetailIdentity?
  
  func logIn(withRetailIdentity identity: RetailIdentity) {
    loginIdentitySpy = identity
  }
  
  func resendCode(withRetailIdentity identity: RetailIdentity) {
    codeIdentitySpy = identity
  }
}
