import XCTest

class DualModeLoginInteractorTests: XCTestCase {
  private var interactor: DualModeLoginInteractor!
  private var output: DualModeLoginInteractorOutputSpy!
  private var service: DualModeLoginServiceSpy!
  private var storage: DualModeLoginStorageSpy!
  
  private let ambiguousID = "12345"
  private let validUsername = "name"
  private let validCardNumber = "12345678"
  private let validPassword = "1234"
  private let validPIN = "1234"
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
  
  func testReset() {
    interactor.reset()
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.modeSpy, LoginMode.undetermined)
  }
  
  func testResetInUsernameMode() {
    interactor.changeID(to: validUsername)
    
    interactor.reset()
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.modeSpy, LoginMode.undetermined)
  }
  
  func testResetInCardNumberMode() {
    interactor.changeID(to: validCardNumber)
    
    interactor.reset()
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.modeSpy, LoginMode.undetermined)
  }
  
  func testChangeIDRemainAmbiguous() {
    interactor.changeID(to: ambiguousID)
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.modeSpy, nil)
  }
  
  func testChangeIDFromAmbiguousToUsername() {
    interactor.changeID(to: validUsername)
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.modeSpy, LoginMode.username)
  }
  
  func testChangeIDFromAmbiguousCardNumber() {
    interactor.changeID(to: validCardNumber)
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.modeSpy, LoginMode.cardNumber)
  }
  
  func testChangeIDFromUsernameToAmbiguous() {
    interactor.changeID(to: validUsername)
    
    interactor.changeID(to: ambiguousID)
    
    XCTAssertEqual(output.modeSpy, LoginMode.undetermined)
  }
  
  func testChangeIDFromUsernameToCardNumber() {
    interactor.changeID(to: validUsername)
    
    interactor.changeID(to: validCardNumber)
    
    XCTAssertEqual(output.modeSpy, LoginMode.cardNumber)
  }
  
  func testChangeIDFromCardNumberToAmbiguous() {
    interactor.changeID(to: validCardNumber)
    
    interactor.changeID(to: ambiguousID)
    
    XCTAssertEqual(output.modeSpy, LoginMode.undetermined)
  }
  
  func testChangeIDFromCardNumberToUsername() {
    interactor.changeID(to: validCardNumber)
    
    interactor.changeID(to: validUsername)
    
    XCTAssertEqual(output.modeSpy, LoginMode.username)
  }
  
  func testLoginWithUsername() {
    interactor.changeID(to: validUsername)
    interactor.changeSecret(to: validPassword)
    
    interactor.logIn(shouldRememberID: true)
    
    let detailsSpy = service.usernameDetailsSpy
    XCTAssertEqual(detailsSpy?.username, validUsername)
    XCTAssertEqual(detailsSpy?.password, validPassword)
    XCTAssertNil(service.cardNumberDetailsSpy)
  }
  
  func testLoginWithCardNumber() {
    interactor.changeID(to: validCardNumber)
    interactor.changeSecret(to: validPIN)
    
    interactor.logIn(shouldRememberID: true)
    
    let detailsSpy = service.cardNumberDetailsSpy
    XCTAssertEqual(detailsSpy?.cardNumber, validCardNumber)
    XCTAssertEqual(detailsSpy?.pin, validPIN)
    XCTAssertNil(service.usernameDetailsSpy)
  }
  
  func testHandleLoginSuccessInUsernameMode() {
    interactor.changeID(to: validUsername)
    interactor.changeSecret(to: validPassword)
    interactor.logIn(shouldRememberID: true)
    
    interactor.loginDidSucceed()
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.loginDidEndSpy, true)
    XCTAssertNil(output.errorsSpy)
    XCTAssertEqual(storage.usernameSpy, validUsername)
    XCTAssertEqual(storage.cardNumberSpy, nil)
  }
  
  func testHandleLoginSuccessInCardNumberMode() {
    interactor.changeID(to: validCardNumber)
    interactor.changeSecret(to: validPIN)
    interactor.logIn(shouldRememberID: true)
    
    interactor.loginDidSucceed()
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.loginDidEndSpy, true)
    XCTAssertNil(output.errorsSpy)
    XCTAssertEqual(storage.cardNumberSpy, validCardNumber)
    XCTAssertEqual(storage.usernameSpy, nil)
  }
  
  func testHandleLoginFailureInUsernameMode() {
    interactor.changeID(to: validUsername)
    interactor.changeSecret(to: validPassword)
    interactor.logIn(shouldRememberID: true)
    
    interactor.loginDidFail(dueTo: [error])
    
    XCTAssertEqual(output.canLoginSpy, true)
    XCTAssertEqual(output.loginDidEndSpy, false)
    XCTAssertEqual(output.errorsSpy!, [error])
    XCTAssertEqual(storage.usernameSpy, nil)
  }
  
  func testHandleLoginFailureInCardNumberMode() {
    interactor.changeID(to: validCardNumber)
    interactor.changeSecret(to: validPIN)
    interactor.logIn(shouldRememberID: true)
    
    interactor.loginDidFail(dueTo: [error])
    
    XCTAssertEqual(output.canLoginSpy, true)
    XCTAssertEqual(output.loginDidEndSpy, false)
    XCTAssertEqual(output.errorsSpy!, [error])
    XCTAssertEqual(storage.cardNumberSpy, nil)
  }
  
  func testHandleExpiredToken() {
    interactor.changeID(to: validCardNumber)
    interactor.changeSecret(to: validPIN)
    interactor.logIn(shouldRememberID: true)
    
    interactor.loginDidFailDueToExpiredToken()
    
    XCTAssertEqual(output.canLoginSpy, false)
    XCTAssertEqual(output.loginDidEndSpy, false)
    XCTAssertNil(output.errorsSpy)
//    XCTAssertEqual(output.detailsSpy, true)
    XCTAssertEqual(storage.cardNumberSpy, nil)
  }
  
  func testHelpWithIDInUsernameMode() {
    interactor.changeID(to: validUsername)
    
    interactor.helpWithID()
    
    XCTAssertEqual(output.helpSpy, LoginHelp.username)
  }
  
  func testHelpWithIDInCardNumberMode() {
    interactor.changeID(to: validCardNumber)
    
    interactor.helpWithID()
    
    XCTAssertEqual(output.helpSpy, LoginHelp.cardNumber)
  }
  
  func testHelpWithSecretInUsernameMode() {
    interactor.changeID(to: validUsername)
    
    interactor.helpWithSecret()
    
    XCTAssertEqual(output.helpSpy, LoginHelp.password)
  }
  
  func testHelpWithSecretInCardNumberMode() {
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

