import Foundation
import UIKit

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
//    Bundle.main.loadNibNamed("KeyboardInputView",
//                             owner: self,
//                             options: nil)
//    addSubview(contentView)
//    contentView.frame = self.bounds
//    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
}
