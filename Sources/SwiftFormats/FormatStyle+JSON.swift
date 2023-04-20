import Foundation

/// Format `Encodable`` types as JSON strings.
/// - Example:
///   - `TextField(text: "JSON", value: $value, format: JSONFormatStyle<SomeCodableType>())`
public struct JSONFormatStyle <FormatInput>: FormatStyle where FormatInput: Encodable {

    public init() {
    }

    public func format(_ value: FormatInput) -> String {
        do {
            let data = try JSONEncoder().encode(value)
            return String(decoding: data, as: UTF8.self)
        }
        catch {
            fatalError("\(error)")
        }
    }
}

extension JSONFormatStyle: ParseableFormatStyle where FormatInput: Decodable {
    public var parseStrategy: JSONParseStrategy<FormatInput> {
        return JSONParseStrategy<FormatInput>()
    }
}

public struct JSONParseStrategy <ParseOutput>: ParseStrategy where ParseOutput: Decodable {

    public enum JSONParseError: Error {
        case couldNotDecodeData
    }

    public init() {
    }

    public func parse(_ value: String) throws -> ParseOutput {

        guard let data = value.data(using: .utf8) else {
            throw JSONParseError.couldNotDecodeData
        }

        return try JSONDecoder().decode(ParseOutput.self, from: data)
    }
}
