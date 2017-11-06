import XCTest
@testable import FFKit

class AlertControllerTests: XCTestCase {
  struct Text {
    static let title = "title"
    static let message = "message"
    static let confirm = "OK"
    static let cancel = "cancel"
    static let input = "input"
  }
  
  let confirmAction = AlertAction(title: Text.confirm, style: .default, handler: nil)
  let cancelAction = AlertAction(title: Text.cancel, style: .cancel, handler: nil)
  
  var alertController: AlertController!
  var delegate: AlertControllerDelegateSpy!
  
  var alertView: AlertView {
    return alertController.alertView!
  }
  var firstButton: UIButton {
    return alertView.buttons![0]
  }
  var secondButton: UIButton {
    return alertView.buttons![1]
  }
  
  override func setUp() {
    super.setUp()
    
    delegate = AlertControllerDelegateSpy()
    
    alertController = AlertController()
    alertController.delegate = delegate
  }
  
  func testShowAlertWithNoAction() {
    let alert = Alert(title: Text.title, message: Text.message, actions: [])
    
    show(alert)
    
    XCTAssertEqual(alertView.titleLabel!.text, Text.title)
    XCTAssertEqual(alertView.messageLabel!.text, Text.message)
    XCTAssertTrue(alertView.buttonsView!.isHidden)
    XCTAssertTrue(alertView.textField!.isHidden)
    XCTAssertTrue(alertView.activityIndicator!.isHidden)
  }
  
  func testShowAlertWithOneAction() {
    let alert = Alert(title: Text.title, message: Text.message, actions: [confirmAction])
    
    show(alert)
    
    XCTAssertFalse(alertView.buttonsView!.isHidden)
    XCTAssertFalse(firstButton.isHidden)
    XCTAssertEqual(firstButton.title(for: .normal), Text.confirm)
    XCTAssertTrue(secondButton.isHidden)
  }
  
  func testShowAlertWithTwoActions() {
    let alert = Alert(title: Text.title, message: Text.message, actions: [cancelAction, confirmAction])
    
    show(alert)
    
    XCTAssertFalse(alertView.buttonsView!.isHidden)
    XCTAssertFalse(firstButton.isHidden)
    XCTAssertEqual(firstButton.title(for: .normal), Text.cancel)
    XCTAssertFalse(secondButton.isHidden)
    XCTAssertEqual(secondButton.title(for: .normal), Text.confirm)
  }
  
  func testShowAlertWithAttributedText() {
    let attributedTitle = NSAttributedString(string: Text.title)
    let attributedMessage = NSAttributedString(string: Text.message)
    let alert = Alert(title: attributedTitle, message: attributedMessage, actions: [confirmAction])
    
    show(alert)
    
    XCTAssertEqual(alertView.titleLabel!.attributedText, attributedTitle)
    XCTAssertEqual(alertView.messageLabel!.attributedText, attributedMessage)
  }

  func testShowAlertWithNoTitle() {
    let alert = Alert(title: nil, message: Text.message, actions: [])
    
    show(alert)
    
    XCTAssertTrue(alertView.titleLabel!.isHidden)
  }

  func testShowAlertWithNoMessage() {
    let alert = Alert(title: Text.title, message: nil, actions: [])
    
    show(alert)
    
    XCTAssertTrue(alertView.messageLabel!.isHidden)
  }
  
  func testShowActivityAlert() {
    let alert = Alert.activity(title: Text.title, message: Text.message)
    
    show(alert)
    
    XCTAssertEqual(alertView.titleLabel!.text, Text.title)
    XCTAssertEqual(alertView.messageLabel!.text, Text.message)
    XCTAssertTrue(alertView.buttonsView!.isHidden)
    XCTAssertTrue(alertView.textField!.isHidden)
    XCTAssertFalse(alertView.activityIndicator!.isHidden)
  }
  
  func testShowAcknowledgementAlert() {
    let alert = Alert.acknowledgement(title: Text.title, message: Text.message, actionTitle: Text.confirm)
    
    show(alert)
    
    XCTAssertEqual(alertView.titleLabel!.text, Text.title)
    XCTAssertEqual(alertView.messageLabel!.text, Text.message)
    XCTAssertFalse(alertView.buttonsView!.isHidden)
    XCTAssertFalse(firstButton.isHidden)
    XCTAssertEqual(firstButton.title(for: .normal), Text.confirm)
    XCTAssertTrue(secondButton.isHidden)
  }

  func testCloseAlert() {
    let alert = Alert(title: Text.title, message: Text.message, actions: [cancelAction, confirmAction])
    
    show(alert)
    alertController.close(secondButton)
    
    XCTAssertEqual(delegate.alert, alert)
    XCTAssertEqual(delegate.action?.title, confirmAction.title)
  }
  
  func testTextFieldInput() {
    let alert = Alert(title: Text.title, message: Text.message, actions: [cancelAction, confirmAction])
    
    show(alert)
    alertView.textField!.text = Text.input
    alertController.close(firstButton)
    
    XCTAssertTrue(firstButton.isEnabled)
    XCTAssertTrue(secondButton.isEnabled)
    XCTAssertEqual(delegate.input, Text.input)
  }
  
  func testConfirmButtonIsDisabledWithInputValidator() {
    var alert = Alert(title: Text.title, message: Text.message, actions: [cancelAction, confirmAction])
    alert.inputValidator = { _ in return false }
    
    show(alert)
    
    XCTAssertTrue(firstButton.isEnabled)
    XCTAssertFalse(secondButton.isEnabled)
  }
  
  func testConfirmButtonIsEnabledAfterEnteredValidInput() {
    var alert = Alert(title: Text.title, message: Text.message, actions: [cancelAction, confirmAction])
    alert.inputValidator = { input in
      return input != nil && input!.characters.count > 0
    }
    
    show(alert)
    let shouldChange = alertController.textField(alertView.textField!,
                                                 shouldChangeCharactersIn: NSRange(location: 0, length: 0),
                                                 replacementString: Text.input)
    
    XCTAssertTrue(shouldChange)
    XCTAssertTrue(firstButton.isEnabled)
    XCTAssertTrue(secondButton.isEnabled)
  }
  
  func testConfirmButtonIsDisabledAgainAfterEnteredInvalidInput() {
    var alert = Alert(title: Text.title, message: Text.message, actions: [cancelAction, confirmAction])
    alert.inputValidator = { input in
      return input != nil && input!.characters.count > 0
    }
    
    show(alert)
    alertView.textField!.text = Text.input
    secondButton.isEnabled = true
    let shouldChange = alertController.textField(alertView.textField!,
                                                 shouldChangeCharactersIn: NSRange(location: 0, length: 5),
                                                 replacementString: "")
    
    XCTAssertTrue(shouldChange)
    XCTAssertTrue(firstButton.isEnabled)
    XCTAssertFalse(secondButton.isEnabled)
  }
  
  func testViewAdjustedWhenThereIsKeyboardAlready() {
    let alert = Alert(title: Text.title, message: Text.message, actions: [confirmAction])
    let alertView = AlertViewSpy()
    alertController.view = alertView
    let keyboardFrame = CGRect(x: 5, y: 5, width: 5, height: 5)
    KeyboardObserver.shared.keyboardFrame = keyboardFrame
    
    show(alert)
    
    XCTAssertEqual(alertView.keyboardFrame, keyboardFrame)
  }
  
  func testViewAdjustedAfterKeyboardAppeared() {
    let alert = Alert(title: Text.title, message: Text.message, actions: [confirmAction])
    let alertView = AlertViewSpy()
    alertController.view = alertView
    let keyboardFrame = CGRect(x: 5, y: 5, width: 5, height: 5)
    
    show(alert)
    NotificationCenter.default.post(name: .keyboardFrameWillChange, object: keyboardFrame)
    
    XCTAssertEqual(alertView.keyboardFrame, keyboardFrame)
  }
  
  private func show(_ alert: Alert) {
    alertController.alert = alert
    alertController.viewDidLoad()
    alertController.viewWillAppear(false)
    alertController.viewDidAppear(false)
  }
}

class AlertControllerDelegateSpy: AlertControllerDelegate {
  var alert: Alert?
  var action: AlertAction?
  var input: String?
  
  func remove(_ alert: Alert, action: AlertAction?, input: String?) {
    self.alert = alert
    self.action = action
    self.input = input
  }
}

class AlertViewSpy: AlertView {
  var keyboardFrame: CGRect?
  
  override func adjustVisibleView(basedOn keyboardFrame: CGRect) {
    self.keyboardFrame = keyboardFrame
  }
}
  
