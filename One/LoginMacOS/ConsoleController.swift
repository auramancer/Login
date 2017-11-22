import Foundation

class ConsoleController {
  func load() {
    outputAndWaitForCommand()
  }
  
  func outputAndWaitForCommand() {
    outputState()
    waitForCommand()
  }
  
  func waitForCommand() {
    let commandString = getInput()
    if let command = Command(commandString) {
      excuteCommand(command)
    }
    else {
      outputAndWaitForCommand()
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
  
  func showProgress() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
      print(".", terminator:"")
    }
  }
  
  func hideProgress() {
    timer?.invalidate()
    
    print("")
  }
  
  func showMessage(_ message: LoginMessage) {
    output("\(message.style == .error ? "❗️" : "💡") \(message.text)")
    
    outputAndWaitForCommand()
  }
  
  func clearMessage() {
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
