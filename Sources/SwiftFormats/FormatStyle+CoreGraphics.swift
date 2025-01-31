import CoreGraphics
import Foundation

/// Format `CGPoint`s.
public struct CGPointFormatStyle: ParseableFormatStyle {

    public var parseStrategy: CGPointParseStrategy {
        return CGPointParseStrategy(componentFormat: componentFormat)
    }

    public var componentFormat: FloatingPointFormatStyle<Double> = .number

    public init() {
    }

    public func format(_ value: CGPoint) -> String {
        let style = SimpleListFormatStyle(substyle: componentFormat)
        return style.format([value.x, value.y])
    }
}

public extension FormatStyle where Self == CGPointFormatStyle {
    static var point: Self {
        return Self()
    }
}

// MARK: -

public struct CGPointParseStrategy: ParseStrategy {
    public var componentFormat: FloatingPointFormatStyle<Double>

    public init(componentFormat: FloatingPointFormatStyle<Double> = .number) {
        self.componentFormat = componentFormat
    }

    public func parse(_ value: String) throws -> CGPoint {
        var strategy = SimpleListFormatStyle(substyle: componentFormat).parseStrategy
        strategy.countRange = 2 ... 2
        let scalars = try strategy.parse(value)
        return CGPoint(x: scalars[0], y: scalars[1])
    }
}

// MARK: -

public extension CGPoint {
    init(_ string: String) throws {
        self = try CGPointFormatStyle().parseStrategy.parse(string)
    }

    init<Format, ParseInput>(_ input: ParseInput, format: Format) throws where Format: ParseableFormatStyle, ParseInput: StringProtocol, Format.Strategy == CGPointParseStrategy {
        self = try format.parseStrategy.parse(String(input))
    }

    init<Strategy, Value>(_ value: Value, strategy: Strategy) throws where Strategy: ParseStrategy, Value: StringProtocol, Strategy.ParseInput == String, Strategy.ParseOutput == CGPoint {
        self = try strategy.parse(String(value))
    }
}

public extension ParseableFormatStyle where Self == CGPointFormatStyle {
    static var point: Self {
        .init()
    }
}

public extension ParseStrategy where Self == CGPointParseStrategy {
    static var point: Self {
        .init()
    }
}

// MARK: -

public extension CGPoint {
    func formatted<S>(_ format: S) -> S.FormatOutput where Self == S.FormatInput, S: FormatStyle {
        return format.format(self)
    }

    func formatted() -> String {
        formatted(CGPointFormatStyle())
    }
}

// MARK: CGSize

/// Format `CGSize`s.
public struct CGSizeFormatStyle: ParseableFormatStyle {

    public var parseStrategy: CGSizeParseStrategy {
        return CGSizeParseStrategy(componentFormat: componentFormat)
    }

    public var componentFormat: FloatingPointFormatStyle<Double> = .number

    public init() {
    }

    public func format(_ value: CGSize) -> String {
        let style = SimpleListFormatStyle(substyle: componentFormat)
        return style.format([value.width, value.height])
    }
}

public extension FormatStyle where Self == CGSizeFormatStyle {
    static var size: Self {
        return Self()
    }
}

// MARK: -

public struct CGSizeParseStrategy: ParseStrategy {
    public var componentFormat: FloatingPointFormatStyle<Double>

    public init(componentFormat: FloatingPointFormatStyle<Double> = .number) {
        self.componentFormat = componentFormat
    }

    public func parse(_ value: String) throws -> CGSize {
        var strategy = SimpleListFormatStyle(substyle: componentFormat).parseStrategy
        strategy.countRange = 2 ... 2
        let scalars = try strategy.parse(value)
        return CGSize(width: scalars[0], height: scalars[1])
    }
}

// MARK: -

public extension CGSize {
    init(_ string: String) throws {
        self = try CGSizeFormatStyle().parseStrategy.parse(string)
    }

    init<Format, ParseInput>(_ input: ParseInput, format: Format) throws where Format: ParseableFormatStyle, ParseInput: StringProtocol, Format.Strategy == CGSizeParseStrategy {
        self = try format.parseStrategy.parse(String(input))
    }

    init<Strategy, Value>(_ value: Value, strategy: Strategy) throws where Strategy: ParseStrategy, Value: StringProtocol, Strategy.ParseInput == String, Strategy.ParseOutput == CGSize {
        self = try strategy.parse(String(value))
    }
}

public extension ParseableFormatStyle where Self == CGSizeFormatStyle {
    static var point: Self {
        .init()
    }
}

public extension ParseStrategy where Self == CGSizeParseStrategy {
    static var point: Self {
        .init()
    }
}

// MARK: -

public extension CGSize {
    func formatted<S>(_ format: S) -> S.FormatOutput where Self == S.FormatInput, S: FormatStyle {
        return format.format(self)
    }

    func formatted() -> String {
        formatted(CGSizeFormatStyle())
    }
}

