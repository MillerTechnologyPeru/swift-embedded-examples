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

internal extension String {
    
    /// Initialize from UTF8 data.
    init?<Data: DataContainer>(utf8 data: Data) {
        #if hasFeature(Embedded)
        self.init(validating: data, as: UTF8.self)
        #else
        if #available(macOS 15, iOS 18, watchOS 11, tvOS 18, visionOS 2, *) {
            self.init(validating: data, as: UTF8.self)
        } else {
            self.init(bytes: data, encoding: .utf8)
        }
        #endif
    }
}

