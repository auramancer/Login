import UIKit

class LoginVerificationViewController: UIViewController {
  var configurator: Configurator?
  
  var interactor: LoginVerificationInteractorInput?
  
  @IBOutlet weak var messageView: UIView!
  @IBOutlet weak var messageLabel: UILabel!
  
  @IBOutlet weak var codeField: UITextField!
  
  @IBOutlet weak var resendButton: UIButton!
  @IBOutlet weak var verifyButton: Button!
  
  var retailIdentity: RetailIdentity!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpViews()
    
    configurator = Configurator(for: self)
    interactor?.load(withIdentity: retailIdentity)
  }
  
  fileprivate func setUpViews() {
    codeField.addTarget(self, action: #selector(codeDidChange), for: .editingChanged)
    
    messageView.isHidden = true
    messageLabel.text = nil
  }
  
  @objc fileprivate func codeDidChange() {
    interactor?.changeCode(to: codeField.text ?? "")
  }
  
  @IBAction func didPressVerifyButton(_ sender: Any) {
    interactor?.verify()
  }
  
  @IBAction func didPressResendButton(_ sender: Any) {
    interactor?.resendCode(confirmed: false)
  }
}

extension LoginVerificationViewController: LoginVerificationPresenterOutput {
  func changeCanVerify(to canVerify: Bool) {
    verifyButton.isEnabled = canVerify
  }
  
  func changeIsVerifying(to isVerifying: Bool) {
    verifyButton.shouldShowActivityIndicator = isVerifying
  }
  
  func showMessage(_ message: LoginMessage) {
    messageLabel.text = message.text
    
    UIView.animate(withDuration: 0.15) { [weak self] in
      self?.messageView.backgroundColor = message.style == .error ? Color.salmon.value : Color.blueText.value
      self?.messageView.alpha = 1
      self?.messageView.isHidden = false
    }
  }
  
  func clearMessage() {
    messageLabel.text = nil
    
    UIView.animate(withDuration: 0.15) { [weak self] in
      self?.messageView.alpha = 0
      self?.messageView.isHidden = true
    }
  }
  
  func showResendCodeConfirmaiton(_ alertData: ResendCodeConfirmaiton) {
//    let confirmAction = AlertAction(title: alertData.confirmActionTitle) { [weak self] _ in
//      self?.interactor?.resendCode(confirmed: true)
//    }
//    let cancelAction = AlertAction(title: "Cancel") { _ in }
//    let alert = Alert(title: nil, content: alertData.message, actions: [confirmAction, cancelAction])
//    showAlert(alert)
  }
  
  func goToIdentityCreationPage(withIdentity identity: RetailIdentity) {
    LoginRouter.goToIdentityCreationPage(from: self, withIdentity: identity)
  }
  
  func leave() {
    LoginRouter.leave(from: self)
  }
}

extension LoginVerificationViewController {
  class Configurator {
    var interactor: LoginVerificationInteractor
    var service: LoginVerificationServiceStub
    var presenter: LoginVerificationPresenter
    
    init(for userInterface: LoginVerificationViewController) {
      interactor = LoginVerificationInteractor()
      service = LoginVerificationServiceStub()
      presenter = LoginVerificationPresenter()
      
      userInterface.interactor = interactor
      interactor.output = presenter
      interactor.loginService = service
      interactor.codeService = service
      service.output = interactor
      presenter.output = userInterface
    }
  }
}

