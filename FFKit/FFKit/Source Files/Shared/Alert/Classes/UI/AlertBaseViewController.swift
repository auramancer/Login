import UIKit

class AlertBaseViewController: UIViewController {
  override var prefersStatusBarHidden: Bool {
    return AlertManager.shared.prefersStatusBarHidden
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return AlertManager.shared.preferredStatusBarStyle
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return AlertManager.shared.supportedInterfaceOrientations
  }
}
