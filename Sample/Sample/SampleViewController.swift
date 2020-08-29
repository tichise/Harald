//
//  SampleViewController
//  Sample
//
//  Copyright © 2017年 ichise. All rights reserved.
//

import UIKit
import Harald
import CoreBluetooth
import TILogger

class Device {
    public var configCharacteristic: CBCharacteristic?
    public var baudrateCharacteristic: CBCharacteristic?
    public var txCharacteristic: CBCharacteristic?
    public var rxNotificationCharacteristic: CBCharacteristic?
}

class SampleViewController: UIViewController, HaraldDelegate {

    @IBOutlet weak var baseTextView: UITextView?
    
    var device = Device()
    
    var receiveMessage: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Harald.shared.haraldDelegate = self
        Harald.shared.isDebug = true
        
        // Initialize CBCentralManager
        if 1 == 1 {
            // konashiの場合
            let peripheralPrefix = HaraldConstants.PERIPHERAL_PREFIX
            
            let serviceUUID = CBUUID(string: HaraldConstants.SERVICE_UUID)
            
            let configUUID = CBUUID(string: HaraldConstants.UART_CONFIG_UUID)
            let baudrateUUID = CBUUID(string: HaraldConstants.UART_BAUDRATE_UUID)
            let txUUID = CBUUID(string: HaraldConstants.UART_TX_UUID)
            let rxNotificationUUID = CBUUID(string: HaraldConstants.UART_RX_NOTIFICATION_UUID)
            
            Harald.shared.isDebug = true
            Harald.shared.prepareForKonashi(peripheralPrefix: peripheralPrefix, serviceUUID: serviceUUID, txUUID: txUUID, rxNotificationUUID: rxNotificationUUID, configUUID: configUUID, baundrateUUID: baudrateUUID)
        } else {
            // M5Stackの場合
            let peripheralPrefix = HaraldConstants.PERIPHERAL_PREFIX
            
            let serviceUUID = CBUUID(string: HaraldConstants.SERVICE_UUID)
            
            let txUUID = CBUUID(string: HaraldConstants.UART_TX_UUID)
            let rxNotificationUUID = CBUUID(string: HaraldConstants.UART_RX_NOTIFICATION_UUID)
            
            Harald.shared.isDebug = true
            Harald.shared.prepareForEsp32(peripheralPrefix: peripheralPrefix, serviceUUID: serviceUUID, txUUID: txUUID, rxNotificationUUID: rxNotificationUUID)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - HaraldDelegate
    // MARK: - CBCentralManagerDelegate
    
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
    
    func bleDiscoverPeripheral(_ peripheral: CBPeripheral) {
        TILogger().info("ペリフェラルを見つけた時に呼ばれます")

        // 発見したペリフェラルに接続
        Harald.shared.connect(peripheral: peripheral)
    }
    
    /// ペリフェラルに接続したら呼ばれる
    func bleDidConnectToPeripheral(_ peripheral: CBPeripheral) {
        TILogger().info("ペリフェラルに接続したら呼ばれます")
        
        Harald.shared.discoverServices(peripheral: peripheral)
    }
    
    /// ペリフェラルとの既存の接続が切断されたときに呼び出されます
    func bleDidDisconenctFromPeripheral(_ peripheral: CBPeripheral) {
        TILogger().info("ペリフェラルとの既存の接続が切断されたときに呼び出されます")
        
        // The application has disconnected the Bluetooth connection
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 1.0秒後に実行したい処理
            NotificationCenter.default.post(name: Notification.Name(rawValue:"connectPeripheral"), object: nil)
        }
    }
    
    // キャラクタリスティック TXを発見した時に呼ばれる
    func bleDiscoverTxCharacteristic(txCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {
        TILogger().info("キャラクタリスティック TXを発見した時に呼ばれる")
        device.txCharacteristic = txCharacteristic
    }
    
    // キャラクタリスティック RXを発見した時に呼ばれる
    func bleDiscoverRxNotificationCharacteristic(rxNotificationCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {
        TILogger().info("キャラクタリスティック RXを発見した時に呼ばれる")
        device.rxNotificationCharacteristic = rxNotificationCharacteristic
    }
    
    // キャラクタリスティック Baudrateを発見した時に呼ばれる
    func bleDiscoverBaudrateCharacteristic(baudrateCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {
        TILogger().info("キャラクタリスティック Baudrateを発見した時に呼ばれる")
        device.baudrateCharacteristic = baudrateCharacteristic
        
        Harald.shared.writeBaundrate(baudrateCharacteristic: device.baudrateCharacteristic, peripheral: peripheral, baudrateRate: HaraldConstants.KONASHI_UART_BAUDRATE)
    }
    
    // キャラクタリスティック Configを発見した時に呼ばれる
    func bleDiscoverConfigCharacteristic(configCharacteristic: CBCharacteristic?, peripheral: CBPeripheral) {
        TILogger().info("キャラクタリスティック Configを発見した時に呼ばれる")
        device.configCharacteristic = configCharacteristic
        
        Harald.shared.writeConfigUuid(configCharacteristic: device.configCharacteristic, peripheral: peripheral)
    }
    
    /// データを受信した時に呼ばれる
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
    
    func receiveLog(message: String) {
        TILogger().info(message)
    }
}
