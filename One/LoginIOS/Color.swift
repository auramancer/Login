import UIKit

struct RGB {
  let red: Double
  let green: Double
  let blue: Double
}

extension UIColor {
  
  private var coreColor: CIColor {
    return CIColor(color: self)
  }
  
  var components: RGB {
    let color = coreColor
    return RGB(red: Double(color.red * 255), green: Double(color.green * 255), blue: Double(color.blue * 255))
  }
}

enum Color {
  case lightText
  case lightMediumText
  case darkText
  case darkMediumText
  case errorText
  case circle
  case background
  case shadeBackground
  case lightBackground
  case blueText
  case lightGray
  case primaryButtonBackgroundNormal
  case primaryButtonBackgroundHighlighted
  case primaryButtonBackgroundDisabled
  case primaryButtonTitleDisabled
  case secondaryButtonDisabled
  case secondaryButtonBorder
  case salmon
  
  var value: UIColor {
    switch self {
    case .background:
      return UIColor(hexString: "021d22")
    case .shadeBackground:
      return UIColor(hexString: "022a31")
    case .lightBackground:
      return UIColor(hexString: "E5E7E8")
    case .lightText:
      return .white
    case .lightMediumText:
      return UIColor(hexString: "C0C6C8")
    case .darkText:
      return .black
    case .darkMediumText:
      return UIColor(hexString: "5C5C5D")
    case .errorText:
      return .red
    case .blueText:
      return UIColor(hexString: "5DA9CC")
    case .circle:
      return UIColor(hexString: "C0C6C8").withAlphaComponent(0.2)
    case .primaryButtonBackgroundNormal:
      return UIColor(hexString: "EFBF2D")
    case .primaryButtonBackgroundHighlighted:
      return UIColor(hexString: "D29321")
    case .primaryButtonBackgroundDisabled:
      return UIColor(hexString: "E8DDB9")
    case .primaryButtonTitleDisabled:
      return UIColor(hexString: "ADADAD")
    case .secondaryButtonDisabled:
      return UIColor(hexString: "BCBCBC")
    case .secondaryButtonBorder:
      return UIColor(hexString: "737373")
    case .lightGray:
      return UIColor(hexString: "C8CACB")
    case .salmon:
      return UIColor(hexString: "F97979")
    }
  }
}

@objc class ColorAdapter: NSObject
{
  static let yellowColor: UIColor = {
    return Color.primaryButtonBackgroundNormal.value
  }()
  
  static let blueColor: UIColor = {
    return Color.blueText.value
  }()
}

extension UIColor {
  convenience init(hexString: String) {
    let scanner = Scanner(string: hexString)
    scanner.scanLocation = 0
    
    var rgbValue: UInt64 = 0
    
    scanner.scanHexInt64(&rgbValue)
    
    let r = (rgbValue & 0xff0000) >> 16
    let g = (rgbValue & 0xff00) >> 8
    let b = rgbValue & 0xff
    
    self.init(
      red: CGFloat(r) / 0xff,
      green: CGFloat(g) / 0xff,
      blue: CGFloat(b) / 0xff, alpha: 1
    )
  }
}
