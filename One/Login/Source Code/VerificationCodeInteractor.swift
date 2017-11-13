protocol VerificationCodeInteractorInput {
  func updateDetails(_: MembershipCardNumberLoginDetails)
  func updateCode(_: String)
  
  func login()
  
  func resendCode()
}

class VerificationCodeInteractor: VerificationCodeInteractorInput,  {
  var details: MembershipCardNumberLoginDetails?
  var loginService: MembershipCardNumberLoginServiceInput?
  var codeService:
  
  func updateDetails(_ details: MembershipCardNumberLoginDetails) {
    self.details = details
  }
  
  func updateCode(_ code: String) {
    details?.verificationCode = code
  }
  
  func login() {
    service?.logIn(withMembershipCardNumberDetails: details)
  }
  
  func resendCode() {
    
  }
}
