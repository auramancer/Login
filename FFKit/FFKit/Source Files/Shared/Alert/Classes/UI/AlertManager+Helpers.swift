extension AlertManager {
  func showAlert(title: StringVarient?,
                 message: StringVarient?,
                 confirmButtonTitle: String?,
                 cancelButtonTitle: String?,
                 confirmAction: ((String?)->Void)?) {
    
    let cancelAction = AlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
    let confirmAction = AlertAction(title: confirmButtonTitle, style: .default) { _, input in
      confirmAction?(input)
    }
    let actions = cancelButtonTitle == nil ? [confirmAction] : [cancelAction, confirmAction]
    
    let alert = Alert(title: title,
                      message: message,
                      actions: actions)
    
    show(alert)
  }
}

extension UIViewController {
  func showOKAlert(title: String?, message: String?) {
    let alert = Alert.acknowledgement(title: title, message: message)
    
    AlertInteractor.shared.show(alert)
  }
  
  func showOKAlert(title: String?, attributedMessage: NSAttributedString?) {
    let alert = Alert.acknowledgement(title: title, message: attributedMessage)
    
    AlertInteractor.shared.show(alert)
  }
  
  func showActivityAlert(title: String?, message: String?) {
    let alert = Alert.activity(title: title, message: message)
    
    AlertInteractor.shared.show(alert)
  }
  
  func showAlert(title: String?,
                 message: String?,
                 confirmButtonTitle: String?,
                 cancelButtonTitle: String?,
                 confirmAction: ((String?)->Void)?) {
    AlertInteractor.shared.showAlert(title: title,
                                  message: message,
                                  confirmButtonTitle: confirmButtonTitle,
                                  cancelButtonTitle: cancelButtonTitle,
                                  confirmAction: confirmAction)
  }
  
  func showAlert(title: String?,
                 attributedMessage: NSAttributedString?,
                 confirmButtonTitle: String?,
                 cancelButtonTitle: String?,
                 confirmAction: ((String?)->Void)?) {
    AlertInteractor.shared.showAlert(title: title,
                                  message: attributedMessage,
                                  confirmButtonTitle: confirmButtonTitle,
                                  cancelButtonTitle: cancelButtonTitle,
                                  confirmAction: confirmAction)
  }
}

extension UIView {
  func showOKAlert(title: String?, message: String?) {
    let alert = Alert.acknowledgement(title: title, message: message)
    
    AlertInteractor.shared.show(alert)
  }
  
  func showOKAlert(title: String?, attributedMessage: NSAttributedString?) {
    let alert = Alert.acknowledgement(title: title, message: attributedMessage)
    
    AlertInteractor.shared.show(alert)
  }
  
  func showAlert(title: String?,
                 message: String?,
                 confirmButtonTitle: String?,
                 cancelButtonTitle: String?,
                 confirmAction: ((String?)->Void)?) {
    AlertInteractor.shared.showAlert(title: title,
                                  message: message,
                                  confirmButtonTitle: confirmButtonTitle,
                                  cancelButtonTitle: cancelButtonTitle,
                                  confirmAction: confirmAction)
  }
  
  func showAlert(title: String?,
                 attributedMessage: NSAttributedString?,
                 confirmButtonTitle: String?,
                 cancelButtonTitle: String?,
                 confirmAction: ((String?)->Void)?) {
    AlertInteractor.shared.showAlert(title: title,
                                  message: attributedMessage,
                                  confirmButtonTitle: confirmButtonTitle,
                                  cancelButtonTitle: cancelButtonTitle,
                                  confirmAction: confirmAction)
  }
}
