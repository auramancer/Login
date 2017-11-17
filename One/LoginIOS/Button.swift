import UIKit

struct ColorWithState {
  var normal: UIColor
  var highlighted: UIColor
  var disabled: UIColor
}

struct ButtonConfiguration {
  var backgroundColor: ColorWithState
  var titleColor: ColorWithState
  var borderColor: ColorWithState
  var borderWidth: CGFloat
}

class Button: UIButton {
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.startAnimating()
    addView(indicator, toContainer: self)
    return indicator
  }()
  
  var shouldShowActivityIndicator = false {
    didSet {
      isEnabled = !shouldShowActivityIndicator
      stopActivity = !shouldShowActivityIndicator
    }
  }
  
  private var stopActivity = true {
    didSet {
      activityIndicator.isHidden = stopActivity
      stopActivity ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }
  }
  
  enum Style: Int {
    case primary = 0
    case secondary = 1
    case transparentWhite = 2
  }
  
  @IBInspectable var style: Int = Style.primary.rawValue {
    didSet {
      switch Style(rawValue: style)! {
      case .primary:
        configuration = Button.primaryConfiguration
      case .secondary:
        configuration = Button.secondaryConfiguration
      case .transparentWhite:
        configuration = Button.transparentWhiteConfiguration
      }
    }
  }
  
  var configuration = primaryConfiguration {
    didSet {
      configure()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    cornerRadius = 2
    configure()
  }

  override var isHighlighted: Bool {
    didSet {
      configure()
    }
  }
  
  override var isEnabled: Bool {
    didSet {
      configure()
    }
  }
  
  func configure() {
    if !isEnabled {
      backgroundColor = configuration.backgroundColor.disabled
      borderColor = configuration.borderColor.disabled
      setTitleColor(configuration.titleColor.disabled, for: .disabled)
    }
    else if isHighlighted {
      backgroundColor = configuration.backgroundColor.highlighted
      borderColor = configuration.borderColor.highlighted
      setTitleColor(configuration.titleColor.highlighted, for: .highlighted)
    }
    else {
      backgroundColor = configuration.backgroundColor.normal
      borderColor = configuration.borderColor.normal
      setTitleColor(configuration.titleColor.normal, for: .normal)
    }
    
    borderWidth = configuration.borderWidth
    titleLabel?.font = Font.futuraHeavy.of(size: Int(titleLabel?.font.pointSize ?? 16))
  }
  
  static let primaryConfiguration = ButtonConfiguration(
    backgroundColor: ColorWithState(normal: Color.primaryButtonBackgroundNormal.value,
                                    highlighted: Color.primaryButtonBackgroundHighlighted.value,
                                    disabled: Color.primaryButtonBackgroundDisabled.value),
    titleColor: ColorWithState(normal: .black,
                               highlighted: .black,
                               disabled: Color.primaryButtonTitleDisabled.value),
    borderColor: ColorWithState(normal: .clear,
                                highlighted: .clear,
                                disabled: .clear),
    borderWidth: 0)
  
  static let secondaryConfiguration = ButtonConfiguration(
    backgroundColor: ColorWithState(normal: .clear,
                                    highlighted: .clear,
                                    disabled: .clear),
    titleColor: ColorWithState(normal: .black,
                               highlighted: .black,
                               disabled: Color.secondaryButtonDisabled.value),
    borderColor: ColorWithState(normal: Color.secondaryButtonBorder.value,
                                highlighted: .black,
                                disabled: Color.secondaryButtonDisabled.value),
    borderWidth: 1)
  
  static let transparentWhiteConfiguration = ButtonConfiguration(
    backgroundColor: ColorWithState(normal: .clear,
                                    highlighted: .clear,
                                    disabled: .clear),
    titleColor: ColorWithState(normal: .white,
                               highlighted: .white,
                               disabled: Color.secondaryButtonDisabled.value),
    borderColor: ColorWithState(normal: Color.secondaryButtonBorder.value,
                                highlighted: .white,
                                disabled: Color.secondaryButtonDisabled.value),
    borderWidth: 1)
}

func addView(_ view: UIView, toContainer container: UIView) {
  view.translatesAutoresizingMaskIntoConstraints = false
  container.addSubview(view)
  
  let namedView = ["view": view]
  addConstraints(withVisualFormat: "H:|-0-[view]-0-|", views: namedView, to: container)
  addConstraints(withVisualFormat: "V:|-0-[view]-0-|", views: namedView, to: container)
}

func addConstraints(withVisualFormat format: String, views: [String : AnyObject], to superView: UIView) {
  let constraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: views)
  superView.addConstraints(constraints)
}


