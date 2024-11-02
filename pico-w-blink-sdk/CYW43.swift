
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
}