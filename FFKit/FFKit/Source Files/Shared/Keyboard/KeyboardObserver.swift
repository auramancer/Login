import Foundation
import UIKit

extension Notification.Name {
  static let keyboardFrameDidChange = Notification.Name(rawValue: "keyboardFrameDidChange")
}

class KeyboardObserver {
  static let shared = KeyboardObserver()
  
  var keyboardFrame: CGRect = .zero
  
  init() {
    observe()
  }
  
  private func observe() {
    let center = NotificationCenter.default
    
    center.addObserver(self,
                       selector: #selector(keyboardWillShow(_:)),
                       name: .UIKeyboardWillShow,
                       object: nil)
    center.addObserver(self,
                       selector:#selector(keyboardWillHide(_:)),
                       name: .UIKeyboardWillHide,
                       object: nil)
  }
  
  @objc private func keyboardWillShow(_ notification: NSNotification) {
    guard let userInfo = notification.userInfo,
          let value = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
    
    keyboardFrame = value.cgRectValue
    
    print(keyboardFrame)
    
    notify()
  }
  
  @objc private func keyboardWillHide(_ notification: NSNotification) {
    keyboardFrame = .zero
    
    notify()
  }
  
  private func notify() {
    let center = NotificationCenter.default
   
    center.post(name: .keyboardFrameDidChange, object: keyboardFrame)
  }
}
