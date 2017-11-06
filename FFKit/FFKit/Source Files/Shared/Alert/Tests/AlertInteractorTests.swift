import XCTest
@testable import FFKit

class AlertInteractorTests: XCTestCase {
  private var interactor: AlertInteractor!
  private var presenter: AlertPresenterSpy!
  
  let alert1 = Alert(title: "Title1", message: "Message1", actions: [])
  let alert2 = Alert(title: "Title2", message: "Message2", actions: [])
  
  override func setUp() {
    super.setUp()
    
    presenter = AlertPresenterSpy()
    
    interactor = AlertInteractor()
    interactor.presenter = presenter
  }
  
  func testAlertIsShowedWhenNotShowingOtherAlert() {
    interactor.show(alert1)
    
    assertVisibleAlert(is: alert1)
  }
  
  func testAlertIsInQueueWhenShowingOtherAlert() {
    interactor.show(alert1)
    interactor.show(alert2)
    
    assertVisibleAlert(is: alert1)
    assertQueuedAlerts(are: [alert1, alert2])
  }
  
  func testAlertIsDiscardedWhenShowingSameAlert() {
    interactor.show(alert1)
    interactor.show(alert1)
    
    assertVisibleAlert(is: alert1)
    assertQueuedAlerts(are: [alert1])
  }
  
  func testNoAlertIsPresentedAfterRemovingLastOne() {
    interactor.show(alert1)
    interactor.close(alert1)
    
    assertQueuedAlerts(are: [])
    assertVisibleAlert(is: nil)
  }
  
  func testNextAlertIsPresentedAfterRemovingCurrentOne() {
    interactor.show(alert1)
    interactor.show(alert2)
    interactor.close(alert1)
    
    assertQueuedAlerts(are: [alert2])
    assertVisibleAlert(is: alert2)
  }
  
  func testRemoveAlertInQueue() {
    interactor.show(alert1)
    interactor.show(alert2)
    interactor.close(alert2)
    
    assertQueuedAlerts(are: [alert1])
    assertVisibleAlert(is: alert1)
  }
  
  private func assertVisibleAlert(is alert: Alert?) {
    XCTAssertEqual(presenter.alert, alert)
  }
  
  private func assertQueuedAlerts(are alerts: [Alert]) {
    XCTAssertEqual(interactor.alerts, alerts)
  }
}

