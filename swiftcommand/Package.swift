import PackageDescription

let package = Package(
        name: "swiftcommand",
        dependencies:[
//          .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 1, minor: 0),
          .Package(url:"../../greeter",majorVersion:1,minor:0),
        ],
        exclude: ["LinuxLibraries"]
)


