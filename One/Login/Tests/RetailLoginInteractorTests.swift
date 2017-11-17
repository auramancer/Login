import XCTest

class RetailLoginInteractorTests: XCTestCase {
  private var interactor: RetailLoginInteractor!
  private var output: RetailLoginInteractorOutputSpy!
  private var service: RetailLoginServiceSpy!
  private var storage: RetailLoginStorageSpy!
  
  private let validCardNumber = "1234567890"
  private let validPIN = "888888"
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
  
  func testLoadWithNoRememberedCardNumber() {
    interactor.load()
    
    XCTAssertEqual(output.loadRequestSpy, RetailLoginRequest(cardNumber: "", pin: ""))
  }
  
  func testLoadWithRememberedCardNumber() {
    storage.cardNumberSpy = validCardNumber
    
    interactor.load()
    
    XCTAssertEqual(output.loadRequestSpy, RetailLoginRequest(cardNumber: validCardNumber, pin: ""))
  }
  
  func testChangeCardNumber() {
    assertOutputReceived(canLogin: nil, whenChangeCardNumber: "", to: validCardNumber, pinRemains: "")
    assertOutputReceived(canLogin: true, whenChangeCardNumber: "", to: validCardNumber, pinRemains: validPIN)
    assertOutputReceived(canLogin: false, whenChangeCardNumber: validCardNumber, to: "", pinRemains: validPIN)
  }
  
  func testChangePIN() {
    assertOutputReceived(canLogin: nil, whenChangePIN: "", to: validPIN, cardNumberRemains: "")
    assertOutputReceived(canLogin: true, whenChangePIN: "", to: validPIN, cardNumberRemains: validCardNumber)
    assertOutputReceived(canLogin: false, whenChangePIN: validPIN, to: "", cardNumberRemains: validCardNumber)
  }
  
  func testLoginWithNoToken() {
    set(cardNumber: validCardNumber, pin: validPIN)
    output.reset()
    
    interactor.logIn(shouldRememberCardNumber: true)
    
    assertOutputReceived(canLogin: nil)
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(RetailLoginRequest(cardNumber: validCardNumber,
                                             pin: validPIN))
  }
  
  func testLoginWithToken() {
    storage.tokenSpy = validToken
    set(cardNumber: validCardNumber, pin: validPIN)
    output.reset()
    
    interactor.logIn(shouldRememberCardNumber: true)
    
    assertOutputReceived(loginDidBegin: true,
                         loginDidEnd: false,
                         loginErrors: nil)
    assertServiceReceived(RetailLoginRequest(cardNumber: validCardNumber,
                                             pin: validPIN,
                                             authenticationToken: validToken))
  }
  
  func testHandleLoginSuccessAndRemember() {
    login()
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertOutputReceived(loginDidBegin: false,
                         loginDidEnd: true,
                         loginErrors: nil)
    assertStorageSaved(validCardNumber)
  }
  
  func testHandleLoginSuccessAndNotRemember() {
    login(shouldRemember: false)
    output.reset()
    
    interactor.loginDidSucceed()
    
    assertStorageSaved(nil)
  }
  
  func testHandleLoginFailure() {
    login()
    output.reset()
    
    interactor.loginDidFail(dueTo: [SimpleError(error)])
    
    assertOutputReceived(loginDidBegin: false,
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
  
  private func set(cardNumber: String, pin: String) {
    interactor.load()
    interactor.changeCardNumber(to: cardNumber)
    interactor.changePIN(to: pin)
  }
  
  private func login(shouldRemember: Bool = true) {
    set(cardNumber: validCardNumber, pin: validPIN)
    interactor.logIn(shouldRememberCardNumber: shouldRemember)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    whenChangeCardNumber oldCardNumber: String,
                                    to newCardNumber: String,
                                    pinRemains pin: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    set(cardNumber: oldCardNumber, pin: pin)
    output.reset()
    
    interactor.changeCardNumber(to: newCardNumber)
    
    assertOutputReceived(canLogin: canLogin, file: file, line: line)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    whenChangePIN oldPIN: String,
                                    to newPIN: String,
                                    cardNumberRemains cardNumber: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    set(cardNumber: cardNumber, pin: oldPIN)
    output.reset()
    
    interactor.changePIN(to: newPIN)
    
    assertOutputReceived(canLogin: canLogin, file: file, line: line)
  }
  
  private func assertOutputReceived(canLogin: Bool?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.canLoginSpy, canLogin, "canLogin", file: file, line: line)
  }
  
  private func assertOutputReceived(loginDidBegin: Bool?,
                                    loginDidEnd: Bool?,
                                    loginErrors: [String]?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.loginDidBeginSpy, loginDidBegin, "loginDidBegin", file: file, line: line)
    XCTAssertEqual(output.loginDidEndSpy, loginDidEnd, "loginDidEnd", file: file, line: line)
    XCTAssertEqual(output.errorsSpy, loginErrors, "loginErrors", file: file, line: line)
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
  var loadRequestSpy: RetailLoginRequest?
  var cardNumberSpy: String?
  var pinSpy: String?
  var canLoginSpy: Bool?
  var loginDidBeginSpy = false
  var loginDidEndSpy = false
  var errorsSpy: [String]?
  var helpSpy: LoginHelp?
  var verificationRequestSpy: RetailLoginRequest?
  
  func reset() {
    cardNumberSpy = nil
    pinSpy = nil
    canLoginSpy = nil
    loginDidBeginSpy = false
    loginDidEndSpy = false
    errorsSpy = nil
    helpSpy = nil
    verificationRequestSpy = nil
  }
  
  func didLoad(withRememberedRequest request: RetailLoginRequest) {
    loadRequestSpy = request
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
  
  func loginDidFail(withErrors errors: [String]) {
    errorsSpy = errors
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

