import XCTest

class IdentityCreationPresenterTests: XCTestCase {
  private var presenter: IdentityCreationPresenter!
  private var output: IdentityCreationPresenterOutputSpy!
  
  private let defaultMessage = "As this is your first time logging in with these details we need to ask for some further information.\n\n" +
  "Please choose a Username and Password, you can login with these details, or continue to use your membership number and PIN."
  private let errorMessage = "Username taken"
  
  override func setUp() {
    super.setUp()
    
    output = IdentityCreationPresenterOutputSpy()
    
    presenter = IdentityCreationPresenter()
    presenter.output = output
  }
  
  func testDidLoad() {
    presenter.didLoad(canCreate: true)
    
    XCTAssertEqual(output.messageSpy, LoginMessage(text: defaultMessage, style: .default))
    XCTAssertEqual(output.canCreateSpy, true)
  }
  
  func testCanCreateDidChange() {
    presenter.canCreateDidChange(to: true)
    
    XCTAssertEqual(output.canCreateSpy, true)
  }
  
  func testCreationDidBegin() {
    presenter.creationDidBegin()
    
    assertOutputReceived(isCreating: true,
                         message: nil,
                         clearMessage: true,
                         leave: false)
  }
  
  func testCreationDidEnd() {
    presenter.creationDidEnd()
    
    assertOutputReceived(isCreating: false,
                         message: nil,
                         clearMessage: false,
                         leave: true)
  }
  
  func testCreationDidFail() {
    presenter.creationDidFail(withErrors: [errorMessage])
    
    assertOutputReceived(isCreating: false,
                         message: LoginMessage(text: errorMessage, style: .error),
                         clearMessage: false,
                         leave: false)
  }
  
  // MARK: helpers
  
  private func assertOutputReceived(isCreating: Bool?,
                                    message: LoginMessage?,
                                    clearMessage: Bool,
                                    leave: Bool,
                                    file: StaticString = #file,
                                    line: UInt = #line) {
    XCTAssertEqual(output.isCreatingSpy, isCreating, "isCreating", file: file, line: line)
    XCTAssertEqual(output.messageSpy, message, "message", file: file, line: line)
    XCTAssertEqual(output.clearMessageSpy, clearMessage, "clearMessage", file: file, line: line)
    XCTAssertEqual(output.leaveSpy, leave, "leave", file: file, line: line)
  }
}

class IdentityCreationPresenterOutputSpy: IdentityCreationPresenterOutput {
  var canCreateSpy: Bool?
  var isCreatingSpy: Bool?
  var messageSpy: LoginMessage?
  var clearMessageSpy = false
  var leaveSpy = false
  
  func changeCanCreate(to canCreate: Bool) {
    canCreateSpy = canCreate
  }
  
  func changeIsCreating(to isCreating: Bool) {
    isCreatingSpy = isCreating
  }
  
  func showMessage(_ message: LoginMessage) {
    messageSpy = message
  }
  
  func clearMessage() {
    clearMessageSpy = true
  }
  
  func leave() {
    leaveSpy = true
  }
}

extension SimpleError: IdentityCreationError {
}
