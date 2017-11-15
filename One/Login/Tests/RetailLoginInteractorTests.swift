import XCTest

class RetailLoginInteractorTests: XCTestCase {
  private var interactor: RetailLoginInteractor!
  private var output: RetailLoginInteractorOutputSpy!
  private var service: RetailLoginServiceSpy!
  private var storage: RetailLoginStorageSpy!
  
  private let validCardNumber = "12345678"
  private let validPIN = "1234"
  private let validToken = "1QAZ2WSX"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = RetailLoginInteractorOutputSpy()
    service = RetailLoginServiceSpy()
    storage = RetailLoginStorageSpy()
    
    interactor = RetailLoginInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
  }
  
  func testInitializeWithNoRememberedCardNumber() {
    interactor.initialize()
    
    assertOutputReceived(cardNumber: "",
                         pin: "",
                         canLogin: false)
  }
  
  func testInitializeWithRememberedCardNumber() {
    storage.cardNumberSpy = validCardNumber
    
    interactor.initialize()
    
    assertOutputReceived(cardNumber: validCardNumber,
                         pin: "",
                         canLogin: false)
  }
  
  func testChangeCardNumber() {
    assertOutputReceived(cardNumber: validCardNumber, canLogin: false, whenChangeCardNumber: "", to: validCardNumber, pinRemains: "")
    assertOutputReceived(cardNumber: validCardNumber, canLogin: true, whenChangeCardNumber: "", to: validCardNumber, pinRemains: validPIN)
    assertOutputReceived(cardNumber: nil, canLogin: nil, whenChangeCardNumber: validCardNumber, to: validCardNumber, pinRemains: "")
    assertOutputReceived(cardNumber: "", canLogin: false, whenChangeCardNumber: validCardNumber, to: "", pinRemains: "")
  }
  
  func testChangePIN() {
    assertOutputReceived(pin: validPIN, canLogin: false, whenChangePIN: "", to: validPIN, cardNumberRemains: "")
    assertOutputReceived(pin: validPIN, canLogin: true, whenChangePIN: "", to: validPIN, cardNumberRemains: validCardNumber)
    assertOutputReceived(pin: nil, canLogin: nil, whenChangePIN: validPIN, to: validPIN, cardNumberRemains: "")
    assertOutputReceived(pin: "", canLogin: false, whenChangePIN: validPIN, to: "", cardNumberRemains: "")
  }
  
  func testLogInWhenRequestNotValid() {
    login(withCardNumber: "", pin: "", shouldRemember: true)
    
    assertOutputReceived(canLogin: nil,
                         loginDidBegin: false,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(nil)
  }
  
  func testLoginWithNoToken() {
    login(withCardNumber: validCardNumber, pin: validPIN, shouldRemember: true)
    
    assertOutputReceived(canLogin: false,
                         loginDidBegin: true,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(RetailLoginRequest(cardNumber: validCardNumber,
                                             pin: validPIN))
  }
  
  func testLoginWithToken() {
    storage.tokenSpy = validToken
    
    login(withCardNumber: validCardNumber, pin: validPIN, shouldRemember: true)
    
    assertOutputReceived(canLogin: false,
                         loginDidBegin: true,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(RetailLoginRequest(cardNumber: validCardNumber,
                                             pin: validPIN,
                                             authenticationToken: validToken))
  }
  
  func testHandleLoginSuccessAndRemember() {
    login(withCardNumber: validCardNumber, pin: validPIN, shouldRemember: true)
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertOutputReceived(canLogin: nil,
                         loginDidBegin: false,
                         loginDidEnd: true,
                         loginErrors: nil)
    assertStorageSaved(validCardNumber)
  }
  
  func testHandleLoginSuccessAndNotRemember() {
    login(withCardNumber: validCardNumber, pin: validPIN, shouldRemember: false)
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertStorageSaved(nil)
  }
  
  func testHandleLoginFailure() {
    login(withCardNumber: validCardNumber, pin: validPIN, shouldRemember: true)
    output.reset()
    
    interactor.loginDidFail(dueTo: [error])
    
    assertOutputReceived(canLogin: true,
                         loginDidBegin: false,
                         loginDidEnd: false,
                         loginErrors: [error])
    assertStorageSaved(nil)
  }
  
  func testHelpWithCardNumber() {
    interactor.helpWithCardNumber()
    
    assertHelp(is: .cardNumber)
  }
  
  func testHelpWithPIN() {
    interactor.helpWithPIN()
    
    assertHelp(is: .pin)
  }
  
  // MARK: helpers
  
  private func login(withCardNumber cardNumber: String, pin: String, shouldRemember: Bool) {
    interactor.changeCardNumber(to: cardNumber)
    interactor.changePIN(to: pin)
    output.reset()
    interactor.logIn(shouldRememberCardNumber: shouldRemember)
  }
  
  private func assertOutputReceived(cardNumber: String?,
                                    canLogin: Bool?,
                                    whenChangeCardNumber oldCardNumber: String,
                                    to newCardNumber: String,
                                    pinRemains pin: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    interactor.changeCardNumber(to: oldCardNumber)
    interactor.changePIN(to: pin)
    output.reset()
    
    interactor.changeCardNumber(to: newCardNumber)
    
    assertOutputReceived(cardNumber: cardNumber, pin: nil, canLogin: canLogin)
  }
  
  private func assertOutputReceived(pin: String?,
                                    canLogin: Bool?,
                                    whenChangePIN oldPIN: String,
                                    to newPIN: String,
                                    cardNumberRemains cardNumber: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    interactor.changeCardNumber(to: cardNumber)
    interactor.changePIN(to: oldPIN)
    output.reset()
    
    interactor.changePIN(to: newPIN)
    
    assertOutputReceived(cardNumber: nil, pin: pin, canLogin: canLogin)
  }
  
  private func assertOutputReceived(cardNumber: String?,
                                    pin: String?,
                                    canLogin: Bool?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.cardNumberSpy, cardNumber, "cardNumber", file: file, line: line)
    XCTAssertEqual(output.pinSpy, pin, "pin", file: file, line: line)
    XCTAssertEqual(output.canLoginSpy, canLogin, "canLogin", file: file, line: line)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    loginDidBegin: Bool?,
                                    loginDidEnd: Bool?,
                                    loginErrors: [LoginError]?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.canLoginSpy, canLogin, "canLogin", file: file, line: line)
    XCTAssertEqual(output.didBeginLoginSpy, loginDidBegin, "loginDidBegin", file: file, line: line)
    XCTAssertEqual(output.didEndLoginSpy, loginDidEnd, "loginDidEnd", file: file, line: line)
    XCTAssertEqual(output.loginErrorsSpy, loginErrors, "loginErrors", file: file, line: line)
  }
  
  private func assertServiceReceived(_ request: RetailLoginRequest?,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertEqual(service.requestSpy, request, "request", file: file, line: line)
  }
  
  private func assertStorageSaved(_ cardNumber: String?,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertEqual(storage.cardNumberSpy, cardNumber, "cardNumber", file: file, line: line)
  }
  
  private func assertHelp(is help: LoginHelp,
                          file: StaticString = #file,
                          line: UInt = #line) {
    XCTAssertEqual(output.helpSpy, help, "", file: file, line: line)
  }
}

class RetailLoginInteractorOutputSpy: RetailLoginInteractorOutput {
  var cardNumberSpy: String?
  var pinSpy: String?
  var canLoginSpy: Bool?
  var didBeginLoginSpy = false
  var didEndLoginSpy = false
  var loginErrorsSpy: [LoginError]?
  var helpSpy: LoginHelp?
  var verificationRequestSpy: RetailLoginRequest?
  
  func reset() {
    cardNumberSpy = nil
    pinSpy = nil
    canLoginSpy = nil
    didBeginLoginSpy = false
    didEndLoginSpy = false
    loginErrorsSpy = nil
    helpSpy = nil
    verificationRequestSpy = nil
  }
  
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
    didBeginLoginSpy = true
  }
  
  func loginDidEnd() {
    didEndLoginSpy = true
  }
  
  func loginDidFail(withErrors errors: [LoginError]) {
    loginErrorsSpy = errors
  }
  
  func showHelp(_ help: LoginHelp) {
    helpSpy = help
  }
  
  func inquireVerificationCode(forRequest request: RetailLoginRequest) {
    verificationRequestSpy = request
  }
}

class RetailLoginServiceSpy: RetailLoginServiceInput {
  var requestSpy: RetailLoginRequest?
  
  func logIn(withCardNumberRequest request: RetailLoginRequest) {
    requestSpy = request
  }
}

class RetailLoginStorageSpy: RetailLoginStorage {
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

