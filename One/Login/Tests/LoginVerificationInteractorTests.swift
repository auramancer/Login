import XCTest

class LoginVerificationInteractorTests: XCTestCase {
  private var interactor: LoginVerificationInteractor!
  private var output: LoginVerificationInteractorOutputSpy!
  private var service: CardNumberLoginServiceSpy!
  private var storage: CardNumberLoginStorageSpy!
  
  private let validCardNumber = "12345678"
  private let validPIN = "1234"
  private let validCode = "123456"
  private let validToken = "1QAZ"
  private let error = "Cannot log in."
  private var details: CardNumberLoginDetails {
    return CardNumberLoginDetails(cardNumber: validCardNumber, pin: validPIN)
  }
  
  override func setUp() {
    super.setUp()
    
    output = LoginVerificationInteractorOutputSpy()
    service = CardNumberLoginServiceSpy()
    storage = CardNumberLoginStorageSpy()
    
    interactor = LoginVerificationInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
  }
  
  func testReset() {
    interactor.reset(withDetails: details, shouldRememberCardNumber: true)
    
    XCTAssertEqual(output.canVerifySpy, false)
  }
  
  func testChangeCodeWithNoDetails() {
    interactor.changeCode(to: validCode)
    
    XCTAssertEqual(output.canVerifySpy, false)
  }
  
  func testChangeCode() {
    interactor.reset(withDetails: details, shouldRememberCardNumber: true)
    
    interactor.changeCode(to: validCode)
    
    XCTAssertEqual(output.canVerifySpy, true)
  }
  
  func testResendCodeWithNoDetails() {
    interactor.resendCode()
    
    XCTAssertNil(service.detailsSpy)
    XCTAssertEqual(output.verificationDidBeginSpy, false)
  }
  
  func testResendCode() {
    interactor.reset(withDetails: details, shouldRememberCardNumber: true)
    
    interactor.resendCode()
    
    let detailsSpy = service.detailsSpy
    XCTAssertEqual(detailsSpy?.cardNumber, validCardNumber)
    XCTAssertEqual(detailsSpy?.pin, validPIN)
    XCTAssertEqual(detailsSpy?.verificationCode, nil)
    XCTAssertEqual(detailsSpy?.authenticationToken, nil)
  }
  
  func testVerifyWithNoDetails() {
    interactor.verify()
    
    XCTAssertNil(service.detailsSpy)
    XCTAssertEqual(output.verificationDidBeginSpy, false)
  }
  
  func testVerifyWithNoCode() {
    interactor.reset(withDetails: details, shouldRememberCardNumber: true)
    
    interactor.verify()
    
    XCTAssertNil(service.detailsSpy)
    XCTAssertEqual(output.verificationDidBeginSpy, false)
  }
  
  func testVerify() {
    interactor.reset(withDetails: details, shouldRememberCardNumber: true)
    interactor.changeCode(to: validCode)
    
    interactor.verify()
    
    let detailsSpy = service.detailsSpy
    XCTAssertEqual(detailsSpy?.cardNumber, validCardNumber)
    XCTAssertEqual(detailsSpy?.pin, validPIN)
    XCTAssertEqual(detailsSpy?.verificationCode, validCode)
    XCTAssertEqual(detailsSpy?.authenticationToken, nil)
    XCTAssertEqual(output.canVerifySpy, false)
    XCTAssertEqual(output.verificationDidBeginSpy, true)
  }
  
  func testHandleVerifySuccessAndRemember() {
    interactor.reset(withDetails: details, shouldRememberCardNumber: true)
    interactor.changeCode(to: validCode)
    interactor.verify()
    
    interactor.loginDidSucceed(withToken: validToken)
    
    XCTAssertEqual(output.canVerifySpy, false)
    XCTAssertEqual(output.verificationDidEndSpy, true)
    XCTAssertNil(output.errorsSpy)
    XCTAssertEqual(storage.cardNumberSpy, validCardNumber)
  }
  
  func testHandleVerifySuccessAndNotRemember() {
    interactor.reset(withDetails: details, shouldRememberCardNumber: false)
    interactor.changeCode(to: validCode)
    interactor.verify()
    
    interactor.loginDidSucceed(withToken: validToken)
    
    XCTAssertEqual(output.canVerifySpy, false)
    XCTAssertEqual(output.verificationDidEndSpy, true)
    XCTAssertNil(output.errorsSpy)
    XCTAssertEqual(storage.cardNumberSpy, nil)
  }
  
  func testHandleVerifyFailure() {
    interactor.reset(withDetails: details, shouldRememberCardNumber: true)
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
