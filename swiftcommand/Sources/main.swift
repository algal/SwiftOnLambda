import Foundation

print("Hello, world, from Swift!")

#if os(Linux)
  import Glibc
#else
  import Darwin.C
#endif

func lineGenerator(file:UnsafeMutablePointer<FILE>) -> AnyIterator<String>
{
  return AnyIterator { () -> String? in
    var line:UnsafeMutablePointer<CChar>? = nil
    var linecap:Int = 0
    defer { free(line) }
    let ret = getline(&line, &linecap, file)
    
    if ret > 0 {
      guard let line = line else { return nil }
      return String(validatingUTF8: line)
    }
    else {
      return nil
    }
  }
}

for line in lineGenerator(file:stdin) {
  print(line, separator: "", terminator: "")
}
