import XCTest
@testable import FFKit

class ServiceTests: XCTestCase {
  private var service: ServiceSpy!
  
  private var result: ServiceSpy.Result?
  
  override func setUp() {
    super.setUp()
    
    service = ServiceSpy()
  }
  
  func testInitialize() {
    assertIsIdle()
  }
  
  private func assertIsIdle() {
    XCTAssertNil(service.input)
    XCTAssertNil(service.completion)
    XCTAssertFalse(service.isInUse)
  }
  
  func testReset() {
    setIsInUse()
    
    service.reset()
    
    assertIsIdle()
  }
  
  private func setIsInUse() {
    service.input = "input"
    service.completion = handleResult
    service.isInUse = true
  }
  
  func testInvokeWhenInUse() {
    setIsInUse()
    
    service.invoke("input2", completion: handleResult)
    
    XCTAssertNotEqual(service.input, "input2")
  }
  
  func testInvoke() {
    service.invoke("input", completion: handleResult)
    
    XCTAssertEqual(service.input, "input")
    XCTAssertNotNil(service.completion)
    XCTAssertTrue(service.isInUse)
  }
  
  private func handleResult(_ result: ServiceSpy.Result) {
    self.result = result
  }
  
  func testSucceed() {
    setIsInUse()
    
    service.succeed(withOutput: "output")
    
    assertResultEquals(.succeeded("output"))
    assertIsIdle()
  }
  
  func testFailed() {
    setIsInUse()
    
    service.fail(withErrors: [SimpleError("error1"), SimpleError("error2")])
    
    assertResultEquals(.failed([SimpleError("error1"), SimpleError("error2")]))
    assertIsIdle()
  }
  
  func testNotAvailable() {
    setIsInUse()
    
    service.notAvailable(dueTo: SimpleError("error"))
    
    assertResultEquals(.notAvailable(SimpleError("error")))
    assertIsIdle()
  }
  
  private func assertResultEquals(_ expected: ServiceSpy.Result) {
    guard let result = result else {
      XCTFail()
      return
    }
    
    switch (result, expected) {
    case (let .succeeded(output1), let .succeeded(output2)):
      XCTAssertEqual(output1, output2)
      
    case (let .failed(errors1), let .failed(errors2)):
      guard let errors1 = errors1 as? [SimpleError], let errors2 = errors2 as? [SimpleError] else {
        XCTFail()
        return
      }
      XCTAssertEqual(errors1, errors2)
      
    case (let .notAvailable(error1), let .notAvailable(error2)):
      guard let error1 = error1 as? SimpleError, let error2 = error2 as? SimpleError else {
        XCTFail()
        return
      }
      XCTAssertEqual(error1, error2)
      
    default:
      XCTFail()
    }
  }
}

private class ServiceSpy: Service<String, String> {
}
