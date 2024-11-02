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

        let cyw43: CYW43
        do {
            cyw43 = try CYW43()
        }
        catch {
            print("Wi-Fi init failed.")
            return
        }

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

        l2cap_init()
        gatt_client_init();

        hci_power_control(HCI_POWER_ON);

        sleep_ms(500)

        let advertisement: LowEnergyAdvertisingData = [0x0B, 0x08, 0x42, 0x6C, 0x75, 0x65, 0x5A, 0x20, 0x35, 0x2E, 0x34, 0x33]

        gap_advertisements_set_params(800, 800, 0, 0, nil, 0x07, 0x00);
        advertisement.withUnsafePointer {
            gap_advertisements_set_data(advertisement.length, UnsafeMutablePointer<UInt8>(mutating: $0))
        }
        gap_advertisements_enable(1);

        while true {
            cyw43.dot()
            cyw43.dot()
            cyw43.dot()

            cyw43.dash()
            cyw43.dash()
            cyw43.dash()

            cyw43.dot()
            cyw43.dot()
            cyw43.dot()
        }
    }
}

extension CYW43 {

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
    guard let allocation = malloc(Int(size + alignment - 1)) else { fatalError() }
    let misalignment = Int(bitPattern: allocation) % alignment
    precondition(misalignment == 0)
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