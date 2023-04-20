@_implementationOnly import RegexBuilder
import Foundation
import simd

// TOPO: Move somewhere common
public enum CompositeStyle: Codable {
    case list
    case mapping
}

public struct VectorFormatStyle <V, ScalarStyle>: FormatStyle where V: SIMD, ScalarStyle: FormatStyle, ScalarStyle.FormatInput == V.Scalar, ScalarStyle.FormatOutput == String {


    public var scalarStyle: ScalarStyle
    public var compositeStyle: CompositeStyle
    public var scalarNames = ["x", "y", "z", "w"] // TODO: Localize, allow changing of names, e.g. rgba or quaternion fields

    public init(scalarStyle: ScalarStyle, compositeStyle: CompositeStyle = .mapping) {
        self.scalarStyle = scalarStyle
        self.compositeStyle = compositeStyle
    }

    public func format(_ value: V) -> String {
        switch compositeStyle {
        case .list:
            return SimpleListFormatStyle(substyle: scalarStyle).format(value.scalars)
        case .mapping:
            let mapping = Array(zip(scalarNames, value.scalars))
            return MappingFormatStyle(valueStyle: scalarStyle).format(mapping)
        }
    }
}

extension VectorFormatStyle {
    func scalarStyle(_ scalarStyle: ScalarStyle) -> Self {
        var copy = self
        copy.scalarStyle = scalarStyle
        return copy
    }

    func compositeStyle(_ compositeStyle: CompositeStyle) -> Self {
        var copy = self
        copy.compositeStyle = compositeStyle
        return copy
    }
}

public extension FormatStyle where Self == VectorFormatStyle<SIMD2<Float>, FloatingPointFormatStyle<Float>> {
    static var vector: Self {
        return Self(scalarStyle: .number)
    }
}

public extension FormatStyle where Self == VectorFormatStyle<SIMD3<Float>, FloatingPointFormatStyle<Float>> {
    static var vector: Self {
        return Self(scalarStyle: .number)
    }
}

public extension FormatStyle where Self == VectorFormatStyle<SIMD4<Float>, FloatingPointFormatStyle<Float>> {
    static var vector: Self {
        return Self(scalarStyle: .number)
    }
}

public extension FormatStyle where Self == VectorFormatStyle<SIMD2<Double>, FloatingPointFormatStyle<Double>> {
    static var vector: Self {
        return Self(scalarStyle: .number)
    }
}

public extension FormatStyle where Self == VectorFormatStyle<SIMD3<Double>, FloatingPointFormatStyle<Double>> {
    static var vector: Self {
        return Self(scalarStyle: .number)
    }
}

public extension FormatStyle where Self == VectorFormatStyle<SIMD4<Double>, FloatingPointFormatStyle<Double>> {
    static var vector: Self {
        return Self(scalarStyle: .number)
    }
}

public extension SIMD {
    func formatted<S>(_ format: S) -> S.FormatOutput where Self == S.FormatInput, S: FormatStyle {
        return format.format(self)
    }
}

// TODO: Cannot appease the generic gods.
//public extension SIMD where Scalar: BinaryFloatingPoint {
//    func formatted() -> String {
//        return formatted(.simd())
//    }
//}

// MARK: -

extension VectorFormatStyle: ParseableFormatStyle where ScalarStyle: ParseableFormatStyle {
    public var parseStrategy: SIMDParseStrategy <V, ScalarStyle.Strategy> {
        return SIMDParseStrategy(scalarStrategy: scalarStyle.parseStrategy, compositeStyle: compositeStyle)
    }
}

public struct SIMDParseStrategy <V, ScalarStrategy>: ParseStrategy where V: SIMD, ScalarStrategy: ParseStrategy, ScalarStrategy.ParseInput == String, ScalarStrategy.ParseOutput == V.Scalar {

    public enum ParseError: Error {
        case missingKeys
    }

    public var scalarStrategy: ScalarStrategy
    public var compositeStyle: CompositeStyle

    public init(scalarStrategy: ScalarStrategy, compositeStyle: CompositeStyle = .mapping) {
        self.scalarStrategy = scalarStrategy
        self.compositeStyle = compositeStyle
    }

    public func parse(_ value: String) throws -> V {
        switch compositeStyle {
        case .list:
            let strategy = SimpleListParseStrategy(substrategy: scalarStrategy)
            let scalars = try strategy.parse(value)
            return V(scalars)
        case .mapping:
            let strategy = MappingParseStrategy(keyStrategy: IdentityParseStategy(), valueStrategy: scalarStrategy)
            let dictionary = Dictionary(uniqueKeysWithValues: try strategy.parse(value).map { key, value in
                // TODO: Quick hack to prevent keys like " x", " y". Obviously fix in MappingParseStrategy…
                return (key.trimmingCharacters(in: .whitespaces), value)
            })
            switch V.scalarCount {
            case 2:
                guard let x = dictionary["x"], let y = dictionary["y"] else {
                    throw ParseError.missingKeys
                }
                return V([x, y])
            case 3:
                guard let x = dictionary["x"], let y = dictionary["y"], let z = dictionary["z"] else {
                    throw ParseError.missingKeys
                }
                return V([x, y, z])
            case 4:
                guard let x = dictionary["x"], let y = dictionary["y"], let z = dictionary["z"], let w = dictionary["w"] else {
                    throw ParseError.missingKeys
                }
                return V([x, y, z, w])
            default:
                throw ParseError.missingKeys
            }
        }
    }
}
