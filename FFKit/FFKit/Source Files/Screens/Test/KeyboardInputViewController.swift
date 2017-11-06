import Foundation
import UIKit

protocol KeyboardInputViewControllerDelegate: class {
  func handleInput(_ input: String)
  func dismissKeyboardInputView()
}

class TestView: UIView {
  var textField: UITextField!
  var dismissButton: UIButton!
  
  override init(frame: CGRect) {
    textField = UITextField()
    dismissButton = UIButton(type: .custom)
    
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class KeyboardInputViewController: UIViewController, UITextFieldDelegate {
  var inputBar : TestView!
  
  weak var delegate: KeyboardInputViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.green
    
    observeKeyboard()
    addInputBar()
  }
  
  private func addInputBar() {
    inputBar = TestView(frame: defaultInputBarFrame)
    inputBar.textField.delegate = self
    inputBar.dismissButton.addTarget(self, action: #selector(didDismissKeyboard), for: .touchUpInside)
    
    view.addSubview(inputBar)
  }
  
  private var defaultInputBarFrame: CGRect {
    return CGRect(x: 0,
                  y: view.frame.size.height - 44,
                  width: view.frame.size.width,
                  height: 44)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    inputBar.textField.becomeFirstResponder()
    inputBar.alpha = 1
  }
  
  private func observeKeyboard() {
    let center = NotificationCenter.default
    
    center.addObserver(self,
                       selector: #selector(keyboardFrameDidChange(_:)),
                       name: .keyboardFrameDidChange,
                       object: nil)
  }
  
  var keyboardFrame = CGRect.zero
  
  @objc private func keyboardFrameDidChange(_ notification: NSNotification) {
    guard let value = notification.object as? NSValue else { return }
    
    keyboardFrame = value.cgRectValue
    keyboardFrameDidChange()
  }
  
  private func keyboardFrameDidChange() {
    UIView.animate(withDuration: 0.1,
                   animations: moveTextFieldWithKeyboard,
                   completion: didMoveTextField)
  }
  
  private func moveTextFieldWithKeyboard() {
    var frame = defaultInputBarFrame
    var origin = frame.origin
    origin.y -= keyboardFrame.size.height
    frame.origin = origin
    inputBar.frame = frame
    
    if keyboardFrame == .zero {
      inputBar.alpha = 0
    }
  }
  
  private func didMoveTextField(_: Bool) {
    if keyboardFrame == .zero {
      didDismissKeyboard()
    }
  }
  
  @objc private func didDismissKeyboard() {
    delegate?.dismissKeyboardInputView()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let input = textField.text {
      delegate?.handleInput(input)
      textField.text = nil
    }
    
    return false
  }
}
