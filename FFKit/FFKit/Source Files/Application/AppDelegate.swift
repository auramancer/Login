import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func applicationDidFinishLaunching(_ application: UIApplication) {
  }
  
  var navigationController: UINavigationController? {
    return window?.rootViewController as? UINavigationController
  }
}
