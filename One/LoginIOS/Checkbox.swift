import UIKit

@IBDesignable
class Checkbox: UIControl {
  
  @IBInspectable var inset: Int = 0 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var checkBoxRadius: Int = 0 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var lineWidth = 3 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var checkBoxColor: UIColor = .white  {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var tickColor: UIColor = .black  {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var fontSize: Int = 15 {
    didSet {
      font = Font.futuraBook.of(size: fontSize)
    }
  }
  
  @IBInspectable var font: UIFont = Font.futuraBook.of(size: 15)  {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var textColor: UIColor = .black  {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var text: NSString = "" {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var isChecked: Bool = false {
    didSet {
      setNeedsDisplay()
    }
  }
  
  private var tickPadding: CGFloat {
    let defaultPadding = 5
    return CGFloat(self.lineWidth / defaultPadding == 0 ? 3 : defaultPadding)
  }
  private var isTouchStarted = false
  
  // MARK: Draw
  
  override func draw(_ rect: CGRect) {
    let cBframe = checkBoxFrame(from: rect)
    
    drawCheckBox(in: cBframe)
    drawTick(in: cBframe)
    drawText(after: cBframe, in: rect)
  }
  
  private func drawCheckBox(in frame: CGRect) {
    let checkBox = UIBezierPath(roundedRect: frame, cornerRadius: CGFloat(checkBoxRadius))
    checkBoxColor.setFill()
    checkBox.fill()
    checkBox.close()
  }
  
  private func drawTick(in frame: CGRect)  {
    if isChecked {
      let tick = UIBezierPath()
      let bottomX = frame.minX + tickPadding
      let bottomY = frame.height / 1.5
      let midX = frame.midX / 1.5
      let midY = frame.height - CGFloat(tickPadding)
      let topX = frame.maxX - tickPadding
      let topY = frame.minY + tickPadding
      
      tick.move(to: CGPoint(x: bottomX , y: bottomY))
      tick.addLine(to: CGPoint(x: midX, y: midY))
      tick.addLine(to: CGPoint(x: topX, y: topY))
      
      tickColor.setStroke()
      tick.lineWidth = CGFloat(lineWidth)
      tick.lineCapStyle = .round
      tick.lineJoinStyle = .round
      tick.stroke()
      tick.close()
    }
  }
  
  private func drawText(after frame: CGRect, in rect: CGRect) {
    let paraStyle = NSMutableParagraphStyle()
    paraStyle.alignment = .center
    paraStyle.lineSpacing = 6
    
    let attributes: NSDictionary = [
      NSAttributedStringKey.foregroundColor: textColor,
      NSAttributedStringKey.paragraphStyle: paraStyle,
      NSAttributedStringKey.font: font
    ]
    let size = text.size(withAttributes: attributes as? [NSAttributedStringKey : Any])
    let point = CGPoint(x: frame.width + 2*CGFloat(inset), y: rect.midY - size.height/2)

    text.draw(at: point, withAttributes: attributes as? [NSAttributedStringKey : Any])
  }
  
  // MARK: Helpers
  
  private func checkBoxFrame(from rect: CGRect) -> CGRect {
    let minSize = min(rect.width, rect.height)
    let rect = CGRect(x: 0, y: 0, width: minSize, height: minSize)
    return rect.insetBy(dx: CGFloat(inset), dy: CGFloat(inset))
  }
  
  private func textFrame(from rect: CGRect) -> CGRect {
    let checkboxRect = checkBoxFrame(from: rect)
    let rect = CGRect(x: checkboxRect.width + 5, y: rect.minY, width: rect.width - checkboxRect.width - 5 , height: rect.height)
    return rect
  }
  
  // Tap Handling
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    isTouchStarted = true
    super.touchesBegan(touches, with: event)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    isTouchStarted = false
    super.touchesCancelled(touches, with: event)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if isTouchStarted {
      isTouchStarted = false
      isChecked = !isChecked
    }
    super.touchesEnded(touches, with: event)
  }
  
}
