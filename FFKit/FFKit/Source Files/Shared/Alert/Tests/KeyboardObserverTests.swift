import XCTest
@testable import FFKit

class KeyboardObserverTests: XCTestCase {
  private var observer: KeyboardObserver?
  private var keyboardFrame: CGRect?
  
  override func setUp() {
    super.setUp()
    
    observer = KeyboardObserver()
    keyboardFrame = nil
  }
  
  func testShowEventIsObserved() {
    let center = NotificationCenter.default
    center.addObserver(self,
                       selector: #selector(keyboardFrameWillChange),
                       name: .keyboardFrameWillChange,
                       object: nil)
    
    let newFrame = CGRect(x: 5, y: 6, width: 7, height: 8)
    let userInfo = [UIKeyboardFrameEndUserInfoKey : NSValue(cgRect: newFrame)]
    center.post(name: .UIKeyboardWillShow, object: nil, userInfo: userInfo)
    
    XCTAssertEqual(keyboardFrame, newFrame)
  }
  
  func testHideEventIsObserved() {
    let center = NotificationCenter.default
    center.addObserver(self,
                       selector: #selector(keyboardFrameWillChange),
                       name: .keyboardFrameWillChange,
                       object: nil)
    
    center.post(name: .UIKeyboardWillHide, object: nil)
    
    XCTAssertEqual(keyboardFrame, CGRect.zero)
  }
  
  @objc private func keyboardFrameWillChange(notification: Notification) {
    keyboardFrame = notification.object as? CGRect
  }
}

