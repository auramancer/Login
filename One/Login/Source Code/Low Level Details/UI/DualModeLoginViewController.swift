import UIKit

class DualModeLoginViewController: UIViewController {
  var configurator: Configurator?
  
  weak var interactor: DualModeLoginInteractorInput?
  
  @IBOutlet weak var messageView: UIView!
  @IBOutlet weak var messageLabel: UILabel!
  
  @IBOutlet weak var identifierTitleLabel: UILabel!
  @IBOutlet weak var identifierField: UITextField!
  @IBOutlet var forgottenIdentifierButton: UIButton!
  
  @IBOutlet weak var credentialTitleLabel: UILabel!
  @IBOutlet weak var credentialField: UITextField!
  @IBOutlet var forgottenCredentialButton: UIButton!
  
  @IBOutlet weak var fieldsStackView: UIStackView!
  @IBOutlet weak var rememberMeCheckbox: Checkbox!
  
  @IBOutlet weak var logInButton: Button!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpViews()
    
    configurator = Configurator(for: self)
    interactor?.load()
  }
  
  fileprivate func setUpViews() {
    identifierField.addTarget(self, action: #selector(identifierDidChange), for: .editingChanged)
    credentialField.addTarget(self, action: #selector(credentialDidChange), for: .editingChanged)
    
    messageView.isHidden = true
    messageLabel.text = nil
  }
  
  @objc fileprivate func identifierDidChange() {
    interactor?.changeIdentifier(to: identifierField.text ?? "")
  }
  
  @objc fileprivate func credentialDidChange() {
    interactor?.changeCredential(to: credentialField.text ?? "")
  }
  
  @IBAction func didPressRememberMeCheckbox(_ sender: Any) {
    interactor?.changeShouldRememberIdentity(to: rememberMeCheckbox.isChecked)
  }
  
  @IBAction func didPressLogInButton(_ sender: Any) {
    interactor?.logIn()
  }
  
  @IBAction func didPressForgottenIdButton(_ sender: Any) {
    interactor?.helpWithIdentifier()
  }
  
  @IBAction func didPressForgottenCredentialButton(_ sender: Any) {
    interactor?.helpWithCredential()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    fieldsStackView.axis = size.width >= 480 ? .horizontal : .vertical
  }
  
  fileprivate func updateLabelsAnimated(with wording: DualModeLoginWording) {
    updateLabel(identifierTitleLabel, withText: wording.id)
    updateLabel(credentialTitleLabel, withText: wording.credential)
  }
  
  fileprivate func updateLabel(_ label: UILabel,
                           withText text: String,
                           hideDuration: TimeInterval = 0.15,
                           showDuration: TimeInterval = 0.15) {
    UIView.animate(withDuration: hideDuration,
                   delay: 0,
                   options: [],
                   animations: { label.alpha = 0 },
                   completion: { _ in
                    label.text = text
                    UIView.animate(withDuration: showDuration,
                                   delay: 0.03,
                                   options: [],
                                   animations: { label.alpha = 1 },
                                   completion: nil)
    })
  }
  
  fileprivate func updateLabels(with wording: DualModeLoginWording) {
    identifierTitleLabel.text = wording.id
    credentialTitleLabel.text = wording.credential
  }
  
  fileprivate func changeAttributedTitle(of button: UIButton, to newTitle: String) {
    guard let attributedTitle = button.attributedTitle(for: .normal) else { return }
    
    let mutableAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
    mutableAttributedTitle.replaceCharacters(in: NSMakeRange(0, mutableAttributedTitle.length), with: newTitle)
    button.setAttributedTitle(mutableAttributedTitle, for: .normal)
  }
}

extension DualModeLoginViewController: DualModeLoginPresenterOutput {
  func changeIdentifier(to identifier: String) {
    identifierField.text = identifier
  }
  
  func changeCredential(to credential: String) {
    credentialField.text = credential
  }
  
  func changeWording(to wording: DualModeLoginWording) {
    updateLabelsAnimated(with: wording)
    changeAttributedTitle(of: forgottenIdentifierButton, to: wording.forgottenIdentifier)
    changeAttributedTitle(of: forgottenCredentialButton, to: wording.forgottenCredential)
  }
  
  func changeCanLogin(to canLogin: Bool) {
    logInButton.isEnabled = canLogin
  }
  
  func changeIsLoggingIn(to isLoggingIn: Bool) {
    logInButton.shouldShowActivityIndicator = isLoggingIn
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
  
  func goToHelpPage(for help: LoginHelp) {
    LoginRouter.goToHelpPage(from: self, for: help)
  }
  
  func goToVerificationPage(withIdentity identity: RetailIdentity) {
    LoginRouter.goToVerificationPage(from: self, withIdentity: identity)
  }
  
  func leave() {
    LoginRouter.leave(from: self)
  }
}

extension DualModeLoginViewController {
  class Configurator {
    var interactor: DualModeLoginInteractor
    var service: DualModeLoginServiceStub
    var presenter: DualModeLoginPresenter
    
    init(for userInterface: DualModeLoginViewController) {
      interactor = DualModeLoginInteractor()
      service = DualModeLoginServiceStub()
      presenter = DualModeLoginPresenter()
      
      userInterface.interactor = interactor
      interactor.output = presenter
      interactor.service = service
      service.output = interactor
      presenter.output = userInterface
    }
  }
}
