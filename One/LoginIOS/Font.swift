import UIKit

enum PhoneSize {
  case iPhone4Title, iPhone4Normal, iPhone4Small, iPadTitle, iPadNormal, iPhoneNormal
}

@objc enum Font: Int {
  case futuraBook, futuraHeavy
  
  func of(size: Int) -> UIFont {
    switch self {
    case .futuraBook:
      return UIFont(name: name, size: CGFloat(size))!
    case .futuraHeavy:
      return UIFont(name: name, size: CGFloat(size))!
    }
  }
  
  func of(size: PhoneSize) -> UIFont {
    switch size {
    case .iPhone4Title:
      return of(size: 18)
    case .iPhone4Normal:
      return of(size: 15)
    case .iPhone4Small:
      return of(size: 13)
    case .iPadTitle:
      return of(size: 28)
    case .iPadNormal:
      return of(size: 22)
    case .iPhoneNormal:
      return of(size: 17)
    }
  }
  
  var name: String {
    switch self {
    case .futuraBook:
      return "FuturaPT-Book"
    case .futuraHeavy:
      return "FuturaPT-Heavy"
    }
  }
}

@objc class FontBridge: NSObject {
  static func named(_ font: Font, ofSize: Int) -> UIFont {
    switch font {
    case .futuraBook:
      return UIFont(name: font.name, size: CGFloat(ofSize))!
    case .futuraHeavy:
      return UIFont(name: font.name, size: CGFloat(ofSize))!
    }
  }
}
