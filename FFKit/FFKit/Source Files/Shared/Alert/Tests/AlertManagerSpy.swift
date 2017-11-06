@testable import FFKit

class AlertInteractorSpy: AlertInteractor {
  override init() {
    super.init()
    
    presenter = AlertPresenterSpy()
  }
}

class AlertPresenterSpy: AlertPresenter {
  var dismissedAlerts = [Alert]()
  
  override func show(_ alert: Alert?) {
    if let current = alert {
      dismissedAlerts.append(current)
    }
    self.alert = alert
  }
}
