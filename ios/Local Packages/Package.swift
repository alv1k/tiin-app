// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
     name: "tiin_vpn Packages",
     platforms: [
        // Minimum platform version
         .iOS(.v13)
     ],
     products: [
         .library(
             name: "tiin_vpnCore",
             targets: ["tiin_vpnCore"]),
     ],
     dependencies: [
         // No dependencies
     ],
     targets: [
        .binaryTarget(
            name: "tiin_vpnCore",
            path: "../Frameworks/tiin_vpnCore.xcframework"
        )
     ]
 )
