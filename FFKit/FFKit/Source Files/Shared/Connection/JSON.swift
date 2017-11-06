public class JSON {
  var data: Any
  
  init(_ data: Any) {
    self.data = data
  }
}

extension JSON {
  struct KeyPath {
    let keys: [String]
    
    init(_ string: String) {
      keys = string.components(separatedBy: ".")
    }
    
    init(keys: [String]) {
      self.keys = keys
    }
    
    func keyPathByRemovingFirstKey() -> KeyPath {
      var firstRemoved = keys
      firstRemoved.removeFirst()
      return KeyPath(keys: firstRemoved)
    }
    
    var hasOnlyOneKey: Bool {
      return keys.count == 1
    }
  }
  
  func value(forKeyPath keyPathString: String) -> JSON? {
    guard let dictionary = data as? [String : Any],
      let value = getValue(for: KeyPath(keyPathString), in: dictionary) else { return nil }
    return JSON(data: value)
  }
  
  private func getValue(for keyPath: KeyPath, in dictionary: [String : Any]) -> Any? {
    if let key = keyPath.keys.first, let value = dictionary[key] {
      if keyPath.hasOnlyOneKey {
        return value
      }
      else if let subDictionary = value as? [String : Any] {
        let subKeyPath = keyPath.keyPathByRemovingFirstKey()
        return getValue(for: subKeyPath, in: subDictionary)
      }
    }
    
    return nil
  }
}

public protocol DictionaryInitializable {
  init?(dictionary: [String: Any])
}

extension JSON {
  public func convertToArray<T: DictionaryInitializable>(of element: T.Type) -> [T]? {
    if let array = data as? [[String : Any]] {
      return convert(array, toArrayOf: element)
    }
    else if let dictionary = data as? [String : Any] {
      return convert([dictionary], toArrayOf: element)
    }
    
    return nil
  }
  
  private func convert<T: DictionaryInitializable>(_ arrayObject: [[String : Any]], toArrayOf element: T.Type) -> [T]? {
    return arrayObject.flatMap { T(dictionary: $0) }
  }
}

extension JSON {
  public func convertToDouble() -> Double? {
    if let data = data as? Int {
      return Double(data)
    }
    else if let data = data as? Double {
      return data
    }
    else if let data = data as? String {
      return Double(data)
    }
    
    return nil
  }
  
  public func convertToString() -> String? {
    if let data = data as? Int {
      return String(data)
    }
    else if let data = data as? Double {
      return String(data)
    }
    else if let data = data as? String {
      return data
    }
    
    return nil
  }
}
