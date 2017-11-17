import UIKit

extension UIView {
  
  @IBInspectable var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }
  
  @IBInspectable var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable var borderColor: UIColor? {
    get {
      return UIColor(cgColor: layer.borderColor!)
    }
    set {
      layer.borderColor = newValue?.cgColor
    }
  }
  
  // MARK: Constraints
  
  func matchConstraints(to superView: UIView) {
    let margins = superView.layoutMarginsGuide
    
    leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: -superView.layoutMargins.left).isActive = true
    trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: superView.layoutMargins.right).isActive = true
    topAnchor.constraint(equalTo: margins.topAnchor, constant: -superView.layoutMargins.top).isActive = true
    bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: superView.layoutMargins.bottom).isActive = true
  }
  
}
