import UIKit

class DigitalLoginViewController: UIViewController {
  var configurator: Configurator?
  
  var interactor: LoginInteractorInput?
  
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var usernameField: UITextField!
  @IBOutlet weak var passwordLabel: UILabel!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var fieldsStackView: UIStackView!
  @IBOutlet weak var logInButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpViews()
    
    configurator = Configurator(for: self)
    update()
  }
  
  private func setUpViews() {
    usernameField.addTarget(self, action: #selector(updateUsername), for: .editingChanged)
    passwordField.addTarget(self, action: #selector(updatePassword), for: .editingChanged)
  }
  
  private func update() {
    updateUsername()
    updatePassword()
  }
  
  @objc private func updateUsername() {
    interactor?.updateId(usernameField.text ?? "")
  }
  
  @objc private func updatePassword() {
    interactor?.updateCredential(passwordField.text ?? "")
  }
  
  @IBAction func didPressLogInButton(_ sender: Any) {
    interactor?.logIn()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    fieldsStackView.axis = size.width >= 480 ? .horizontal : .vertical
  }
}

extension DigitalLoginViewController: LoginPresenterOutput {
  func loginWasEnabled() {
    
  }
  
  func loginWasDisabled() {
    
  }
  
  func showActivityMessage(_: String?) {
    
  }
  
  func hideActivityMessage() {
    
  }
  
  func showErrorMessage(_: String) {
    
  }
  
  func hideErrorMessage() {
    
  }
  
  func navigate(to: LoginDestination) {
    
  }
  
  func leave() {
    
  }
}

extension DigitalLoginViewController {
  class Configurator {
    var presenter: LoginPresenter
    var interactor: DigitalLoginInteractor
    var service: DigitalLoginServiceStub
    
    init(for userInterface: DigitalLoginViewController) {
      interactor = DigitalLoginInteractor()
      service = DigitalLoginServiceStub()
      presenter = LoginPresenter()
      
      userInterface.interactor = interactor
      interactor.output = presenter
      interactor.service = service
      service.output = interactor
      presenter.output = userInterface
    }
  }
}
