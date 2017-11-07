import UIKit

class UserNameLoginViewController: UIViewController {
  var configurator: UserNameLoginViewConfigurator?
  
  weak var interactor: UserNameLoginInteractorInput?
  
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userNameField: UITextField!
  @IBOutlet weak var passwordLabel: UILabel!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var fieldsStackView: UIStackView!
  @IBOutlet weak var logInButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUpViews()
    
    configurator = UserNameLoginViewConfigurator(for: self)
    updateDetails()
  }
  
  private func setUpViews() {
    observeDetailInputField(userNameField)
    observeDetailInputField(passwordField)
  }
  
  private func observeDetailInputField(_ field: UITextField) {
    field.addTarget(self, action: #selector(updateDetails), for: .editingChanged)
  }
  
  @objc private func updateDetails() {
    let details = UserNameLoginDetails(userName: userName, password: password)
    interactor?.updateDetail(details)
  }
  
  private var userName: String {
    return userNameField.text ?? ""
  }
  
  private var password: String {
    return passwordField.text ?? ""
  }
  
  @IBAction func didPressLogInButton(_ sender: Any) {
    interactor?.logIn()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    fieldsStackView.axis = size.width >= 480 ? .horizontal : .vertical
  }
}

extension UserNameLoginViewController: UserNameLoginPresenterOutput {
  func setLogInEnabled(to isEnabled: Bool) {
    logInButton.isEnabled = isEnabled
  }
  
  func showActivityMessage(_: String?) {
    
  }
  
  func hideActivityMessage() {
    
  }
  
  func showErrorMessage(_: String?) {
    
  }
  
  func hideErrorMessage() {
    
  }
  
  func close() {
    
  }
}

class UserNameLoginViewConfigurator {
  var viewController: UserNameLoginViewController
  var presenter: UserNameLoginPresenter
  var interactor: UserNameLoginInteractor
  var service: UserNameLoginService
  
  init(for viewController: UserNameLoginViewController) {
    self.viewController = viewController
    interactor = UserNameLoginInteractor()
    presenter = UserNameLoginPresenter()
    service = UserNameLoginService()
    
    viewController.interactor = interactor
    interactor.output = presenter
    interactor.service = service
    presenter.output = viewController
  }
}

class UserNameLoginService: UserNameLoginServiceInput {
  weak var output: UserNameLoginServiceOutput?
  
  func logIn(withDetails: UserNameLoginDetails) {
    print("Logging in")
  }
}
