struct MembershipCardNumberLoginDetails {
  let membershipCardNumber: String
  let pin: String
  
  let authenticationCode: String?
  let authenticationToken: String?
  
  private init (membershipCardNumber: String, pin: String, authenticationCode: String?, authenticationToken: String?) {
    self.membershipCardNumber = membershipCardNumber
    self.pin = pin
    self.authenticationCode = authenticationCode
    self.authenticationToken = authenticationToken
  }
  
  init(membershipCardNumber: String, pin: String) {
    self.init(membershipCardNumber: membershipCardNumber, pin: pin, authenticationCode: nil, authenticationToken: nil)
  }
}

protocol MembershipCardNumberLoginServiceInput: class {
  func logIn(withMembershipCardNumberDetails: MembershipCardNumberLoginDetails)
}

extension LoginDestination {
  static let forgottenMembershipCardNumber = "forgottenMembershipCardNumber"
  static let forgottenPIN = "forgottenPIN"
}

class MembershipCardNumberLoginInteractor: AbstractLoginInteractor {
  var service: MembershipCardNumberLoginServiceInput?
  
  override func invokeService() {
    let cardNumberDetails = MembershipCardNumberLoginDetails(membershipCardNumber: id ?? "",
                                                             pin: secret ?? "")
    service?.logIn(withMembershipCardNumberDetails: cardNumberDetails)
  }
  
  override func helpWithId() {
    output?.navigate(to: .forgottenMembershipCardNumber)
  }
  
  override func helpWithSecret() {
    output?.navigate(to: .forgottenPIN)
  }
}

