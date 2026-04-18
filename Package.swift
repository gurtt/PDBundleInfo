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
	targets: [
		.plugin(
			name: "PDBundleInfo",
			capability: .buildTool(),
			dependencies: ["PDBundleInfoGenerator"]
		),
		.executableTarget(
			name: "PDBundleInfoGenerator",
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
