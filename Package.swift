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
	traits: [
		.trait(
			name: "BuildTime",
			description:
				"Include a buildTime property with seconds since the Playdate epoch (Jan 1, 2000)."
		)
	],
	dependencies: [
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
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			],
			swiftSettings: [
				.define("ENABLE_BUILD_TIME", .when(traits: ["BuildTime"]))
			]
		),
		.testTarget(
			name: "PDBundleInfoTests",
			dependencies: ["PDBundleInfoGenerator"],
			swiftSettings: [
				.define("ENABLE_BUILD_TIME", .when(traits: ["BuildTime"]))
			]
		),
	]
)
