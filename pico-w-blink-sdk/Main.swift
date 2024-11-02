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

struct CYW43: ~Copyable {

    /// Initialize the CYW43 architecture. 
    /// 
    /// [Documentation](https://www.raspberrypi.com/documentation/pico-sdk/networking.html#group_pico_cyw43_arch_1ga7a05bd21f02a0effadbba1e8266b8771)
    init() throws(PicoError) {
        let errorCode = cyw43_arch_init()
        guard errorCode == 0 else {
            throw PicoError(rawValue: errorCode) ?? .unknown
        }
    }

    deinit {
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

    enum GPIO: UInt32, CaseIterable, Copyable, Sendable {

        case led = 0

        case vsys = 1

        case vbus = 2
    }
}

extension CYW43 {

    struct AccessPoint: ~Copyable {

        /// Enables Wi-Fi AP (Access point) mode.
        /// 
        /// This enables the Wi-Fi in Access Point mode such that connections can be made to the device by other Wi-Fi clients.
        init(
            ssid: StaticString,
            password: StaticString, 
            authentication: WiFiAuthentication = .wpa2AESPSK
        ) throws(PicoError) {
            ssid.withUTF8Buffer { ssidBuffer in
                password.withUTF8Buffer { passwordBuffer in
                    cyw43_arch_enable_ap_mode(ssidBuffer.baseAddress, passwordBuffer.baseAddress, authentication.rawValue)
                }
            }
        }

        /// Enables Wi-Fi AP (Access point) mode.
        /// 
        /// This enables the Wi-Fi in Access Point mode such that connections can be made to the device by other Wi-Fi clients.
        init(
            ssid: StaticString
        ) throws(PicoError) {
            ssid.withUTF8Buffer { ssidBuffer in
                cyw43_arch_enable_ap_mode(ssidBuffer.baseAddress, nil, UInt32(CYW43_AUTH_OPEN))
            }
        }

        deinit {
            cyw43_arch_disable_ap_mode()
        }
    }
}

enum WiFiAuthentication: UInt32, Copyable, Sendable {
    
    /// WPA authorization using TKIP (Temporal Key Integrity Protocol).
    case wpaTKIPPSK = 0x00200002
    
    /// WPA2 authorization using AES (Advanced Encryption Standard); preferred option.
    case wpa2AESPSK = 0x00400004
    
    /// Mixed WPA/WPA2 authorization for compatibility with both types.
    case wpa2MixedPSK = 0x00400006
    
    /// WPA3 authorization using SAE (Simultaneous Authentication of Equals) with AES.
    case wpa3SAE_AESPSK = 0x01000004
    
    /// Mixed WPA2/WPA3 authorization for compatibility with both WPA2 and WPA3 devices.
    case wpa3WPA2_AESPSK = 0x01400004
}

enum PicoError: Int32, Error, Copyable, Sendable {

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