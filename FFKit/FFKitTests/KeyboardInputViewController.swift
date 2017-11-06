import Foundation
import UIKit

protocol KeyboardInputViewControllerDelegate: class {
  func handleInput(_ input: String)
  func dismissKeyboardInputView()
}

class KeyboardInputView: UIView {
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var dismissButton: UIButton!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  private func commonInit() {
    Bundle.main.loadNibNamed("KeyboardInputView",
                             owner: self,
                             options: nil)
    addSubview(contentView)
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
}

class KeyboardInputViewController: UIViewController, UITextFieldDelegate {
  var inputBar : KeyboardInputView!
  
  weak var delegate: KeyboardInputViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    observeKeyboard()
    addInputView()
  }
  
  private func addInputView() {
    inputBar = KeyboardInputView(frame: defaultInputViewFrame)
    inputBar.textField.delegate = self
    inputBar.dismissButton.addTarget(self, action: #selector(didDismissKeyboard), for: .touchUpInside)
    
    view.addSubview(inputBar)
  }
  
  private var defaultInputViewFrame: CGRect {
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
    var frame = defaultInputViewFrame
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
