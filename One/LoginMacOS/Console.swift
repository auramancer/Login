import Foundation

class ConsoleController {
  func start() {
    waitForCommand()
  }
  
  func waitForCommand() {
    outputState()
    
    let commandString = getInput()
    if let command = Command(commandString) {
      excuteCommand(command)
    }
    else {
      waitForCommand()
    }
  }
  
  func outputState() {
  }
  
  func excuteCommand(_ command: Command) {
  }
  
  func getInput() -> String {
    print("> ", terminator:"")
    return readLine() ?? ""
  }
  
  func output(_ message: String) {
    print(message)
  }
  
  var timer: Timer?
  
  func showActivityMessage(_ message: String?) {
    if let message = message {
      print(message)
    }
    
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
      print(".", terminator:"")
    }
  }
  
  func hideActivityMessage() {
    timer?.invalidate()
    
    print("")
  }
  
  func showErrorMessage(_ message: String) {
    output("❗️\(message)")
    
    waitForCommand()
  }
  
  func hideErrorMessage() {
  }
  
  func leave() {
    output("🎉 Done!")
    exit(0)
  }
}

struct Command {
  let type: String
  let parameters: String?
  
  init?(_ string: String) {
    guard string != "" else { return nil }
    
    var string = string
    
    type = String(string.removeFirst())
    parameters = string.trimmingCharacters(in: .whitespaces)
  }
}
