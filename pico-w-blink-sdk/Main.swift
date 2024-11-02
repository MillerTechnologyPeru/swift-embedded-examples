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
            try cyw43 = CYW43()
        }
        catch {
            print("Wi-Fi init failed.")
            return
        }
        defer {
            cyw43.deinit()
        }
        let led = UInt32(CYW43_WL_GPIO_LED_PIN)
        let dot = {
            cyw43[.led] = true
            sleep_ms(250)
            cyw43[.led] = false
            sleep_ms(250)
        }
        let dash = {
            cyw43[.led] = true
            sleep_ms(500)
            cyw43[.led] = false
            sleep_ms(250)
        }
        while true {
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
    }
}

struct CYW43 {

    /// Initialize the CYW43 architecture. 
    /// 
    /// [Documentation](https://www.raspberrypi.com/documentation/pico-sdk/networking.html#group_pico_cyw43_arch_1ga7a05bd21f02a0effadbba1e8266b8771)
    init() throws(PicoError) {
        let errorCode = cyw43_arch_init()
        guard errorCode == 0 else {
            throw PicoError(rawValue: errorCode) ?? .unknown
        }
    }

    func `deinit`() {
        cyw43_arch_deinit()
    }

    subscript (gpio: GPIO) -> Bool {
        get {
            cyw43_arch_gpio_get(gpio.rawValue)
        }
        nonmutating set {
            cyw43_arch_gpio_put(gpio.rawValue, newValue)
        }
    }
}

extension CYW43 {

    enum GPIO: UInt32, CaseIterable {

        case led = 0

        case vsys = 1

        case vbus = 2
    }
}

enum PicoError: Int32, Error {

    /// An unspecified error occurred.
    case unknown = -1
    
    /// The function failed due to timeout.
    case timeout = -2
    
    /// Attempt to read from an empty buffer/FIFO.
    case noData = -3
    
    /// Permission violation (e.g. write to read-only flash partition).
    case notPermitted = -4
    
    /// Argument is outside the range of supported values.
    case invalidArg = -5
    
    /// An I/O error occurred.
    case io = -6
    
    /// The authorization failed due to bad credentials.
    case badAuth = -7
    
    /// The connection failed.
    case connectFailed = -8
    
    /// Dynamic allocation of resources failed.
    case insufficientResources = -9
    
    /// Address argument was out-of-bounds or inaccessible.
    case invalidAddress = -10
    
    /// Address was mis-aligned (usually not on a word boundary).
    case badAlignment = -11
    
    /// Something failed in the past, preventing servicing the current request.
    case invalidState = -12
    
    /// A user-allocated buffer was too small to hold the result.
    case bufferTooSmall = -13
    
    /// The call failed because another function must be called first.
    case preconditionNotMet = -14
    
    /// Cached data was determined to be inconsistent with the actual version.
    case modifiedData = -15
    
    /// A data structure failed to validate.
    case invalidData = -16
    
    /// Attempted to access something that does not exist; search failed.
    case notFound = -17
    
    /// Write is impossible based on previous writes (e.g. attempted to clear an OTP bit).
    case unsupportedModification = -18
    
    /// A required lock is not owned.
    case lockRequired = -19
    
    /// A version mismatch occurred (e.g. running incompatible code).
    case versionMismatch = -20
    
    /// The call could not proceed because required resources were unavailable.
    case resourceInUse = -21
}