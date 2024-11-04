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

@main
struct Main {

    static func main() {

        print("Hello World!")

        let cyw43: CYW43
        do {
            cyw43 = try CYW43()
        }
        catch {
            print("Wi-Fi init failed.")
            return
        }

        cyw43.dot()

        cyw43[.led] = false

        #if ACCESS_POINT
        let accessPoint: CYW43.AccessPoint
        do {
            accessPoint = try CYW43.AccessPoint(ssid: "Pi Pico W", password: "1234")
        }
        catch {
            print("Access Point init failed.")
            return
        }
        #endif

        let bluetooth = CYW43.Bluetooth.shared
        bluetooth.setPower(.on)

        // wait for Bluetooth to turn on
        while bluetooth.state != .on {
            sleep_ms(500)
        }
        
        var advertisement = LowEnergyAdvertisingData()
        advertisement.bytes.0 = 0x02
        advertisement.bytes.1 = 0x01
        advertisement.bytes.2 = 0x06

        advertisement.bytes.3 = 0x05
        advertisement.bytes.4 = 0x09
        advertisement.bytes.5 = "P".utf8.first!
        advertisement.bytes.6 = "I".utf8.first!
        advertisement.bytes.7 = "C".utf8.first!
        advertisement.bytes.8 = "O".utf8.first!

        advertisement.length = 9

        var address: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = (0,0,0,0,0,0)
        gap_advertisements_set_params(0x0030, 0x0030, 0, 0, &address, 0x07, 0x00);
        bluetooth.advertisement = advertisement
        gap_advertisements_enable(1);

        while true {
            cyw43.blink()
        }
    }
}

extension CYW43 {

        func blink() {
            dot()
            dot()
            dot()

            dash()
            dash()
            dash()

            dot()
            dot()
            dot()
        }

        func dot() {
            self[.led] = true
            sleep_ms(250)
            self[.led] = false
            sleep_ms(250)
        }

        func dash() {
            self[.led] = true
            sleep_ms(500)
            self[.led] = false
            sleep_ms(250)
        }
}

/// Implement `posix_memalign(3)`, which is required by the Embedded Swift runtime but is
/// not provided by the Pi Pico SDK.
@_documentation(visibility: internal)
@_cdecl("posix_memalign") public func posix_memalign(
    _ memptr: UnsafeMutablePointer<UnsafeMutableRawPointer?>,
    _ alignment: Int,
    _ size: Int
) -> CInt {
    guard let allocation = aligned_alloc(alignment, size) else {
        return 0
    }
    memptr.pointee = allocation
    return 0
}

/// Implement `arc4random_buf` which is required by the Embedded Swift runtime for Hashable, Set, Dictionary,
/// and random-number generating APIs but is not provided by the Pi Pico SDK.
@_documentation(visibility: internal)
@_cdecl("arc4random_buf") public func arc4random_buf(buf: UnsafeMutableRawPointer, nbytes: Int) {
    for i in stride(from: 0, to: nbytes - 1, by: 2) {
        let randomValue = UInt16(rand() & Int32(UInt16.max))
        (buf + i).assumingMemoryBound(to: UInt16.self).pointee = randomValue
    }
    if nbytes % 2 == 1 {
        let randomValue = UInt8(rand() & Int32(UInt8.max))
        (buf + nbytes - 1).assumingMemoryBound(to: UInt8.self).pointee = randomValue
    }
}
