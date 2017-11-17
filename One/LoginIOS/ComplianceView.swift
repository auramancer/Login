//
//  ComplianceView.swift
//  LiveCasino
//
//  Created by Vinoth Palanisamy on 25/04/2017.
//  Copyright © 2017 Grosvenor. All rights reserved.
//

import UIKit

protocol ComplianceViewDelegate: class {
  func showHelp()
}

@IBDesignable class ComplianceView: UIView {
  
  @IBInspectable var contactUs: Bool = false {
    didSet {
      styleCustomerCare()
    }
  }
  
  weak var delegate: ComplianceViewDelegate?
  
  @IBOutlet var view: UIView!
  
  @IBOutlet var customerCareField: UITextView!
  @IBOutlet var licenceField: UITextView!
  @IBOutlet var rankCaresField: UITextView!
  
  @IBOutlet var gamingCommissionImageView: UIImageView!
  @IBOutlet var alderneyGamblingImageView: UIImageView!
  
  @IBOutlet var keepItFunButton: UIButton!
  @IBOutlet var gamecareCertifiedButton: UIButton!
  @IBOutlet var eighteenImageView: UIImageView!
  @IBOutlet var problemGamingButton: UIButton!
  
  private let paraStyle = NSMutableParagraphStyle()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    Bundle.main.loadNibNamed(String(describing: ComplianceView.self), owner: self, options: [:])
    addSubview(view)
    view.frame = bounds
    styleCustomerCare()
    styleLicense()
    styleRankCares()
    gamecareCertifiedButton.imageView?.contentMode = .scaleAspectFit
    keepItFunButton.imageView?.contentMode = .scaleAspectFit
    problemGamingButton.imageView?.contentMode = .scaleAspectFit
  }
  
  // MARK: Action
  
  @IBAction func gambleAwareButtonTapped(_ sender: Any) {
    openUrl(.gambleAware)
  }
  
  @IBAction func keepItFunButtonTapped(_ sender: Any) {
    openUrl(.keepItFun)
  }
  
  @IBAction func gameCareCertifiedButtonTapped(_ sender: Any) {
    openUrl(.gameCareCertified)
  }
  
  @IBAction func problemGamblingButtonTapped(_ sender: Any) {
    openUrl(.problemGambling)
  }
  
  private func openUrl(_ complaince: Compliance) {
    if let url = URL(string: complaince.url) {
      UIApplication.shared.openURL(url)
    }
  }
  
  // MARK: Style
  
  private func styleCustomerCare() {
    if let customerCareField = customerCareField {
      customerCareField.delegate = self
      var customerCareText = customerCareField.text ?? ""
      if !contactUs {
        customerCareText = customerCareText.replacingOccurrences(of: "\(Compliance.contactUs.rangeValue) |", with: "")
      }
      var customerCareString = NSMutableAttributedString(string: customerCareText,
                                                         attributes: attributes())
      addLink(in: &customerCareString, compliances: [.contactUs, .faqs, .terms, .privacy, .aboutUs])
      customerCareField.attributedText = customerCareString
    }
  }
  
  private func styleLicense() {
    var licenseString = NSMutableAttributedString(string: licenceField.text,
                                                  attributes: attributes())
    addLink(in: &licenseString, compliances: [.alderneyGambling, .ukGambling, .keepItFun, .rankLeisure, .gambleAware])
    licenceField.attributedText = licenseString
  }
  
  private func styleRankCares() {
    var rankCareString = NSMutableAttributedString(string: rankCaresField.text,
                                                   attributes: attributes())
    addLink(in: &rankCareString, link: Compliance.keepItFun.url, rangeValue: Compliance.keepItFun.url)
    rankCaresField.attributedText = rankCareString
  }
  
  
  // MARK: Format Text
  
  private func addLink(in attributedString: inout NSMutableAttributedString, compliances: [Compliance]) {
    for compliance in compliances {
      addLink(in: &attributedString, link: compliance.url, rangeValue: compliance.rangeValue)
    }
  }
  
  private func addLink(in attributedString: inout NSMutableAttributedString, for compliance : Compliance) {
    addLink(in: &attributedString, link: compliance.url, rangeValue: compliance.rangeValue)
  }
  
  private func addLink(in attributedString: inout NSMutableAttributedString, link: String, rangeValue : String) {
    let rangeString = attributedString.string as NSString
    
    attributedString.addAttributes([NSAttributedStringKey.link: link,
                                    NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue],
                                   range: rangeString.range(of: rangeValue))
  }
  
  // MARK: Style Helpers
  
  private func attributes() -> [NSAttributedStringKey : Any] {
    return [NSAttributedStringKey(rawValue: NSAttributedStringKey.paragraphStyle.rawValue): paragraphStlye(),
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): Font.futuraBook.of(size: 14), NSAttributedStringKey.foregroundColor: Color.lightMediumText.value ]
  }
  
  private func paragraphStlye() -> NSParagraphStyle {
    paraStyle.alignment = .center
    return paraStyle
  }
  
}

extension ComplianceView: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
    if URL.absoluteString == Compliance.contactUs.url {
      delegate?.showHelp()
      return false
    }
    return true
  }
}
