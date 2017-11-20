protocol LoginDataPersistable {
  func saveIdentity(_: String)
  func savePassword(_: String)
  func saveCardNumber(_: String)
  func savePin(_: String)
  func saveToken(_: String)
  
  func loadIdentity() -> String?
  func loadPassword() -> String?
  func loadCardNumber() -> String?
  func loadPin() -> String?
  func loadToken() -> String?
}

//
//class LoginDataStorage {
//  func saveIdentity() {
//
//  }
//
//  func savePassword() {
//
//  }
//
//  func saveCardNumber() {
//
//  }
//
//  func savePin() {
//
//  }
//  func saveToken()
//
//  func loadIdentity() -> String?
//  func
//}

