### Harald

Harald is a BLE library.

### License
Harald is available under the MIT license. See the LICENSE file for more info.

### BLEの基本
- セントラルマネージャーを起動する。
- スキャンして、ペリフェラル（BLEデバイス）を検出する。
- ペリフェラルに接続する。
- ペリフェラルのサービスを検出する。
- サービス特性（キャラクタリスティック）を検出する。
- CONFIGとBAUDRATEの設定を行う。
- 以降はペリフェラルに対して送受信を行う。

### 登場人物

| 用語 | 説明 |
|---|---|
|CBCentralManager| セントラル側のクラス|
|CBPeripheral | ペリフェラル側のクラス|
|CBService|サービスのクラス|
|CBCharacteristic| サービスの特性|
|CBCentralManagerDelegate |電源のON/OFFの検出、ペリフェラルの検出/接続|
|CBPeripheralDelegate |サービスの検出、サービス特性の取得|


### Haraldの使い方

#### セントラルマネージャーを起動する

```
let peripheralPrefix = HaraldConstants.PERIPHERAL_PREFIX
        
let serviceUUID = CBUUID(string: HaraldConstants.SERVICE_UUID)
        
let configUUID = CBUUID(string: HaraldConstants.UART_CONFIG_UUID)
let baudrateUUID = CBUUID(string: HaraldConstants.UART_BAUDRATE_UUID)
let txUUID = CBUUID(string: HaraldConstants.UART_TX_UUID)
let rxNotificationUUID = CBUUID(string: HaraldConstants.UART_RX_NOTIFICATION_UUID)
        
Harald.shared.prepareForKonashi(peripheralPrefix: peripheralPrefix, serviceUUID: serviceUUID, txUUID: txUUID, rxNotificationUUID: rxNotificationUUID, configUUID: configUUID, baundrateUUID: baudrateUUID)
```

#### スキャンして、ペリフェラル（BLEデバイス）を検出する
電源がONになるのを待って、スキャンする。

```
// セントラルマネージャの状態変化があると呼ばれる
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
           Harald.shared.startScanning(timeout: 30)
       }
   }
```
#### ペリフェラルに接続する
ペリフェラルを検出したら、検出したペリフェラルに接続する。

```
   func bleDiscoverPeripheral(_ peripheral: CBPeripheral) {
       TILogger().info("ペリフェラルを見つけた時に呼ばれます")

       // 発見したペリフェラルに接続
       Harald.shared.connect(peripheral: peripheral)
   }
```
#### ペリフェラルのサービスを検出する
接続されたら、接続したペリフェラルのサービスを検出する。

```
 Harald.shared.discoverServices(peripheral: peripheral)
```

#### サービス特性（キャラクタリスティック）を検出する
サービスを検出したら、サービスの特性を検出する。Haraldではサービス発見したタイミングで自動的にキャラクタリスティックの検出を行う。


キャラクタリスティックが発見されると下記が呼び出される。

```
// キャラクタリスティック TXを発見した時に呼ばれる
func bleDiscoverTxCharacteristic(txCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {
    TILogger().info("キャラクタリスティック TXを発見した時に呼ばれる")
}
```

```
// キャラクタリスティック RXを発見した時に呼ばれる
func bleDiscoverRxNotificationCharacteristic(rxNotificationCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {
    TILogger().info("キャラクタリスティック RXを発見した時に呼ばれる")
}
```

```
// キャラクタリスティック Baudrateを発見した時に呼ばれる
func bleDiscoverBaudrateCharacteristic(baudrateCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {
    TILogger().info("キャラクタリスティック Baudrateを発見した時に呼ばれる")
}
```

```
// キャラクタリスティック Configを発見した時に呼ばれる
func bleDiscoverConfigCharacteristic(configCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {
    TILogger().info("キャラクタリスティック Configを発見した時に呼ばれる")
}
```

#### CONFIGとBAUDRATEの設定を行う


##### UART_BAUDRATE_UUID / writeWithoutResponse 
baudrateCharacteristicでBAUDRATEの設定を行う

```
Harald.shared.writeBaundrate(baudrateCharacteristic: device.baudrateCharacteristic, peripheral: peripheral, baudrateRate: HaraldConstants.KONASHI_UART_BAUDRATE)
```

#####  UART_CONFIG_UUID / writeWithoutResponse
configCharacteristicでbaudrateCharacteristicの設定を行う
```
Harald.shared.writeConfigUuid(configCharacteristic: device.configCharacteristic, peripheral: peripheral)
```

#### 以降はペリフェラルに対して送受信を行う


##### UART_TX_UUID / writeWithoutResponseでWriteする場合
```
Harald.shared.writeUartTXCharacter(txCharacteristic: "txCharacteristic", peripheral: peripheral, character: "matrix:eye;")
```

##### UART_RX_NOTIFICATION_UUID / notifyでNotificationを受け取る場合

送り方

```
```

bleDidReceiveDataで受け取れる
```
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
            // 受け取ったTextを元に処理する
        }
            
        receiveMessage = ""
    }
}
```
