
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