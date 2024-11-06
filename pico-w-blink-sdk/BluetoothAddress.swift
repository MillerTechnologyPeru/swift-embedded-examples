//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// Bluetooth address.
@frozen
public struct BluetoothAddress: Sendable {
    
    // MARK: - Properties
    
    /// Underlying address bytes (host endianess).
    public var bytes: ByteValue
    
    // MARK: - Initialization
    
    /// Initialize with the specifed bytes (in host endianess).
    public init(bytes: ByteValue = (0, 0, 0, 0, 0, 0)) {
        self.bytes = bytes
    }
}

public extension BluetoothAddress {
    
    /// The minimum representable value in this type.
    static var min: BluetoothAddress { return BluetoothAddress(bytes: (.min, .min, .min, .min, .min, .min)) }
    
    /// The maximum representable value in this type.
    static var max: BluetoothAddress { return BluetoothAddress(bytes: (.max, .max, .max, .max, .max, .max)) }
    
    /// A zero address.
    static var zero: BluetoothAddress { return .min }
}

// MARK: - ByteValue

extension BluetoothAddress {
    
    /// Raw Bluetooth Address 6 byte (48 bit) value.
    public typealias ByteValue = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
    
    public static var bitWidth: Int { return 48 }
    
    public static var length: Int { return 6 }
}

// MARK: - Equatable

extension BluetoothAddress: Equatable {
    
    public static func == (lhs: BluetoothAddress, rhs: BluetoothAddress) -> Bool {
        return lhs.bytes.0 == rhs.bytes.0
            && lhs.bytes.1 == rhs.bytes.1
            && lhs.bytes.2 == rhs.bytes.2
            && lhs.bytes.3 == rhs.bytes.3
            && lhs.bytes.4 == rhs.bytes.4
            && lhs.bytes.5 == rhs.bytes.5
    }
}

// MARK: - Hashable

extension BluetoothAddress: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: bytes) { hasher.combine(bytes: $0) }
    }
}

// MARK: - Byte Swap

extension BluetoothAddress: ByteSwap {
    
    /// A representation of this address with the byte order swapped.
    public var byteSwapped: BluetoothAddress {
        return BluetoothAddress(bytes: (bytes.5, bytes.4, bytes.3, bytes.2, bytes.1, bytes.0))
    }
}

// MARK: - RawRepresentable

#if !hasFeature(Embedded)
extension BluetoothAddress: RawRepresentable {
    
    /// Initialize a Bluetooth Address from its big endian string representation (e.g. `00:1A:7D:DA:71:13`).
    public init?(rawValue: String) {
        
        // verify string length
        guard rawValue.utf8.count == 17
            else { return nil }
        
        var bytes: ByteValue = (0, 0, 0, 0, 0, 0)
        
        let components = rawValue.split(whereSeparator: { $0 == ":" })
        
        guard components.count == 6
            else { return nil }
        
        for (index, string) in components.enumerated() {
            
            guard string.utf8.count == 2,
                let byte = UInt8(string, radix: 16)
                else { return nil }
            
            withUnsafeMutablePointer(to: &bytes) {
                $0.withMemoryRebound(to: UInt8.self, capacity: 6) {
                    $0.advanced(by: index).pointee = byte
                }
            }
        }
        
        self.init(bigEndian: BluetoothAddress(bytes: bytes))
    }
    
    /// Convert a Bluetooth Address to its big endian string representation (e.g. `00:1A:7D:DA:71:13`).
    public var rawValue: String {
        _description
    }
}
#endif

// MARK: - CustomStringConvertible

extension BluetoothAddress: CustomStringConvertible {
    
    public var description: String { _description }

    /// Convert a Bluetooth Address to its big endian string representation (e.g. `00:1A:7D:DA:71:13`).
    internal var _description: String {
        let bytes = self.bigEndian.bytes
        return withUnsafePointer(to: bytes) { bytePointer in
            bytePointer.withMemoryRebound(to: UInt8.self, capacity: 6) {
                String(cString: bd_addr_to_str($0))
            }
        }
    }
}

// MARK: - Data

public extension BluetoothAddress {
        
    init?<Data: DataContainer>(data: Data) {
        guard data.count == type(of: self).length
            else { return nil }
        self.bytes = (data[0], data[1], data[2], data[3], data[4], data[5])
    }
}

// MARK: - Codable

#if !hasFeature(Embedded)
extension BluetoothAddress: Codable { }
#endif
