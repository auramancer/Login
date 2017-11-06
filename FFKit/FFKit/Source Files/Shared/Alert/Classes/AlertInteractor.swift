class AlertInteractor {
  lazy var presenter = AlertPresenter()
  
  var alerts = [Alert]()
  var firstAlertDidChange = false
  
  func show(_ alert: Alert) {
    add(alert)
    
    if firstAlertDidChange {
      presenter.show(alert)
      firstAlertDidChange = false
    }
  }
  
  func close(_ alert: Alert) {
    remove(alert)
    
    if firstAlertDidChange {
      presenter.show(alerts.first)
      firstAlertDidChange = false
    }
  }
  
  private func add(_ alert: Alert) {
    guard !alerts.contains(alert) else { return }
    
    alerts.append(alert)
    firstAlertDidChange = alerts.count == 1
  }
  
  private func remove(_ alert: Alert) {
    guard let index = alerts.index(of: alert) else { return }
    
    alerts.remove(at: index)
    firstAlertDidChange = index == 0
  }
}

extension Alert: Equatable {
  static func == (lhs: Alert, rhs: Alert) -> Bool {
    return lhs.title?.string == rhs.title?.string
      && lhs.message?.string == rhs.message?.string
  }
}
