import UIKit

protocol LoginRouterOutput {
  var forgottonUsernameAddress: String { get }
  var forgottonPasswordAddress: String { get }
  var forgottonCardNumberAddress: String { get }
  var forgottonPINAddress: String { get }
  
  var helpViewController: UIViewController { get }
  var registrationViewController: UIViewController { get }
}

class LoginRouter {
  class func goToHelpPage(from currentPage: UIViewController, for help: LoginHelp) {
    UIApplication.shared.openURL(URL(string:"https://www.google.co.uk")!)
  }

  class func goToVerificationPage(from currentPage: UIViewController, withIdentity identity: RetailIdentity) {
    let verificationPage = instantiateViewController(withIdentifier: "LoginVerificationViewController") as! LoginVerificationViewController
    verificationPage.retailIdentity = identity
    
    currentPage.navigationController?.pushViewController(verificationPage, animated: true)
  }

  class func goToIdentityCreationPage(from currentPage: UIViewController, withIdentity identity: RetailIdentity) {
    let identityCreationPage = instantiateViewController(withIdentifier: "IdentityCreationViewController") as! IdentityCreationViewController
    identityCreationPage.retailIdentity = identity

    currentPage.navigationController?.present(identityCreationPage, animated: true, completion: nil)
  }

  class func leave(from currentPage: UIViewController) {
    currentPage.navigationController?.popToRootViewController(animated: true)
  }
  
  private class func instantiateViewController(withIdentifier identifier: String) -> UIViewController {
    return UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: identifier)
  }
}

