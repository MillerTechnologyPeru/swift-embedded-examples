extension CYW43 {

    enum GPIO: UInt32, CaseIterable, Copyable, Sendable {

        case led = 0

        case vsys = 1

        case vbus = 2
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