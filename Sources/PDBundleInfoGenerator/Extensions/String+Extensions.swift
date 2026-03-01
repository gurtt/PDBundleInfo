import Foundation

extension String {
	/// Escapes backslashes and double quotes for use in a Swift string literal.
	var escapedForStringLiteral: String {
		replacingOccurrences(of: "\\", with: "\\\\")
			.replacingOccurrences(of: "\"", with: "\\\"")
	}

	/// Sanitises an arbitrary string into a valid Swift identifier.
	var sanitisedIdentifier: String {
		var result = map { $0.isLetter || $0.isNumber || $0 == "_" ? $0 : Character("_") }
		if let first = result.first, first.isNumber {
			result.insert("_", at: result.startIndex)
		}
		return String(result)
	}
}
