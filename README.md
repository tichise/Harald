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

#### delegate

```
extension DevicesViewPresenter: HaraldDelegate {

    // MARK: - HaraldDelegate

    func bleDidUpdateState(_ state: CBManagerState) {
        switch state {
        case .unknown:
            TILogger().info("Central manager state: Unknown")
        case .resetting:
            TILogger().info("Central manager state: Resseting")
        case .unsupported:
            TILogger().info("Central manager state: Unsopported")
        case .unauthorized:
            TILogger().info("Central manager state: Unauthorized")
        case .poweredOff:
            TILogger().info("Central manager state: Powered off")
        case .poweredOn:
            TILogger().info("Central manager state: Powered on")

            // このタイミング以外でstartScanningを実行するとエラーが出る
            Harald.shared.startScanning(30)
        @unknown default:
            fatalError()
        }
    }

    func bleDiscoverPeripheral(_ peripheral: CBPeripheral) {
        DevicesManager.shared.setDevice(peripheral:peripheral)

        Harald.shared.connect(peripheral: peripheral) {

        }

        self.reloadData()
    }

    func bleDidConnectToPeripheral(_ peripheral: CBPeripheral) {
        DevicesManager.shared.updateIsConnect(uuidString:peripheral.identifier.uuidString, isConnect: true)
        self.reloadData()

        view?.toast(text: NSLocalizedString("connected to Bluetooth", comment: ""))

    }

    func bleDidDisconenctFromPeripheral(_ peripheral: CBPeripheral) {
        DevicesManager.shared.updateIsConnect(uuidString:peripheral.identifier.uuidString, isConnect: false)
        self.reloadData()

        view?.toast(text: NSLocalizedString("disconnected Bluetooth", comment: ""))

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 1.0秒後に実行したい処理
            NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.connectPeripheral), object: nil)
        }
    }
    
    

    func bleDidReceiveData(_ peripheral: CBPeripheral, data: Data?) {
        guard let data = data else {
            return
        }

        guard let baseString = String(data: data, encoding: .ascii) else {
            return
        }

        // 先頭1バイトを無視して、その後ろの文字列を全て取得
        let addText = String(baseString[baseString.index(baseString.startIndex, offsetBy: 1)..<baseString.index(baseString.endIndex, offsetBy: 0)])

        receiveMessage = receiveMessage + addText
        
        if receiveMessage.hasSuffix(";") {
            let sendTextArray: [String] = receiveMessage.components(separatedBy: ";")
                        
            for sendText in sendTextArray {
                executeRxAction(peripheral: peripheral, text: sendText+";")
            }
                
            receiveMessage = ""
        }
    }
    
    func bleDiscoverTxCharacteristic(txCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {

        DevicesManager.shared.set(uuidString: peripheral.identifier.uuidString, txCharacteristic: txCharacteristic)
    }

    func bleDiscoverRxNotificationCharacteristic(rxNotificationCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {

        DevicesManager.shared.set(uuidString: peripheral.identifier.uuidString, rxNotificationCharacteristic: rxNotificationCharacteristic)
    }

    func bleDiscoverBaudrateCharacteristic(baudrateCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {

        DevicesManager.shared.set(uuidString: peripheral.identifier.uuidString, baudrateCharacteristic: baudrateCharacteristic)
    }

    func bleDiscoverConfigCharacteristic(configCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {

        DevicesManager.shared.set(uuidString: peripheral.identifier.uuidString, configCharacteristic: configCharacteristic)
    }
    
    func receiveLog(message: String) {
        // TILogger().info(message)
    }
```

#### connection
```

```
Harald.shared.haraldDelegate = self

guard let peripheral = device.peripheral else {
            return
        }

        // 接続済の場合
        if device.isConnect {
            Harald.shared.discoverServices(peripheral:peripheral)
            view?.pushDevice(indexPath: indexPath)
        } else {
            Harald.shared.connect(peripheral: peripheral) {
                self.reloadData()
            }
        }
```
```
