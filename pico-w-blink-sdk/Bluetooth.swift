extension CYW43 {

    final class Bluetooth {

        static let shared = Bluetooth()

        private var callbackRegistration = btstack_packet_callback_registration_t()

        fileprivate(set) var state: State = .off

        var advertisement = LowEnergyAdvertisingData() {
            didSet {
                let length = advertisement.length
                self.advertisementBuffer = [UInt8](advertisement)
                gap_advertisements_set_data(length, &advertisementBuffer)
            }
        }

        private var advertisementBuffer = [UInt8]()

        var scanResponse = LowEnergyAdvertisingData() {
            didSet {

            }
        }

        private init() {
            // register for callbacks
            callbackRegistration.callback = _bluetooth_packet_handler
            hci_add_event_handler(&callbackRegistration)
        }

        deinit {
            hci_remove_event_handler(&callbackRegistration)
        }
    }
}

extension CYW43.Bluetooth {

    func setPower(_ state: PowerState) {
        hci_power_control(.init(rawValue: state.rawValue))
    }
}

extension CYW43.Bluetooth {

    enum PowerState: UInt8, Sendable {

        case off    = 0
        case on     = 1
        case sleep  = 2
    }

    enum State: UInt8 {

        case off            = 0
        case initializing   = 1
        case on             = 2
        case halting        = 3
        case sleeping       = 4
        case fallingAsleep  = 5
    }
}

// packet_handler(uint8_t packet_type, uint16_t channel, uint8_t *packet, uint16_t size)
@_documentation(visibility: internal)
@_cdecl("bluetooth_packet_handler") 
internal func _bluetooth_packet_handler(packetType: UInt8, channel: UInt16, packetPointer: UnsafeMutablePointer<UInt8>?, packetSize: UInt16) {
    
    switch packetType {
        case UInt8(HCI_EVENT_PACKET):
            switch hci_event_packet_get_type(packetPointer) {
                case UInt8(BTSTACK_EVENT_STATE):
                    let rawState = btstack_event_state_get_state(packetPointer)
                    let newValue = CYW43.Bluetooth.State(rawValue: rawState) ?? .off
                    CYW43.Bluetooth.shared.state = newValue
                case UInt8(HCI_EVENT_VENDOR_SPECIFIC):
                    break
                default:
                    break
            }
        default:
            break
    }
}