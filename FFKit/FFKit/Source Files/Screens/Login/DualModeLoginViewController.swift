import UIKit

class DualModeLoginViewController: UIViewController {
  var configurator: Configurator?
  
  weak var interactor: LoginInteractorInput?
  
  @IBOutlet weak var idTitleLabel: UILabel!
  @IBOutlet weak var idField: UITextField!
  @IBOutlet var forgottenIdButton: UIButton!
  
  @IBOutlet weak var secretTitleLabel: UILabel!
  @IBOutlet weak var secretField: UITextField!
  @IBOutlet var forgottenSecretButton: UIButton!
  
  @IBOutlet weak var fieldsStackView: UIStackView!
  
  @IBOutlet weak var logInButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpViews()
    
    configurator = Configurator(for: self)
    update()
  }
  
  private func setUpViews() {
    idField.addTarget(self, action: #selector(updateId), for: .editingChanged)
    secretField.addTarget(self, action: #selector(updateSecret), for: .editingChanged)
  }
  
  private func update() {
    updateId()
    updateSecret()
  }
  
  @objc private func updateId() {
    interactor?.updateId(idField.text ?? "")
  }
  
  @objc private func updateSecret() {
    interactor?.updateSecret(secretField.text ?? "")
  }
  
  @IBAction func didPressLogInButton(_ sender: Any) {
    interactor?.logIn()
  }
  
  @IBAction func didPressForgottenIdButton(_ sender: Any) {
    interactor?.helpWithId()
  }
  
  @IBAction func didPressForgottenSecretButton(_ sender: Any) {
    interactor?.helpWithSecret()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    fieldsStackView.axis = size.width >= 480 ? .horizontal : .vertical
  }
}

extension DualModeLoginViewController: DualModeLoginPresenterOutput {
  func loginWasEnabled() {
    logInButton.isEnabled = true
  }
  
  func loginWasDisabled() {
    logInButton.isEnabled = false
  }
  
  func showActivityMessage(_: String?) {
  }
  
  func hideActivityMessage() {
  }
  
  func showErrorMessage(_ error: String?) {
  }
  
  func hideErrorMessage() {
  }
  
  func leave() {
  }
  
  func navigate(to destination: LoginDestination) {
    switch destination {
    case .forgottenUsername:
      break
    case .forgottenPassword:
      break
    case .forgottenMembershipCardNumber:
      break
    case .forgottenPIN:
      break
    default:
      break
    }
  }
  
  func updateWording(_ wording: DualModeLoginWording) {
    updateLabelsAnimated(with: wording)
    changeAttributedTitle(of: forgottenIdButton, to: wording.forgottenId)
    changeAttributedTitle(of: forgottenSecretButton, to: wording.forgottenSecret)
  }
  
  private func updateLabelsAnimated(with wording: DualModeLoginWording) {
    updateLabel(idTitleLabel, withText: wording.id)
    updateLabel(secretTitleLabel, withText: wording.secret)
  }
  
  private func updateLabel(_ label: UILabel,
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
  
  private func updateLabels(with wording: DualModeLoginWording) {
    idTitleLabel.text = wording.id
    secretTitleLabel.text = wording.secret
  }
  
  private func changeAttributedTitle(of button: UIButton, to newTitle: String) {
    guard let attributedTitle = button.attributedTitle(for: .normal) else { return }
    
    let mutableAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
    mutableAttributedTitle.replaceCharacters(in: NSMakeRange(0, mutableAttributedTitle.length), with: newTitle)
    button.setAttributedTitle(mutableAttributedTitle, for: .normal)
  }
}

extension DualModeLoginViewController {
  class Configurator {
    var presenter: DualModeLoginPresenter
    var interactor: DualModeLoginInteractor
    var service: DualModeLoginServiceStub
    
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
