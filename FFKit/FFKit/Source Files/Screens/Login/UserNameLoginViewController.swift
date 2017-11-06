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
    refresh()
  }
  
  private func setUpViews() {
    userNameField.delegate = self
    passwordField.delegate = self
  }
  
  private func refresh() {
    interactor?.refresh()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    fieldsStackView.axis = size.width >= 480 ? .horizontal : .vertical
  }
  
  @IBAction func didPressLogInButton(_ sender: Any) {
    interactor?.logIn()
  }
}

extension UserNameLoginViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    if let oldText = textField.text as NSString? {
      let newText = oldText.replacingCharacters(in: range, with: string)
      attempToChangeText(of: textField, to: newText)
    }
    
    return false
  }
  
  func attempToChangeText(of textField: UITextField, to newText: String) {
    if textField === userNameField {
      interactor?.attempToChangeUserName(to: newText)
    }
    else if textField === passwordField {
      interactor?.attempToChangePassword(to: newText)
    }
  }
}

extension UserNameLoginViewController: UserNameLoginPresenterOutput {
  func showUserName(_ userName: String) {
    userNameField.text = userName
  }
  
  func showPassword(_ password: String) {
    passwordField.text = password
  }
  
  func showLogInIsEnabled(_ isEnabled: Bool) {
    logInButton.isEnabled = isEnabled
  }
  
  func showActivityMessage(_: String) {
    
  }
  
  func showErrorMessage(_: String) {
    
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
  
  func logIn(withUserName: String, password: String) {
    
  }
}
