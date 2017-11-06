import Foundation

struct Alert {
  var title: StringVarient?
  var message: StringVarient?
  var actions: [AlertAction]
  
  var needsInput = false
  var inputValidator: ((String?) -> Bool)?
  
  var activityIsInProgress = false
  
  var timeUntilAutoClose: TimeInterval?
  
  var controllerInstantiater: AlertControllerInstantiater = { alert in
    let controller = AlertController()
    controller.alert = alert
    return controller
  }
  
  init(title: StringVarient?, message: StringVarient?, actions: [AlertAction]) {
    self.title = title
    self.message = message
    self.actions = actions
  }
}

extension Alert {
  static func activity(title: StringVarient?, message: StringVarient?) -> Alert {
    var alert = Alert(title: title, message: message, actions: [])
    alert.activityIsInProgress = true
    return alert
  }
  
  static func acknowledgement(title: StringVarient?,
                              message: StringVarient?,
                              actionTitle: String? = "OK")  -> Alert {
    let action = AlertAction(title: actionTitle, style: .default, handler: nil)
    let alert = Alert(title: title, message: message, actions: [action])
    return alert
  }
}

protocol StringVarient {
  var string: String { get }
}

extension String: StringVarient {
  var string: String {
    return self
  }
}

extension NSAttributedString: StringVarient {}

typealias AlertActionHandler = (AlertAction, String?) -> Void

enum AlertActionStyle: Int {
  case `default`
  case cancel
  //  case destructive
}

struct AlertAction {
  var title: String?
  var style: AlertActionStyle
  var handler: AlertActionHandler?
  
  init(title: String?, style: AlertActionStyle, handler: AlertActionHandler?) {
    self.title = title
    self.style = style
    self.handler = handler
  }
}

class AlertWrapper: NSObject {
  var alert: Alert
  
  init(_ alert: Alert) {
    self.alert = alert
  }
}
