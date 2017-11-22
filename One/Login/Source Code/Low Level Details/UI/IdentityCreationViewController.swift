import UIKit

class IdentityCreationViewController: UIViewController {
  var configurator: Configurator?
  
  weak var interactor: IdentityCreationInteractorInput?
  
  @IBOutlet weak var messageView: UIView!
  @IBOutlet weak var messageLabel: UILabel!
  
  @IBOutlet weak var identifierField: UITextField!
  @IBOutlet weak var identifierRuleLabel: UILabel!
  @IBOutlet weak var credentialField: UITextField!
  @IBOutlet weak var credentialRuleLabel: UILabel!
  
  @IBOutlet weak var fieldsStackView: UIStackView!
  
  @IBOutlet weak var saveButton: Button!
  
  var retailIdentity: RetailIdentity!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpViews()
    
    configurator = Configurator(for: self)
    interactor?.load(withRetailIdentity: retailIdentity)
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
  
  @IBAction func didPressSaveButton(_ sender: Any) {
    interactor?.create()
  }
}

extension IdentityCreationViewController: IdentityCreationPresenterOutput {
  func changeCanCreate(to canCreate: Bool) {
    saveButton.isEnabled = canCreate
  }
  
  func changeIsCreating(to isCreating: Bool) {
    saveButton.shouldShowActivityIndicator = isCreating
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
  
  func leave() {
    LoginRouter.leave(from: self)
  }
}

extension IdentityCreationViewController {
  class Configurator {
    var interactor: IdentityCreationInteractor
    var service: IdentityCreationServiceStub
    var presenter: IdentityCreationPresenter
    
    init(for userInterface: IdentityCreationViewController) {
      interactor = IdentityCreationInteractor()
      service = IdentityCreationServiceStub()
      presenter = IdentityCreationPresenter()
      
      userInterface.interactor = interactor
      interactor.output = presenter
      interactor.service = service
      service.output = interactor
      presenter.output = userInterface
    }
  }
}
