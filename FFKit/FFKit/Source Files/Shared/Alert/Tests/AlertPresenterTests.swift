import XCTest
@testable import FFKit

class AlertPresenterTest: XCTestCase {
  private var presenter: AlertPresenter!
  private var window: AlertWindowSpy!
  
  let alert1 = Alert(title: "Title1", message: "Message1", actions: [])
  let alert2 = Alert(title: "Title2", message: "Message2", actions: [])
  
  override func setUp() {
    super.setUp()
    
    window = AlertWindowSpy()
    
    presenter = AlertPresenter()
    presenter.window = window
  }
  
  func testShowNothing() {
    presenter.show(nil)
    
    assertWindowIsVisible(false)
    assertPresentedAlert(is: nil)
    assertIsNotPerformingAction()
  }
  
  func testShow() {
    presenter.show(alert1)
    didShow()
    didPresent()
    
    assertWindowIsVisible(true)
    assertPresentedAlert(is: alert1)
    assertIsNotPerformingAction()
  }
  
  func testClose() {
    presenter.show(alert1)
    didShow()
    didPresent()
    presenter.show(nil)
    didDismiss()
    didHide()

    assertWindowIsVisible(false)
    assertPresentedAlert(is: nil)
    assertIsNotPerformingAction()
  }

  func testCloseBeforeShowingWindow() {
    presenter.show(alert1)
    presenter.show(nil)
    didShow()
    didPresent()
    didDismiss()
    didHide()

    assertWindowIsVisible(false)
    assertPresentedAlert(is: nil)
    assertIsNotPerformingAction()
  }

  func testCloseBeforePresentingController() {
    presenter.show(alert1)
    didShow()
    presenter.show(nil)
    didPresent()
    didDismiss()
    didHide()

    assertWindowIsVisible(false)
    assertPresentedAlert(is: nil)
    assertIsNotPerformingAction()
  }

  func testShowAnother() {
    presenter.show(alert1)
    didShow()
    didPresent()
    presenter.show(nil)
    didDismiss()
    didHide()
    presenter.show(alert2)
    didShow()
    didPresent()

    assertWindowIsVisible(true)
    assertPresentedAlert(is: alert2)
    assertIsNotPerformingAction()
  }

  func testShowAnotherBeforeShowingWindow() {
    presenter.show(alert1)
    presenter.show(nil)
    presenter.show(alert2)
    didShow()
    didPresent()
    didDismiss()
    didPresent()

    assertWindowIsVisible(true)
    assertPresentedAlert(is: alert2)
    assertIsNotPerformingAction()
  }

  func testShowAnotherBeforePresentingController() {
    presenter.show(alert1)
    didShow()
    presenter.show(nil)
    presenter.show(alert2)
    didPresent()
    didDismiss()
    didPresent()

    assertWindowIsVisible(true)
    assertPresentedAlert(is: alert2)
    assertIsNotPerformingAction()
  }

  func testShowAnotherBeforeDismissingController() {
    presenter.show(alert1)
    didShow()
    didPresent()
    presenter.show(nil)
    presenter.show(alert2)
    didDismiss()
    didHide()
    didShow()
    didPresent()

    assertWindowIsVisible(true)
    assertPresentedAlert(is: alert2)
    assertIsNotPerformingAction()
  }

  func testShowAnotherBeforeHidingWindow() {
    presenter.show(alert1)
    didShow()
    didPresent()
    presenter.show(nil)
    didDismiss()
    presenter.show(alert2)
    didHide()
    didShow()
    didPresent()

    assertWindowIsVisible(true)
    assertPresentedAlert(is: alert2)
    assertIsNotPerformingAction()
  }
  
  private func assertWindowIsVisible(_ expected: Bool, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(window.isVisible, expected, "", file: file, line: line)
  }
  
  private func assertPresentedAlert(is expected: Alert?, file: StaticString = #file, line: UInt = #line) {
    if let controller = window.alertController {
      XCTAssertEqual(controller.alert, expected, "", file: file, line: line)
    }
    else {
      XCTAssertNil(expected, "", file: file, line: line)
    }
  }
  
  private func assertIsNotPerformingAction(file: StaticString = #file, line: UInt = #line) {
    XCTAssertFalse(window.isPerformingAction)
  }
  
  private func didShow(file: StaticString = #file, line: UInt = #line) {
    if !window.didShow() {
      XCTFail("", file: file, line: line)
    }
  }
  
  func didHide(file: StaticString = #file, line: UInt = #line) {
    if !window.didHide() {
      XCTFail("", file: file, line: line)
    }
  }
  
  func didPresent(file: StaticString = #file, line: UInt = #line) {
    if !window.didPresent() {
      XCTFail("", file: file, line: line)
    }
  }
  
  func didDismiss(file: StaticString = #file, line: UInt = #line) {
    if !window.didDismiss() {
      XCTFail("", file: file, line: line)
    }
  }
}

class AlertWindowSpy: AlertWindow {
  var isVisibleStub: Bool = false
  var alertControllerStub: AlertController?
  
  override var isVisible: Bool {
    return isVisibleStub
  }
  
  override var alertController: AlertController? {
    return alertControllerStub
  }
  
  private var isShowing = false
  private var isHiding = false
  private var isPresenting = false
  private var controlerToBePresented: AlertController?
  private var isDismissing = false
  
  override func show() {
    isShowing = true
  }
  
  override func hide() {
    isHiding = true
  }
  
  override func present(_ alertController: AlertController) {
    isPresenting = true
    controlerToBePresented = alertController
  }
  
  override func dismiss() {
    isDismissing = true
  }
  
  func didShow() -> Bool {
    guard isShowing else { return false }
    
    isVisibleStub = true
    isShowing = false
    completeCurrentAction()
    return true
  }
  
  func didHide() -> Bool {
    guard isHiding else { return false }
    
    isVisibleStub = false
    isHiding = false
    completeCurrentAction()
    return true
  }
  
  func didPresent() -> Bool {
    guard isPresenting else { return false }
    
    alertControllerStub = controlerToBePresented
    isPresenting = false
    completeCurrentAction()
    return true
  }
  
  func didDismiss() -> Bool {
    guard isDismissing else { return false }
    
    alertControllerStub = nil
    isDismissing = false
    completeCurrentAction()
    return true
  }
}
