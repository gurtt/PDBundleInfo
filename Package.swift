// swift-tools-version: 6.2

import PackageDescription

let package = Package(
	name: "PDBundleInfo",
	platforms: [.macOS(.v13)],
	products: [
		.plugin(
			name: "PDBundleInfo",
			targets: ["PDBundleInfo"]
		)
	],
	dependencies: [
		.package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
	],
	targets: [
		.plugin(
			name: "PDBundleInfo",
			capability: .buildTool(),
			dependencies: ["PDBundleInfoGenerator"]
		),
		.executableTarget(
			name: "PDBundleInfoGenerator",
			dependencies: [
				.product(name: "SwiftSyntax", package: "swift-syntax"),
				.product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),
		.testTarget(
			name: "PDBundleInfoTests",
			dependencies: ["PDBundleInfoGenerator"]
		),
	]
)
