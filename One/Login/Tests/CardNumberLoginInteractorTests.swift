import XCTest

class CardNumberLoginInteractorTests: XCTestCase {
  private var interactor: CardNumberLoginInteractor!
  private var output: CardNumberLoginInteractorOutputSpy!
  private var service: CardNumberLoginServiceSpy!
  private var storage: CardNumberLoginStorageSpy!
  
  private let validCardNumber = "12345678"
  private let validPIN = "1234"
  private let validToken = "1QAZ2WSX"

  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = CardNumberLoginInteractorOutputSpy()
    service = CardNumberLoginServiceSpy()
    storage = CardNumberLoginStorageSpy()
    
    interactor = CardNumberLoginInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
  }
  
  func testResetWithNoRememberedCardNumber() {
    interactor.reset()
    
    XCTAssertEqual(output.cardNumberSpy, "")
    XCTAssertEqual(output.pinSpy, "")
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testResetWithRememberedCardNumber() {
    storage.cardNumberSpy = validCardNumber
    
    interactor.reset()
    
    XCTAssertEqual(output.cardNumberSpy, validCardNumber)
    XCTAssertEqual(output.pinSpy, "")
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testChangeCardNumber() {
    interactor.changeCardNumber(to: validCardNumber)
    
    XCTAssertEqual(output.cardNumberSpy, validCardNumber)
    XCTAssertEqual(output.pinSpy, nil)
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testChangeCardNumberToSameValue() {
    interactor.changeCardNumber(to: validCardNumber)
    output.cardNumberSpy = nil
    output.canLoginSpy = nil
    
    interactor.changeCardNumber(to: validCardNumber)
    
    XCTAssertEqual(output.cardNumberSpy, nil)
    XCTAssertEqual(output.pinSpy, nil)
    XCTAssertEqual(output.canLoginSpy, nil)
  }
  
  func testClearCardNumber() {
    interactor.changeCardNumber(to: validCardNumber)
    output.cardNumberSpy = nil
    output.canLoginSpy = nil
    
    interactor.changeCardNumber(to: "")
    
    XCTAssertEqual(output.cardNumberSpy, "")
    XCTAssertEqual(output.pinSpy, nil)
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testChangePIN() {
    interactor.changePIN(to: validPIN)
    
    XCTAssertEqual(output.cardNumberSpy, nil)
    XCTAssertEqual(output.pinSpy, validPIN)
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testChangePINToSameValue() {
    interactor.changePIN(to: validPIN)
    output.pinSpy = nil
    output.canLoginSpy = nil
    
    interactor.changePIN(to: validPIN)
    
    XCTAssertEqual(output.cardNumberSpy, nil)
    XCTAssertEqual(output.pinSpy, nil)
    XCTAssertEqual(output.canLoginSpy, nil)
  }
  
  func testClearPIN() {
    interactor.changePIN(to: validPIN)
    output.pinSpy = nil
    output.canLoginSpy = nil
    
    interactor.changePIN(to: "")
    
    XCTAssertEqual(output.cardNumberSpy, nil)
    XCTAssertEqual(output.pinSpy, "")
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testChangePINWhenCardNumberIsValid() {
    interactor.changeCardNumber(to: validCardNumber)
    
    interactor.changePIN(to: validPIN)
    
    XCTAssertEqual(output.cardNumberSpy, validCardNumber)
    XCTAssertEqual(output.pinSpy, validPIN)
    XCTAssertEqual(output.canLoginSpy, true)
  }
  
  func testChangeCardNumberWhenPINIsValid() {
    interactor.changePIN(to: validPIN)
    
    interactor.changeCardNumber(to: validCardNumber)
    
    XCTAssertEqual(output.cardNumberSpy, validCardNumber)
    XCTAssertEqual(output.pinSpy, validPIN)
    XCTAssertEqual(output.canLoginSpy, true)
  }
  
  func testClearCardNumberWhenBothAreValid() {
    interactor.changeCardNumber(to: validCardNumber)
    interactor.changePIN(to: validPIN)
    
    interactor.changeCardNumber(to: "")
    
    XCTAssertEqual(output.cardNumberSpy, "")
    XCTAssertEqual(output.pinSpy, validPIN)
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testClearPINWhenBothAreValid() {
    interactor.changeCardNumber(to: validCardNumber)
    interactor.changePIN(to: validPIN)
    
    interactor.changePIN(to: "")
    
    XCTAssertEqual(output.cardNumberSpy, validCardNumber)
    XCTAssertEqual(output.pinSpy, "")
    XCTAssertEqual(output.canLoginSpy, false)
  }
  
  func testLogInWithNoDetails() {
    interactor.logIn(shouldRememberCardNumber: false)
    
    XCTAssertEqual(output.canLoginSpy, nil)
    XCTAssertEqual(output.loginDidBeginSpy, false)
    XCTAssertNil(service.detailsSpy)
  }
  
  func testLogin() {
    interactor.changeCardNumber(to: validCardNumber)
    interactor.changePIN(to: validPIN)
    
    interactor.logIn(shouldRememberCardNumber: false)
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.loginDidBeginSpy, true)
  }
  
  func testHandleLoginSuccessAndRemember() {
    interactor.changeCardNumber(to: validCardNumber)
    interactor.changePIN(to: validPIN)
    interactor.logIn(shouldRememberCardNumber: true)
    
    interactor.loginDidSucceed()
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.loginDidEndSpy, true)
    XCTAssertNil(output.errorsSpy)
    XCTAssertEqual(output.inquireVerificationCodeSpy, false)
    XCTAssertEqual(storage.cardNumberSpy, validCardNumber)
  }
  
  func testHandleLoginSuccessAndNotRemember() {
    interactor.changeCardNumber(to: validCardNumber)
    interactor.changePIN(to: validPIN)
    interactor.logIn(shouldRememberCardNumber: false)
    
    interactor.loginDidSucceed()
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.loginDidEndSpy, true)
    XCTAssertNil(output.errorsSpy)
    XCTAssertEqual(output.inquireVerificationCodeSpy, false)
    XCTAssertEqual(storage.cardNumberSpy, nil)
  }
  
  func testHandleLoginFailure() {
    interactor.changeCardNumber(to: validCardNumber)
    interactor.changePIN(to: validPIN)
    interactor.logIn(shouldRememberCardNumber: true)
    
    interactor.loginDidFail(dueTo: [error])
    
    XCTAssertEqual(output.canLoginSpy, true)
    XCTAssertEqual(output.loginDidEndSpy, false)
    XCTAssertEqual(output.errorsSpy!, [error])
    XCTAssertEqual(output.inquireVerificationCodeSpy, false)
    XCTAssertEqual(storage.cardNumberSpy, nil)
  }
  
  func testHandleExpiredToken() {
    interactor.changeCardNumber(to: validCardNumber)
    interactor.changePIN(to: validPIN)
    interactor.logIn(shouldRememberCardNumber: true)
    
    interactor.loginDidFailDueToExpiredToken()
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.loginDidEndSpy, false)
    XCTAssertNil(output.errorsSpy)
    XCTAssertEqual(output.inquireVerificationCodeSpy, true)
    XCTAssertEqual(storage.cardNumberSpy, nil)
  }
  
  func testHelpWithCardNumber() {
    interactor.helpWithCardNumber()
    
    XCTAssertEqual(output.helpSpy, LoginHelp.cardNumber)
  }
  
  func testHelpWithPIN() {
    interactor.helpWithPIN()
    
    XCTAssertEqual(output.helpSpy, LoginHelp.pin)
  }
}

class CardNumberLoginInteractorOutputSpy: CardNumberLoginInteractorOutput {
  var cardNumberSpy: String?
  var pinSpy: String?
  var canLoginSpy: Bool?
  var loginDidBeginSpy = false
  var loginDidEndSpy = false
  var errorsSpy: [LoginError]?
  var helpSpy: LoginHelp?
  var inquireVerificationCodeSpy = false
  
  func cardNumberDidChange(to cardNumber: String) {
    cardNumberSpy = cardNumber
  }
  
  func pinDidChange(to pin: String) {
    pinSpy = pin
  }
  
  func canLoginDidChange(to canLogin: Bool) {
    canLoginSpy = canLogin
  }
  
  func loginDidBegin() {
    loginDidBeginSpy = true
  }
  
  func loginDidEnd() {
    loginDidEndSpy = true
  }
  
  func loginDidFail(withErrors errors: [LoginError]) {
    errorsSpy = errors
  }
  
  func showHelp(_ help: LoginHelp) {
    helpSpy = help
  }
  
  func inquireVerificationCode(forDetails details: CardNumberLoginDetails) {
    inquireVerificationCodeSpy = true
  }
}

class CardNumberLoginServiceSpy: CardNumberLoginServiceInput {
  var detailsSpy: CardNumberLoginDetails?
  
  func logIn(withCardNumberDetails details: CardNumberLoginDetails) {
    detailsSpy = details
  }
}

class CardNumberLoginStorageSpy: CardNumberLoginStorage {
  var cardNumberSpy: String?
  var tokenSpy: String?
  
  func saveCardNumber(_ cardNumber: String) {
    cardNumberSpy = cardNumber
  }
  
  func loadCardNumber() -> String? {
    return cardNumberSpy
  }
  
  func saveToken(_ token: String) {
    tokenSpy = token
  }
  
  func loadToken() -> String? {
    return tokenSpy
  }
  
  func removeToken() {
    tokenSpy = nil
  }
}

