import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder

@main
struct PDBundleInfoGenerator: ParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "Generate a PDBundle enum from a Playdate pdxinfo file."
	)

	@Argument(help: "Path to the input pdxinfo file.")
	var input: String

	@Argument(help: "Path to the output Swift file.")
	var output: String

	/// Known pdxinfo keys that map directly to camelCase Swift property names.
	static let knownKeys: Set<String> = [
		"name",
		"author",
		"description",
		"bundleID",
		"version",
		"buildNumber",
		"imagePath",
		"launchSoundPath",
		"contentWarning",
		"contentWarning2",
	]

	func validate() throws {
		let inputURL = URL(fileURLWithPath: input)
		guard FileManager.default.fileExists(atPath: inputURL.path) else {
			throw ValidationError("No pdxinfo file found at '\(input)'.")
		}
	}

	func run() throws {
		let inputURL = URL(fileURLWithPath: input)
		let outputURL = URL(fileURLWithPath: output)

		let contents = try String(contentsOf: inputURL, encoding: .utf8)
		let entries = Self.parse(contents)

		let swift = try Self.generate(from: entries)

		try FileManager.default.createDirectory(
			at: outputURL.deletingLastPathComponent(),
			withIntermediateDirectories: true
		)
		try swift.write(to: outputURL, atomically: true, encoding: .utf8)
	}

	// MARK: - Parsing

	/// Parses pdxinfo key=value content into a dictionary.
	static func parse(_ content: String) -> [String: String] {
		var entries: [String: String] = [:]
		for line in content.components(separatedBy: .newlines) {
			let trimmed = line.trimmingCharacters(in: .whitespaces)
			if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
			guard let equalsIndex = trimmed.firstIndex(of: "=") else { continue }
			let key = String(trimmed[trimmed.startIndex..<equalsIndex])
			let value = String(trimmed[trimmed.index(after: equalsIndex)...])
			entries[key] = value
		}
		return entries
	}

	// MARK: - Code Generation

	/// Errors thrown during generation.
	enum GeneratorError: Error, CustomStringConvertible {
		/// An error that's thrown when the parsed `buildNumber` isn't a valid integer.
		case invalidBuildNumber(String)

		var description: String {
			switch self {
				case .invalidBuildNumber(let value):
					"buildNumber '\(value)' isn't a valid integer."
			}
		}
	}

	/// Generates the Swift source for `PDBundle`.
	static func generate(from entries: [String: String]) throws -> String {
		// validate buildNumber before entering the result builder
		var buildNumber: Int?
		if let buildNumberValue = entries["buildNumber"] {
			guard let intVal = Int(buildNumberValue) else {
				throw GeneratorError.invalidBuildNumber(buildNumberValue)
			}
			buildNumber = intVal
		}

		let sortedEntries = entries.sorted(by: { $0.key < $1.key })

		let enumDecl = try EnumDeclSyntax("public enum PDBundle") {
			for (key, value) in sortedEntries {
				let name = knownKeys.contains(key) ? key : key.sanitisedIdentifier

				if key == "buildNumber", let intVal = buildNumber {
					DeclSyntax("public static let \(raw: name): Int = \(raw: intVal)")
				} else {
					let escapedValue = value.escapedForStringLiteral
					DeclSyntax("public static let \(raw: name) = \"\(raw: escapedValue)\"")
				}
			}
		}

		let header: Trivia = [
			.lineComment("// Auto-generated from pdxinfo — don't edit this file."),
			.newlines(2),
			.docLineComment("/// Metadata about this bundle."),
			.newlines(1),
		]

		let source = enumDecl.with(\.leadingTrivia, header)
		return source.formatted().description + "\n"
	}
}
