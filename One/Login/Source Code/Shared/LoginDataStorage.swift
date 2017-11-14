protocol LoginDataPersistable {
  func saveUsername(_: String)
  func savePassword(_: String)
  func saveCardNumber(_: String)
  func savePin(_: String)
  func saveToken(_: String)
  
  func loadUsername() -> String?
  func loadPassword() -> String?
  func loadCardNumber() -> String?
  func loadPin() -> String?
  func loadToken() -> String?
}

//
//class LoginDataStorage {
//  func saveUsername() {
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
//  func loadUsername() -> String?
//  func
//}

