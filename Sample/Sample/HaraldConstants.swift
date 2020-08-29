//
//  HaraldConstants
//

import Foundation

public struct HaraldConstants {
    public static let PERIPHERAL_PREFIX = "konashi"

    public static let SERVICE_UUID = "229BFF00-03FB-40DA-98A7-B0DEF65C2D4B"

    // UART
    public static let UART_CONFIG_UUID       = "229B3010-03FB-40DA-98A7-B0DEF65C2D4B"
    public static let UART_BAUDRATE_UUID = "229B3011-03FB-40DA-98A7-B0DEF65C2D4B"
    public static let UART_TX_UUID = "229B3012-03FB-40DA-98A7-B0DEF65C2D4B"
    public static let UART_RX_NOTIFICATION_UUID = "229B3013-03FB-40DA-98A7-B0DEF65C2D4B"

    public static let KONASHI_UART_BAUDRATE: CUnsignedChar = 0x0028
}
