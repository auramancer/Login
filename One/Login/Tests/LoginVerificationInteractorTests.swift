import XCTest

class LoginVerificationInteractorTests: XCTestCase {
  private var interactor: LoginVerificationInteractor!
  private var output: LoginVerificationInteractorOutputSpy!
  private var service: RetailLoginServiceSpy!
  private var storage: RetailLoginStorageSpy!
  
  private let validCardNumber = "12345678"
  private let validPIN = "1234"
  private let validCode = "123456"
  private let validToken = "1QAZ"
  private let error = "Cannot log in."
  private var request: RetailLoginRequest {
    return RetailLoginRequest(cardNumber: validCardNumber, pin: validPIN)
  }
  
  override func setUp() {
    super.setUp()
    
    output = LoginVerificationInteractorOutputSpy()
    service = RetailLoginServiceSpy()
    storage = RetailLoginStorageSpy()
    
    interactor = LoginVerificationInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
  }
  
  func testReset() {
    interactor.reset(withRequest: request, shouldRememberCardNumber: true)
    
    XCTAssertEqual(output.canVerifySpy, false)
  }
  
  func testChangeCodeWithNoRequest() {
    interactor.changeCode(to: validCode)
    
    XCTAssertEqual(output.canVerifySpy, false)
  }
  
  func testChangeCode() {
    interactor.reset(withRequest: request, shouldRememberCardNumber: true)
    
    interactor.changeCode(to: validCode)
    
    XCTAssertEqual(output.canVerifySpy, true)
  }
  
  func testResendCodeWithNoRequest() {
    interactor.resendCode()
    
    XCTAssertNil(service.requestSpy)
    XCTAssertEqual(output.verificationDidBeginSpy, false)
  }
  
  func testResendCode() {
    interactor.reset(withRequest: request, shouldRememberCardNumber: true)
    
    interactor.resendCode()
    
    let requestSpy = service.requestSpy
    XCTAssertEqual(requestSpy?.cardNumber, validCardNumber)
    XCTAssertEqual(requestSpy?.pin, validPIN)
    XCTAssertEqual(requestSpy?.verificationCode, nil)
    XCTAssertEqual(requestSpy?.authenticationToken, nil)
  }
  
  func testVerifyWithNoRequest() {
    interactor.verify()
    
    XCTAssertNil(service.requestSpy)
    XCTAssertEqual(output.verificationDidBeginSpy, false)
  }
  
  func testVerifyWithNoCode() {
    interactor.reset(withRequest: request, shouldRememberCardNumber: true)
    
    interactor.verify()
    
    XCTAssertNil(service.requestSpy)
    XCTAssertEqual(output.verificationDidBeginSpy, false)
  }
  
  func testVerify() {
    interactor.reset(withRequest: request, shouldRememberCardNumber: true)
    interactor.changeCode(to: validCode)
    
    interactor.verify()
    
    let requestSpy = service.requestSpy
    XCTAssertEqual(requestSpy?.cardNumber, validCardNumber)
    XCTAssertEqual(requestSpy?.pin, validPIN)
    XCTAssertEqual(requestSpy?.verificationCode, validCode)
    XCTAssertEqual(requestSpy?.authenticationToken, nil)
    XCTAssertEqual(output.canVerifySpy, false)
    XCTAssertEqual(output.verificationDidBeginSpy, true)
  }
  
  func testHandleVerifySuccessAndRemember() {
    interactor.reset(withRequest: request, shouldRememberCardNumber: true)
    interactor.changeCode(to: validCode)
    interactor.verify()
    
    interactor.loginDidSucceed(withToken: validToken)
    
    XCTAssertEqual(output.canVerifySpy, false)
    XCTAssertEqual(output.verificationDidEndSpy, true)
    XCTAssertNil(output.errorsSpy)
    XCTAssertEqual(storage.cardNumberSpy, validCardNumber)
  }
  
  func testHandleVerifySuccessAndNotRemember() {
    interactor.reset(withRequest: request, shouldRememberCardNumber: false)
    interactor.changeCode(to: validCode)
    interactor.verify()
    
    interactor.loginDidSucceed(withToken: validToken)
    
    XCTAssertEqual(output.canVerifySpy, false)
    XCTAssertEqual(output.verificationDidEndSpy, true)
    XCTAssertNil(output.errorsSpy)
    XCTAssertEqual(storage.cardNumberSpy, nil)
  }
  
  func testHandleVerifyFailure() {
    interactor.reset(withRequest: request, shouldRememberCardNumber: true)
    interactor.changeCode(to: validCode)
    interactor.verify()
    
    interactor.loginDidFail(dueTo: [error])
    
    XCTAssertEqual(output.canVerifySpy, true)
    XCTAssertEqual(output.verificationDidEndSpy, false)
    XCTAssertEqual(output.errorsSpy!, [error])
    XCTAssertEqual(storage.cardNumberSpy, nil)
  }
}

class LoginVerificationInteractorOutputSpy: LoginVerificationInteractorOutput {
  var canVerifySpy: Bool?
  var verificationDidBeginSpy = false
  var verificationDidEndSpy = false
  var errorsSpy: [LoginError]?
  
  func canVerifyDidChange(to canVerify: Bool) {
    canVerifySpy = canVerify
  }
  
  func verificationDidBegin() {
    verificationDidBeginSpy = true
  }
  
  func verificationDidEnd() {
    verificationDidEndSpy = true
  }
  
  func verificationDidFail(dueTo errors: [LoginError]) {
    errorsSpy = errors
  }
}
