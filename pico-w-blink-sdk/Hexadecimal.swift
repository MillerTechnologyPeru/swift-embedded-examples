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

internal extension FixedWidthInteger {
    
    func toHexadecimal() -> String {
        
        var string = String(self, radix: 16)
        while string.utf8.count < (MemoryLayout<Self>.size * 2) {
            string = "0" + string
        }
        return string.uppercased()
    }
}

internal extension Collection where Element: FixedWidthInteger {
    
    func toHexadecimal() -> String {
        let length = count * MemoryLayout<Element>.size * 2
        var string = ""
        string.reserveCapacity(length)
        string = reduce(into: string) { $0 += $1.toHexadecimal() }
        assert(string.count == length)
        return string
    }
}
