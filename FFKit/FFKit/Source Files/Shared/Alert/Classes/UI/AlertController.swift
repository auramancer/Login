import UIKit

typealias AlertControllerInstantiater = (Alert) -> AlertController

protocol AlertControllerDelegate: class {
  func remove(_ alert: Alert, action: AlertAction?, input: String?)
}

class AlertController: AlertBaseViewController {
  var alert: Alert!
  weak var delegate: AlertControllerDelegate?
  var appearance: AlertAppearance?
  
  var keyboardShowed = false
  
  var alertView: AlertView? {
    return view as? AlertView
  }
  
  init(nibName: String? = "AlertView") {
    super.init(nibName: nibName, bundle: nil)
    
    appearance = AlertManager.shared.appearance
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    alertView?.customizeAppearance(appearance)
    
    observeKeyboard()
    
    scheduleAutoClose()
  }
  
  private func scheduleAutoClose() {
    guard let time = alert.timeUntilAutoClose else { return }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(time))) { [weak self] in
      self?.close(nil)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    adjustViewForKeyboard()
    setUpAlertView()
  }
  
  private func setUpAlertView() {
    setUpTitleLabel()
    setUpMessageLabel()
    setUpTextField()
    setUpButtons()
    setUpActivityIndicator()
  }
  
  func setUpTitleLabel() {
    if let title = alert.title {
      alertView?.showTitle(title)
    }
    else {
      alertView?.hideTitle()
    }
  }
  
  func setUpMessageLabel() {
    if let message = alert.message {
      alertView?.showMessage(message)
    }
    else {
      alertView?.hideMessage()
    }
  }
  
  func setUpTextField() {
    guard let textField = alertView?.textField else { return }
    
    textField.isHidden = !alert.needsInput
    textField.delegate = self
  }
  
  func setUpButtons() {
    guard let buttons = alertView?.buttons else { return }
    let actions = alert.actions
    
    if actions.count == 0 {
      alertView?.hideButtons()
    }
    else {
      setUpButtons(buttons, withActions: actions)
    }
  }
  
  func setUpButtons(_ buttons: [UIButton], withActions actions: [AlertAction]) {
    for (index, button) in buttons.enumerated() {
      
      if index >= alert.actions.count {
        button.isHidden = true
      }
      else {
        let action = alert.actions[index]
        setUpButton(button, withAction: action)
      }
    }
  }
  
  func setUpButton(_ button: UIButton, withAction action: AlertAction) {
    button.isHidden = false
    button.setTitle(action.title, for: .normal)
    button.isEnabled = action.style == .cancel || shouldEnableButtons
    
    if let customize = appearance?.buttonCustomizer {
      customize(button, action.style)
    }
  }
  
  var shouldEnableButtons: Bool {
    guard let validate = alert.inputValidator,
      let input = alertView?.textField?.text else { return true }
    
    return validate(input)
  }
  
  func setUpActivityIndicator() {
    if alert.activityIsInProgress {
      alertView?.showActivityIndicator()
    }
    else {
      alertView?.hideActivityIndicator()
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    alertView?.adjustPanel()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    showKeyboardForTextField()
  }
  
  private func showKeyboardForTextField() {
    if !keyboardShowed, let textField = alertView?.textField, !textField.isHidden {
      textField.becomeFirstResponder()
      keyboardShowed = true
    }
  }
  
  @IBAction func close(_ sender: Any?) {
    if let selectedAction = action(for: sender) {
      selectedAction.handler?(selectedAction, input)
    }
    
    AlertManager.shared.close(alert)
  }
  
  private func action(for button: Any?) -> AlertAction? {
    if let buttons = alertView?.buttons,
      let button = button as? UIButton,
      let index = buttons.index(of: button) {
      return alert.actions[index]
    }
    
    return nil
  }
  
  private var input: String? {
    return alertView?.textField?.text
  }
}

extension AlertController {
  fileprivate func observeKeyboard() {
    let center = NotificationCenter.default
    
    center.addObserver(self,
                       selector: #selector(keyboardFrameWillChange(_:)),
                       name: .keyboardFrameWillChange,
                       object: nil)
  }
  
  fileprivate func adjustViewForKeyboard() {
    keyboardFrameWillChange(to: KeyboardObserver.shared.keyboardFrame)
  }
  
  @objc private func keyboardFrameWillChange(_ notification: NSNotification) {
    guard let value = notification.object as? NSValue else { return }
    
    keyboardFrameWillChange(to: value.cgRectValue)
  }
  
  private func keyboardFrameWillChange(to rect: CGRect) {
    alertView?.adjustVisibleView(basedOn: rect)
  }
}

extension AlertController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let validate = alert.inputValidator else { return true }
    
    let oldText = textField.text
    let newText = (oldText as NSString?)?.replacingCharacters(in: range, with: string)
    
    let wasValid = validate(oldText)
    let isValid = validate(newText)
    
    if wasValid != isValid {
      if isValid {
        enableButtons()
      }
      else {
        disableButtons()
      }
    }
    
    return true
  }
  
  private func enableButtons() {
    guard let buttons = alertView?.buttons else { return }
    
    buttons.forEach { $0.isEnabled = true }
  }
  
  private func disableButtons() {
    guard let buttons = alertView?.buttons else { return }
    
    for (index, action) in alert.actions.enumerated() {
      guard index < buttons.count else { return }
      let button = buttons[index]
      
      button.isEnabled = action.style == .cancel || alert.inputValidator == nil
    }
  }
}
