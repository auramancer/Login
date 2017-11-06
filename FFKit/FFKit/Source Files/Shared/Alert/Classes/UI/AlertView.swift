import UIKit

class AlertView: UIView {
  
  @IBOutlet weak var titleLabel: UILabel?
  @IBOutlet weak var messageLabel: UILabel?
  @IBOutlet weak var textField: UITextField?
  @IBOutlet var buttons: [UIButton]?
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
  
  @IBOutlet weak var visibleView: UIView?
  @IBOutlet weak var visibleViewBottom: NSLayoutConstraint?
  @IBOutlet weak var panelView: UIView?
  @IBOutlet weak var panelWidth: NSLayoutConstraint?
  @IBOutlet weak var panelHeight: NSLayoutConstraint?
  @IBOutlet weak var upperScrollView: UIScrollView?
  @IBOutlet weak var upperContentView: UIView?
  @IBOutlet weak var upperStackView: UIStackView?
  @IBOutlet weak var lowerView: UIView?
  @IBOutlet weak var buttonsView: UIView?
  @IBOutlet weak var buttonHeight: NSLayoutConstraint!
  @IBOutlet var extraViews: [UIView]?

  var appearance: AlertAppearance?
  
  func adjustVisibleView(basedOn keyboardFrame: CGRect) {
    visibleViewBottom?.constant = keyboardFrame.size.height + 20
  }
  
  func adjustPanel() {
    let visibleAreaHeight = visibleView?.frame.height ?? 0
    let upperContentHeight = upperContentView?.frame.height ?? 0
    let lowerContentHeight = lowerView?.frame.height ?? 0
    let extraContentHeight = extraViews?.reduce(0) { result, view in
      result + view.frame.height
      } ?? 0
    
    let diff = visibleAreaHeight - upperContentHeight - lowerContentHeight - extraContentHeight
    
    let newHeight = diff > 0 ? -diff : 0
    if let height = panelHeight?.constant, height != newHeight {
      panelHeight?.constant = newHeight
    }
  }
  
  func showTitle(_ title: StringVarient) {
    titleLabel?.isHidden = false
    titleLabel?.show(title)
  }
  
  func hideTitle() {
    titleLabel?.text = nil
    titleLabel?.isHidden = true
  }
  
  func showMessage(_ message: StringVarient) {
    messageLabel?.isHidden = false
    messageLabel?.show(message)
  }
  
  func hideMessage() {
    messageLabel?.text = nil
    messageLabel?.isHidden = true
  }
  
  func hideButtons() {
    buttonsView?.isHidden = true
  }
  
  func showTextField() {
    textField?.isHidden = false
  }
  
  func hideTextField() {
    textField?.isHidden = true
  }
  
  func showActivityIndicator() {
    activityIndicator?.isHidden = false
    activityIndicator?.startAnimating()
  }
  
  func hideActivityIndicator() {
    activityIndicator?.stopAnimating()
    activityIndicator?.isHidden = true
  }
}

extension AlertView {
  func customizeAppearance(_ appearance: AlertAppearance?) {
    self.appearance = appearance
    
    customizeBackground()
    customizePanel()
    customizeTitleLabel()
    customizeMessageLabel()
    customizeTextField()
    customizeActivityIndicator()
    customizeButtons()
  }
  
  private func customizeBackground() {
    if let color = appearance?.backgroundColor {
      backgroundColor = color
    }
  }
  
  private func customizePanel() {
    if let backgroundColor = appearance?.panelBackgroundColor {
      panelView?.backgroundColor = backgroundColor
    }
    
    if let cornerRadius = appearance?.panelCornerRadius {
      panelView?.layer.cornerRadius = cornerRadius
    }
    else {
      panelView?.layer.cornerRadius = 5
    }
    
    if let borderColor = appearance?.panelBorderColor {
      panelView?.layer.borderColor = borderColor.cgColor
    }
    
    if let borderWidth = appearance?.panelBorderWidth {
      panelView?.layer.borderWidth = borderWidth
    }
  }
  
  private func customizeTitleLabel() {
    if let textColor = appearance?.titleTextColor {
      titleLabel?.textColor = textColor
    }
    
    if let font = appearance?.titleFont {
      titleLabel?.font = font
    }
  }
  
  private func customizeMessageLabel() {
    if let textColor = appearance?.messageTextColor {
      messageLabel?.textColor = textColor
    }
    
    if let font = appearance?.messageFont {
      messageLabel?.font = font
    }
  }
  
  private func customizeTextField() {
  }
  
  private func customizeActivityIndicator() {
  }
  
  private func customizeButtons() {
    if let height = appearance?.buttonHeight {
      buttonHeight.constant = height
    }
    
    buttons?.forEach { button in
      if let backgroundImage = appearance?.buttonBackgroundImage {
        button.setBackgroundImage(backgroundImage, for: .normal)
      }
      
      if let textColor = appearance?.buttonTitleTextColor {
        button.setTitleColor(textColor, for: .normal)
      }
      
      if let font = appearance?.buttonTitleFont {
        button.titleLabel?.font = font
      }
    }
  }
}

extension UILabel {
  fileprivate func show(_ text: StringVarient?) {
    if let attributedText = text as? NSAttributedString {
      self.attributedText = attributedText
    }
    else {
      self.text = text as? String
    }
  }
}

class AlertButton: UIButton {
  var style: AlertActionStyle = .default
}
