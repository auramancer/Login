class Console {
  func entered(_ title: String) -> String {
    print("\(title):")
    return readLine() ?? ""
  }
  
  func confirmed(_ title: String) -> Bool {
    print("\(title)?")
    return readLine() == "y"
  }
  
  func show(_ message: String) {
    print(message)
  }
}
