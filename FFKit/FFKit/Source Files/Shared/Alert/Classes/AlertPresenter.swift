class AlertPresenter {
  lazy var window = AlertWindow()
  var alert: Alert?
  private var isBusy = false
  
  func show(_ alert: Alert?) {
    self.alert = alert
    performAction()
  }
  
  private func performAction() {
    if isBusy {
      return
    }
    
    let currentAlert = window.alertController?.alert
    
    if currentAlert == alert {
      return
    }
    
    if currentAlert == nil {
      showAlert()
    }
    else if alert == nil {
      dismissAlert()
    }
    else {
      changeAlert()
    }
  }
  
  private func showAlert() {
    isBusy = true
    
    let controller = createAlertController()
    window.show { [weak self] in
      self?.window.presentAlertController(controller) { [weak self] in
        self?.completeCurrentAction()
      }
    }
  }
  
  private func dismissAlert() {
    isBusy = true
    
    window.dismissAlertController { [weak self] in
      print("did dismiss")
      self?.window.hide { [weak self] in
        print("did hide")
        self?.completeCurrentAction()
      }
    }
  }
  
  private func changeAlert() {
    isBusy = true
    
    let controller = createAlertController()
    window.dismissAlertController { [weak self] in
      self?.window.presentAlertController(controller) { [weak self] in
        self?.completeCurrentAction()
      }
    }
  }
  
  private func createAlertController() -> AlertController {
    return alert!.controllerInstantiater(alert!)
  }
  
  private func completeCurrentAction() {
    isBusy = false
    performAction()
  }
}
