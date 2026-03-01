import Testing

@testable import PDBundleInfoGenerator

@Suite("Parsing")
struct ParseTests {
	@Test func basicKeyValueParsing() {
		let input = "name=My Game\nauthor=someone"
		let entries = PDBundleInfoGenerator.parse(input)
		#expect(entries.count == 2)
		#expect(entries["name"] == "My Game")
		#expect(entries["author"] == "someone")
	}

	@Test func skipsBlankLines() {
		let input = "name=My Game\n\nauthor=someone"
		let entries = PDBundleInfoGenerator.parse(input)
		#expect(entries.count == 2)
	}

	@Test func skipsCommentLines() {
		let input = "# This is a comment\nname=My Game\n# Another comment"
		let entries = PDBundleInfoGenerator.parse(input)
		#expect(entries.count == 1)
		#expect(entries["name"] == "My Game")
	}

	@Test func skipsLinesWithoutEquals() {
		let input = "name=My Game\nno equals here\nauthor=someone"
		let entries = PDBundleInfoGenerator.parse(input)
		#expect(entries.count == 2)
	}

	@Test func valueContainingEquals() {
		let input = "description=a=b=c"
		let entries = PDBundleInfoGenerator.parse(input)
		#expect(entries.count == 1)
		#expect(entries["description"] == "a=b=c")
	}

	@Test func trimsLeadingWhitespace() {
		let input = "  name=My Game"
		let entries = PDBundleInfoGenerator.parse(input)
		#expect(entries.count == 1)
		#expect(entries["name"] == "My Game")
	}

	@Test func emptyInputReturnsEmpty() {
		let entries = PDBundleInfoGenerator.parse("")
		#expect(entries.isEmpty)
	}
}

@Suite("Property Naming")
struct PropertyNameTests {
	@Test(arguments: [
		"name",
		"bundleID",
		"buildNumber",
		"imagePath",
		"launchSoundPath",
		"contentWarning2",
	])
	func knownKeysAreRecognised(key: String) {
		#expect(PDBundleInfoGenerator.knownKeys.contains(key))
	}

	@Test func unknownKeyFallsBackToSanitise() {
		#expect(!PDBundleInfoGenerator.knownKeys.contains("my-custom-key"))
		#expect("my-custom-key".sanitisedIdentifier == "my_custom_key")
	}
}

@Suite("Identifier Sanitisation")
struct SanitiseIdentifierTests {
	@Test func lettersAndNumbersPassThrough() {
		#expect("abc123".sanitisedIdentifier == "abc123")
	}

	@Test func specialCharsReplacedWithUnderscore() {
		#expect("hello-world!".sanitisedIdentifier == "hello_world_")
	}

	@Test func leadingDigitGetsPrefixed() {
		#expect("42answer".sanitisedIdentifier == "_42answer")
	}

	@Test func underscoresPreserved() {
		#expect("my_key".sanitisedIdentifier == "my_key")
	}
}

@Suite("Escaping")
struct EscapedTests {
	@Test func backslashesDoubled() {
		#expect(#"back\slash"#.escapedForStringLiteral == #"back\\slash"#)
	}

	@Test func doubleQuotesEscaped() {
		#expect(#"say "hello""#.escapedForStringLiteral == #"say \"hello\""#)
	}

	@Test func noSpecialCharsUnchanged() {
		#expect("plain text".escapedForStringLiteral == "plain text")
	}

	@Test func combinedEscaping() {
		#expect(#"a\"b"#.escapedForStringLiteral == #"a\\\"b"#)
	}
}

@Suite("Code Generation")
struct GenerateTests {
	@Test func producesExpectedProperties() throws {
		let entries = [
			"name": "My Game",
			"author": "someone",
		]
		let output = try PDBundleInfoGenerator.generate(from: entries)
		#expect(output.contains("public enum PDBundle"))
		#expect(output.contains(#"public static let name = "My Game""#))
		#expect(output.contains(#"public static let author = "someone""#))
	}

	@Test func buildNumberRenderedAsInt() throws {
		let entries = ["buildNumber": "42"]
		let output = try PDBundleInfoGenerator.generate(from: entries)
		#expect(output.contains("public static let buildNumber: Int = 42"))
	}

	@Test func invalidBuildNumberThrows() {
		let entries = ["buildNumber": "notanumber"]
		#expect(throws: PDBundleInfoGenerator.GeneratorError.self) {
			try PDBundleInfoGenerator.generate(from: entries)
		}
	}

	@Test func emptyEntriesProducesEmptyEnum() throws {
		let output = try PDBundleInfoGenerator.generate(from: [:])
		#expect(output.contains("public enum PDBundle"))
	}

	@Test func specialCharactersEscapedInOutput() throws {
		let entries = ["description": #"They said "hello""#]
		let output = try PDBundleInfoGenerator.generate(from: entries)
		#expect(output.contains(#"They said \"hello\""#))
	}

	@Test func headerCommentPresent() throws {
		let output = try PDBundleInfoGenerator.generate(from: [:])
		#expect(output.contains("Auto-generated from pdxinfo"))
	}
}
