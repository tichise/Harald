### Harald

Harald is a BLE library.

### License
Harald is available under the MIT license. See the LICENSE file for more info.

### 使い方


##### prepare
```
        let peripheralPrefix = HaraldConstants.PERIPHERAL_PREFIX
        
        let serviceUUID = CBUUID(string: HaraldConstants.SERVICE_UUID)
        
        let configUUID = CBUUID(string: HaraldConstants.UART_CONFIG_UUID)
        let baudrateUUID = CBUUID(string: HaraldConstants.UART_BAUDRATE_UUID)
        let txUUID = CBUUID(string: HaraldConstants.UART_TX_UUID)
        let rxNotificationUUID = CBUUID(string: HaraldConstants.UART_RX_NOTIFICATION_UUID)
        
        Harald.shared.prepareForKonashi(peripheralPrefix: peripheralPrefix, serviceUUID: serviceUUID, txUUID: txUUID, rxNotificationUUID: rxNotificationUUID, configUUID: configUUID, baundrateUUID: baudrateUUID)
```
