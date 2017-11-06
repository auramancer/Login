import Foundation

open class Service<Input, Output>: NSObject {
  
  public enum Result {
    case succeeded(Output)
    case failed([Error])
    case notAvailable(Error)
  }
  
  public typealias Completion = (Result) -> Void
  
  public var input: Input?
  public var completion: Completion?
  
  public var isInUse = false
  
  open func invoke(_ input: Input, completion: Completion?) {
    guard !isInUse else {
      return
    }
    
    self.input = input
    self.completion = completion
    isInUse = true
  }
  
  open func succeed(withOutput output: Output) {
    completion?(.succeeded(output))
    
    reset()
  }
  
  open func fail(withErrors errors: [Error]) {
    completion?(.failed(errors))
    
    reset()
  }
  
  open func notAvailable(dueTo error: Error) {
    completion?(.notAvailable(error))
    
    reset()
  }
  
  open func reset() {
    input = nil
    completion = nil
    isInUse = false
  }
}

