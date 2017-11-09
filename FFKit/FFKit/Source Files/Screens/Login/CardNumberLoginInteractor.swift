//struct MembershipNumberLoginDetails: LoginDetails {
//  let membershipNumber: String
//  let pin: String
//
//  var id: String {
//    return membershipNumber
//  }
//
//  var secret: String {
//    return pin
//  }
//}

class MembershipNumberLoginInteractor: LoginInteractor {
//  override func validateDetails(_ details: LoginDetails) -> Bool {
//    return (details as? MembershipNumberLoginDetails)?.areValid ?? false
//  }
}

//private extension MembershipNumberLoginDetails {
//  var areValid: Bool {
//    return membershipNumberIsValid && pinIsValid
//  }
//
//  private var membershipNumberIsValid: Bool {
//    return membershipNumber != ""
//  }
//
//  private var pinIsValid: Bool {
//    return pin != ""
//  }
//}

