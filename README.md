# PDBundleInfo

Generate programatically accessible bundle metadata from your `pdxinfo` files. A replacement for the [playdate.metadata API in the Lua SDK](https://sdk.play.date/Inside%20Playdate.html#f-metadata).

## Usage

Add the package as a dependency and apply the plugin to your target:

```swift
// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MyGame",
    dependencies: [
        .package(url: "https://github.com/gurtt/PDBundleInfo", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MyGame",
            plugins: [.plugin(name: "PDBundleInfo", package: "PDBundleInfo")]
        ),
    ]
)
```

Then, to access your bundle metadata:

```swift
let title = PDBundle.name
let version = PDBundle.version

print("\(title) running @\(version)")
if PDBundle.buildNumber < 10 {
    print("Pre-release version")
}
```

Any unrecognised keys are sanitised into valid Swift identifiers.

### Build time

You can optionally access a generated `buildTime` property by enabling the `BuildTime` trait:

```swift
.package(url: "https://github.com/gurtt/PDBundleInfo", from: "1.0.0", traits: ["BuildTime"])
```

The time is expressed as the number of seconds since 1 January, 2000 (the Playdate epoch).

## Where to put `pdxinfo`

The plugin searches for `pdxinfo` relative to the target's source directory, in order:

1. `Resources/pdxinfo` ([PlaydateKit](https://github.com/finnvoor/PlaydateKit) convention)
2. `pdxinfo` (root of the target source directory)
