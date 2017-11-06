import UIKit

class AlertManager {
  static let shared = AlertManager()
  
  lazy var interactor = AlertInteractor()

  var appearance: AlertAppearance?
  var navigationController: UINavigationController?
  
  func show(_ alert: Alert) {
    interactor.show(alert)
  }
  
  func close(_ alert: Alert) {
    interactor.close(alert)
  }
  
  var prefersStatusBarHidden: Bool {
    let topViewController = navigationController?.presentedViewController ?? navigationController?.topViewController
    
    return topViewController?.prefersStatusBarHidden ?? false
  }
  
  var preferredStatusBarStyle: UIStatusBarStyle {
    let topViewController = navigationController?.presentedViewController ?? navigationController?.topViewController
    
    return topViewController?.preferredStatusBarStyle ?? .default
  }
  
  var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    let topViewController = navigationController?.presentedViewController ?? navigationController
    
    return topViewController?.supportedInterfaceOrientations ?? .landscape
  }
}

