import XCTest

class IdentityCreationInteractorTests: XCTestCase {
  private var interactor: IdentityCreationInteractor!
  private var output: IdentityCreationInteractorOutputSpy!
  private var service: IdentityCreationServiceSpy!
  private var storage: RetailLoginStorageSpy!
  
  typealias Data = LoginTestData
  private let username = Data.validUsername
  private let password = Data.validPassword
  private let digitalIdentity = Data.validDigitalIdentity
  private let retailIdentity = Data.retailIdentityWithEverything 
  
  override func setUp() {
    super.setUp()
    
    output = IdentityCreationInteractorOutputSpy()
    service = IdentityCreationServiceSpy()
    storage = RetailLoginStorageSpy()
    
    interactor = IdentityCreationInteractor()
    interactor.output = output
    interactor.service = service
    interactor.storage = storage
  }
  
  func testLoad() {
    load()
    
    assertOutputReceived(canCreate: false)
  }
  
  func testChangeUsernameOnly() {
    load()
    output.reset()
    
    interactor.changeIdentifier(to: username)
    
    assertOutputReceived(canCreate: nil)
  }
  
  func testChangePasswordOnly() {
    load()
    output.reset()
    
    interactor.changeCredential(to: password)
    
    assertOutputReceived(canCreate: nil)
  }
  
  func testChangeUsername() {
    assertOutputReceived(canCreate: nil, whenChangeUsername: "", to: username, passwordRemains: "")
    assertOutputReceived(canCreate: true, whenChangeUsername: "", to: username, passwordRemains: password)
    assertOutputReceived(canCreate: nil, whenChangeUsername: username, to: Data.validUsername2, passwordRemains: password)
    assertOutputReceived(canCreate: false, whenChangeUsername: username, to: Data.shortUsername, passwordRemains: password)
    assertOutputReceived(canCreate: false, whenChangeUsername: username, to: Data.nonAlphanumericUsername, passwordRemains: password)
  }
  
  func testChangePassword() {
    assertOutputReceived(canCreate: nil, whenChangePassword: "", to: password, usernameRemains: "")
    assertOutputReceived(canCreate: true, whenChangePassword: "", to: password, usernameRemains: username)
    assertOutputReceived(canCreate: nil, whenChangePassword: password, to: Data.validPassword2, usernameRemains: username)
    assertOutputReceived(canCreate: false, whenChangePassword: password, to: Data.shortPassword, usernameRemains: username)
    assertOutputReceived(canCreate: false, whenChangePassword: password, to: Data.nonAlphanumericPassword, usernameRemains: username)
  }
  
  func testCreate() {
    setIdentity()
    output.reset()
    
    interactor.create()
    
    assertOutputReceived(creationDidBegin: true,
                         creationDidEnd: false,
                         errors: nil)
    assertServiceReceived(digitalIdentity: digitalIdentity,
                          retailIdentity: retailIdentity)
  }
  
  func testCreationDidSucceed() {
    create()
    output.reset()
    
    interactor.creationDidSucceed()
    
    assertOutputReceived(creationDidBegin: false,
                         creationDidEnd: true,
                         errors: nil)
    assertStorageSaved(token: Data.validToken)
  }
  
  func testCreationDidFail() {
    create()
    output.reset()
    
    interactor.creationDidFail(dueTo: [Data.error])
    
    assertOutputReceived(creationDidBegin: false,
                         creationDidEnd: false,
                         errors: [Data.errorMessage])
    assertStorageSaved(token: nil)
  }
  
  // Mark: helpers
  
  private func load() {
    interactor.load(withRetailIdentity: retailIdentity)
  }
  
  private func setIdentity(_ identity: DigitalIdentity = Data.validDigitalIdentity) {
    load()
    interactor.changeIdentifier(to: identity.identifier)
    interactor.changeCredential(to: identity.credential)
  }
  
  private func create() {
    setIdentity()
    interactor.create()
  }
  
  private func assertOutputReceived(canCreate: Bool?,
                                    whenChangeUsername oldUsername: String,
                                    to newUsername: String,
                                    passwordRemains password: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    setIdentity(DigitalIdentity(identifier: oldUsername, credential: password))
    output.reset()
    
    interactor.changeIdentifier(to: newUsername)
    
    assertOutputReceived(canCreate: canCreate, file: file, line: line)
  }
  
  private func assertOutputReceived(canCreate: Bool?,
                                    whenChangePassword oldPassword: String,
                                    to newPassword: String,
                                    usernameRemains username: String,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    setIdentity(DigitalIdentity(identifier: username, credential: oldPassword))
    output.reset()
    
    interactor.changeCredential(to: newPassword)
    
    assertOutputReceived(canCreate: canCreate, file: file, line: line)
  }
  
  private func assertOutputReceived(canCreate: Bool?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.canCreateSpy, canCreate, "canCreate", file: file, line: line)
  }
  
  private func assertOutputReceived(creationDidBegin: Bool?,
                                    creationDidEnd: Bool?,
                                    errors: [String]?,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.creationDidBeginSpy, creationDidBegin, "creationDidBegin", file: file, line: line)
    XCTAssertEqual(output.creationDidEndSpy, creationDidEnd, "creationDidEnd", file: file, line: line)
    XCTAssertEqual(output.errorsSpy, errors, "errors", file: file, line: line)
  }
  
  private func assertServiceReceived(digitalIdentity: DigitalIdentity?,
                                     retailIdentity: RetailIdentity?,
                                     file: StaticString = #file,
                                     line: UInt = #line) {
    XCTAssertEqual(service.digitalIdentitySpy, digitalIdentity, "digitalIdentity", file: file, line: line)
    XCTAssertEqual(service.retailIdentitySpy, retailIdentity, "retailIdentity", file: file, line: line)
  }
  
  private func assertStorageSaved(token: String?,
                                  file: StaticString = #file,
                                  line: UInt = #line) {
    XCTAssertEqual(storage.tokenSpy, token, "token", file: file, line: line)
  }
}

class IdentityCreationInteractorOutputSpy: IdentityCreationInteractorOutput {
  var canCreateSpy: Bool?
  var creationDidBeginSpy = false
  var creationDidEndSpy = false
  var errorsSpy: [String]?
  
  func reset() {
    canCreateSpy = nil
    creationDidBeginSpy = false
    creationDidEndSpy = false
    errorsSpy = nil
  }
  
  func didLoad(canCreate: Bool) {
    canCreateSpy = canCreate
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
  
  func creationDidFail(withErrors errors: [String]) {
    errorsSpy = errors
  }
}

class IdentityCreationServiceSpy: IdentityCreationServiceInput {
  var digitalIdentitySpy: DigitalIdentity?
  var retailIdentitySpy: RetailIdentity?
  
  func create(digitalIdentity: DigitalIdentity, withRetailIdentity retailIdentity: RetailIdentity) {
    digitalIdentitySpy = digitalIdentity
    retailIdentitySpy = retailIdentity
  }
}
