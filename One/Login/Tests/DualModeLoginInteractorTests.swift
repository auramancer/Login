import XCTest

class DualModeLoginInteractorTests: XCTestCase {
  private var interactor: DualModeLoginInteractor!
  private var output: DualModeLoginInteractorOutputSpy!
  private var service: DualModeLoginServiceSpy!
  private var storage: DualModeLoginStorageSpy!
  
  private let validUsername = "name"
  private let validCardNumber = "12345678"
  private let validPassword = "1234"
  private let error = "Cannot log in."
  
  override func setUp() {
    super.setUp()
    
    output = DualModeLoginInteractorOutputSpy()
    service = DualModeLoginServiceSpy()
    storage = DualModeLoginStorageSpy()
    
    interactor = DualModeLoginInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
  }
  
  func testC() {
    interactor.reset()
    
  
  }
  
//  func testResetWithNoRememberedUsername() {
//    interactor.reset()
//    
//    XCTAssertEqual(output.usernameSpy, "")
//    XCTAssertEqual(output.passwordSpy, "")
//    XCTAssertEqual(output.canLoginSpy, false)
//  }
//  
//  func testResetWithRememberedUsername() {
//    storage.username = validUsername
//    
//    interactor.reset()
//    
//    XCTAssertEqual(output.usernameSpy, validUsername)
//    XCTAssertEqual(output.passwordSpy, "")
//    XCTAssertEqual(output.canLoginSpy, false)
//  }
//  
//  func testChangeUsername() {
//    interactor.changeUsername(to: validUsername)
//    
//    XCTAssertEqual(output.usernameSpy, validUsername)
//    XCTAssertEqual(output.passwordSpy, nil)
//    XCTAssertEqual(output.canLoginSpy, false)
//  }
//  
//  func testChangeUsernameToSameValue() {
//    interactor.changeUsername(to: validUsername)
//    output.usernameSpy = nil
//    output.canLoginSpy = nil
//    
//    interactor.changeUsername(to: validUsername)
//    
//    XCTAssertEqual(output.usernameSpy, nil)
//    XCTAssertEqual(output.passwordSpy, nil)
//    XCTAssertEqual(output.canLoginSpy, nil)
//  }
//  
//  func testClearUsername() {
//    interactor.changeUsername(to: validUsername)
//    output.usernameSpy = nil
//    output.canLoginSpy = nil
//    
//    interactor.changeUsername(to: "")
//    
//    XCTAssertEqual(output.usernameSpy, "")
//    XCTAssertEqual(output.passwordSpy, nil)
//    XCTAssertEqual(output.canLoginSpy, false)
//  }
//  
//  func testChangePassword() {
//    interactor.changePassword(to: validPassword)
//    
//    XCTAssertEqual(output.usernameSpy, nil)
//    XCTAssertEqual(output.passwordSpy, validPassword)
//    XCTAssertEqual(output.canLoginSpy, false)
//  }
//  
//  func testChangePasswordToSameValue() {
//    interactor.changePassword(to: validPassword)
//    output.passwordSpy = nil
//    output.canLoginSpy = nil
//    
//    interactor.changePassword(to: validPassword)
//    
//    XCTAssertEqual(output.usernameSpy, nil)
//    XCTAssertEqual(output.passwordSpy, nil)
//    XCTAssertEqual(output.canLoginSpy, nil)
//  }
//  
//  func testClearPassword() {
//    interactor.changePassword(to: validPassword)
//    output.passwordSpy = nil
//    output.canLoginSpy = nil
//    
//    interactor.changePassword(to: "")
//    
//    XCTAssertEqual(output.usernameSpy, nil)
//    XCTAssertEqual(output.passwordSpy, "")
//    XCTAssertEqual(output.canLoginSpy, false)
//  }
//  
//  func testChangePasswordWhenUsernameIsValid() {
//    interactor.changeUsername(to: validUsername)
//    
//    interactor.changePassword(to: validPassword)
//    
//    XCTAssertEqual(output.usernameSpy, validUsername)
//    XCTAssertEqual(output.passwordSpy, validPassword)
//    XCTAssertEqual(output.canLoginSpy, true)
//  }
//  
//  func testChangeUsernameWhenPasswordIsValid() {
//    interactor.changePassword(to: validPassword)
//    
//    interactor.changeUsername(to: validUsername)
//    
//    XCTAssertEqual(output.usernameSpy, validUsername)
//    XCTAssertEqual(output.passwordSpy, validPassword)
//    XCTAssertEqual(output.canLoginSpy, true)
//  }
//  
//  func testClearUsernameWhenBothAreValid() {
//    interactor.changeUsername(to: validUsername)
//    interactor.changePassword(to: validPassword)
//    
//    interactor.changeUsername(to: "")
//    
//    XCTAssertEqual(output.usernameSpy, "")
//    XCTAssertEqual(output.passwordSpy, validPassword)
//    XCTAssertEqual(output.canLoginSpy, false)
//  }
//  
//  func testClearPasswordWhenBothAreValid() {
//    interactor.changeUsername(to: validUsername)
//    interactor.changePassword(to: validPassword)
//    
//    interactor.changePassword(to: "")
//    
//    XCTAssertEqual(output.usernameSpy, validUsername)
//    XCTAssertEqual(output.passwordSpy, "")
//    XCTAssertEqual(output.canLoginSpy, false)
//  }
//  
//  func testLogInWithNoDetails() {
//    interactor.logIn(shouldRememberUsername: false)
//    
//    XCTAssertEqual(output.canLoginSpy, nil)
//    XCTAssertEqual(output.loginDidBeginSpy, false)
//    XCTAssertNil(service.detailsSpy)
//  }
//  
//  func testLogin() {
//    interactor.changeUsername(to: validUsername)
//    interactor.changePassword(to: validPassword)
//    
//    interactor.logIn(shouldRememberUsername: false)
//    
//    XCTAssertEqual(output.canLoginSpy, false)
//    XCTAssertEqual(output.loginDidBeginSpy, true)
//  }
//  
//  func testHandleLoginSuccessAndRemember() {
//    interactor.changeUsername(to: validUsername)
//    interactor.changePassword(to: validPassword)
//    interactor.logIn(shouldRememberUsername: true)
//    
//    interactor.loginDidSucceed()
//    
//    XCTAssertEqual(output.canLoginSpy, false)
//    XCTAssertEqual(output.loginDidEndSpy, true)
//    XCTAssertNil(output.errorsSpy)
//    XCTAssertEqual(storage.username, validUsername)
//  }
//  
//  func testHandleLoginSuccessAndNotRemember() {
//    interactor.changeUsername(to: validUsername)
//    interactor.changePassword(to: validPassword)
//    interactor.logIn(shouldRememberUsername: false)
//    
//    interactor.loginDidSucceed()
//    
//    XCTAssertEqual(storage.username, nil)
//  }
//  
//  func testHandleLoginFailure() {
//    interactor.changeUsername(to: validUsername)
//    interactor.changePassword(to: validPassword)
//    interactor.logIn(shouldRememberUsername: true)
//    
//    interactor.loginDidFail(dueTo: [error])
//    
//    XCTAssertEqual(output.canLoginSpy, true)
//    XCTAssertEqual(output.loginDidEndSpy, false)
//    XCTAssertEqual(output.errorsSpy!, [error])
//    XCTAssertEqual(storage.username, nil)
//  }
//
  
  func testHelpWithID() {
    interactor.changeID(to: validUsername)
    
    interactor.helpWithID()
    
    XCTAssertEqual(output.helpSpy, LoginHelp.username)
  }
  
  func testHelpWithPassword() {
    interactor.changeID(to: validCardNumber)
    
    interactor.helpWithSecret()
    
    XCTAssertEqual(output.helpSpy, LoginHelp.pin)
  }
}

class DualModeLoginInteractorOutputSpy: DualModeLoginInteractorOutput {
  var idSpy: String?
  var secretSpy: String?
  var canLoginSpy: Bool?
  var modeSpy: LoginMode?
  var loginDidBeginSpy = false
  var loginDidEndSpy = false
  var errorsSpy: [LoginError]?
  var helpSpy: LoginHelp?
  var detailsSpy: CardNumberLoginDetails?
  
  func idDidChange(to id: String) {
    idSpy = id
  }
  
  func secretDidChange(to secret: String) {
    secretSpy = secret
  }
  
  func canLoginDidChange(to canLogin: Bool) {
    canLoginSpy = canLogin
  }
  
  func loginModeDidChange(to mode: LoginMode) {
    modeSpy = mode
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
    detailsSpy = details
  }
}

class DualModeLoginServiceSpy: DualModeLoginServiceInput {
  var usernameDetailsSpy: UsernameLoginDetails?
  var cardNumberDetailsSpy: CardNumberLoginDetails?
  
  func logIn(withUsernameDetails details: UsernameLoginDetails) {
    usernameDetailsSpy = details
  }
  
  func logIn(withCardNumberDetails details: CardNumberLoginDetails) {
    cardNumberDetailsSpy = details
  }
}

class DualModeLoginStorageSpy: DualModeLoginStorage {
  var usernameSpy: String?
  var cardNumberSpy: String?
  var tokenSpy: String?
  
  func saveUsername(_ username: String) {
    usernameSpy = username
  }
  
  func loadUsername() -> String? {
    return usernameSpy
  }
  
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

//class UsernameLoginInteractorSpy: UsernameLoginInteractor {
//  var resetSpy = false
//  var usernameSpy: String?
//
//  override func reset() {
//    resetSpy = true
//  }
//
//  override func changeUsername(to username: String) {
//    usernameSpy = username
//  }
//
//  override func changePassword(to pasword: String) {
//
//  }
//
//  override func logIn(shouldRememberUsername: Bool) {
//
//  }
//
//  override func helpWithUsername() {
//
//  }
//
//  override func helpWithPassword() {
//
//  }
//}

