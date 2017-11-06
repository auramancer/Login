import UIKit

class AlertWindow: UIWindow {
  
  var isVisible: Bool {
    return !isHidden
  }
  
  var alertController: AlertController? {
    return rootViewController?.presentedViewController as? AlertController
  }
  
  private var backgroundDidAppear = false
   var isPerformingAction = false
  private var actionCompletion: (() -> Void)?
  
  init() {
    super.init(frame: UIApplication.shared.keyWindow?.bounds ?? .zero)
    
    windowLevel = UIWindowLevelAlert
    
    rootViewController = createBackgroundViewController()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func createBackgroundViewController() -> UIViewController {
    let backgroundController = AlertBackgroundViewController()
    backgroundController.didAppear = { [weak self] in
      self?.backgroundDidAppear = true
      self?.completeCurrentAction()
    }
    return backgroundController
  }
  
  func show(completionHandler: @escaping () -> Void) {
    guard !isVisible else { return }
    
    performAction(completionHandler: completionHandler) { [weak self] in
      self?.show()
    }
  }
  
  func hide(completionHandler: @escaping () -> Void) {
    guard isVisible else { return }
    
    performAction(completionHandler: completionHandler) { [weak self] in
      self?.hide()
    }
  }
  
  func presentAlertController(_ alertController: AlertController, completionHandler: @escaping () -> Void) {
    guard self.alertController == nil else { return }
    
    performAction(completionHandler: completionHandler) { [weak self] in
      self?.present(alertController)
    }
  }
  
  func dismissAlertController(completionHandler: @escaping () -> Void) {
    guard alertController != nil else { return }
    
    performAction(completionHandler: completionHandler) { [weak self] in
      self?.dismiss()
    }
  }
  
  func show() {
    isHidden = false
    
    if backgroundDidAppear {
      completeCurrentAction()
    }
  }
  
  func hide() {
    isHidden = true
    
    completeCurrentAction()
  }
  
  func present(_ alertController: AlertController) {
    alertController.modalTransitionStyle = .crossDissolve
    
    rootViewController?.present(alertController, animated: true) { [weak self] in
      self?.completeCurrentAction()
    }
  }
  
  func dismiss() {
    rootViewController?.dismiss(animated: true) {  [weak self] in
      self?.completeCurrentAction()
    }
  }
  
  private func performAction(completionHandler: @escaping () -> Void, action: () -> Void) {
    if isPerformingAction {
      return
    }
    isPerformingAction = true
    
    self.actionCompletion = { [weak self] in
      self?.isPerformingAction = false
      completionHandler()
    }
    
    action()
  }
  
  func completeCurrentAction() {
    actionCompletion?()
  }
}

class AlertBackgroundViewController: AlertBaseViewController {
  var didAppear: (() -> Void)?
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    didAppear?()
  }
}
