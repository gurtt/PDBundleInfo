import Foundation
import PackagePlugin

@main
struct PDBundleInfo: BuildToolPlugin {
	func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
		guard let sourceModule = target.sourceModule else { return [] }

		guard let pdxinfoURL = findPdxinfo(in: sourceModule.directoryURL) else {
			Diagnostics.warning(
				"No pdxinfo file found for target '\(target.name)'."
			)
			return []
		}

		let generator = try context.tool(named: "PDBundleInfoGenerator")
		let outputPath = context.pluginWorkDirectoryURL.appending(path: "PDBundle.generated.swift")

		return [
			.buildCommand(
				displayName: "Generate PDBundle from pdxinfo",
				executable: generator.url,
				arguments: [pdxinfoURL.path, outputPath.path],
				inputFiles: [pdxinfoURL],
				outputFiles: [outputPath]
			)
		]
	}

	private func findPdxinfo(in sourceDir: URL) -> URL? {
		let candidates = [
			sourceDir.appending(path: "Resources/pdxinfo"),
			sourceDir.appending(path: "pdxinfo"),
		]
		return candidates.first { FileManager.default.fileExists(atPath: $0.path) }
	}
}

#if canImport(XcodeProjectPlugin)
	import XcodeProjectPlugin

	extension PDBundleInfo: XcodeBuildToolPlugin {
		func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
			guard
				let pdxinfoFile = target.inputFiles.first(where: { $0.url.lastPathComponent == "pdxinfo" })
			else {
				Diagnostics.warning("No pdxinfo file found for Xcode target '\(target.displayName)'.")
				return []
			}

			let generator = try context.tool(named: "PDBundleInfoGenerator")
			let outputPath = context.pluginWorkDirectoryURL.appending(path: "PDBundle.generated.swift")

			return [
				.buildCommand(
					displayName: "Generate PDBundle from pdxinfo",
					executable: generator.url,
					arguments: [pdxinfoFile.url.path, outputPath.path],
					inputFiles: [pdxinfoFile.url],
					outputFiles: [outputPath]
				)
			]
		}
	}
#endif
