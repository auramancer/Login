//struct UsernameLoginDetails: LoginDetails {
//  let username: String
//  let password: String
//
//  var id: String {
//    return username
//  }
//
//  var secret: String {
//    return password
//  }
//}

class UsernameLoginInteractor: LoginInteractor {
//  override func validateDetails(_ details: LoginDetails) -> Bool {
//    return (details as? UsernameLoginDetails)?.areValid ?? false
//  }
}

//private extension UsernameLoginDetails {
//  var areValid: Bool {
//    return usernameIsValid && passwordIsValid
//  }
//
//  private var usernameIsValid: Bool {
//    return username != ""
//  }
//
//  private var passwordIsValid: Bool {
//    return password != ""
//  }
//}

