//
//  Harald.swift
//  Harald
//
//  Copyright © 2018年 tichise. All rights reserved.
//

import Foundation
import CoreBluetooth

open class Harald: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
        
    public var haraldDelegate: HaraldDelegate?
    
    internal var centralManager: CBCentralManager!
    internal var connectCompletionHandler: (() -> Void)?
    internal var rssiCompletionHandler: ((NSNumber?, Error?) -> Void)?
    
    public static let shared: Harald = Harald()
    
    public var isDebug: Bool = false
    
    internal var bleModuleType: BLEModuleType?
    
    private var peripheralPrefix: String?
    internal var serviceUUID: CBUUID?
    private var useCharacteristics: [CBUUID] {
        
        var useCharacteristics: [CBUUID] = []
        
        if let configUUID = configUUID {
            useCharacteristics.append(configUUID)
        }
        
        if let baundrateUUID = baundrateUUID {
            useCharacteristics.append(baundrateUUID)
        }
        
        if let txUUID = txUUID {
            useCharacteristics.append(txUUID)
        }
        
        if let rxNotificationUUID = rxNotificationUUID {
            useCharacteristics.append(rxNotificationUUID)
        }
        
        return useCharacteristics
    }
    
    internal var configUUID: CBUUID?
    internal var baundrateUUID: CBUUID?
    internal var txUUID: CBUUID?
    internal var rxNotificationUUID: CBUUID?
    
    // MARK: -
    
    fileprivate override init() {
        super.init()
    }
    
    public func prepareForKonashi(peripheralPrefix: String, serviceUUID: CBUUID, txUUID: CBUUID, rxNotificationUUID: CBUUID, configUUID: CBUUID, baundrateUUID: CBUUID) {
        
        self.bleModuleType = BLEModuleType.Konashi
        
        self.peripheralPrefix = peripheralPrefix
        self.serviceUUID = serviceUUID
        
        self.txUUID = txUUID
        self.rxNotificationUUID = rxNotificationUUID
        
        self.configUUID = configUUID
        
        self.baundrateUUID = baundrateUUID
        
        // Initialize CBCentralManager
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    public func prepareForEsp32(peripheralPrefix: String, serviceUUID: CBUUID, txUUID: CBUUID, rxNotificationUUID: CBUUID) {
        
        self.bleModuleType = BLEModuleType.ESP32
        
        self.peripheralPrefix = peripheralPrefix
        self.serviceUUID = serviceUUID
        
        self.txUUID = txUUID
        self.rxNotificationUUID = rxNotificationUUID
        
        // CBCentralManager を初期化する
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    // MARK: - CBCentralManagerDelegate
    
    // 復元時に呼ばれるデリゲートメソッド
    // システムがアプリケーションを立ち上げ直してバックグラウンド状態にする際、 CBCentralManagerDelegate の centralManager:willRestoreState:メソッドが呼ばれるの で、これを実装しておきます。
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        if isDebug {haraldDelegate?.receiveLog(message: "centralManager:willRestoreState:")}
    }
    
    // セントラルマネージャの状態変化があると呼ばれる
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        self.haraldDelegate?.bleDidUpdateState(central.state)
    }
    
    // ペリフェラルが見つかると呼ばれる
    // スキャン結果を受け取る
    // 周辺にある BLE デバイスが見つかると、CBCentralManagerDelegate プロトコルの central Manager:didDiscoverPeripheral:advertisementData:RSSI:が呼ばれます。
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        
        if isDebug {
            if let deviceName = advertisementData["kCBAdvDataLocalName"] {
                // キャッシュじゃないところからデバイス名を取り出し
                 haraldDelegate?.receiveLog(message: "Discovered BLE device. uuid:\(peripheral.identifier.uuidString) name:\(String(describing: peripheral.name)) kCBAdvDataLocalName:\(deviceName)")
            }
        }
        
        // BLE機器のデバイス名を変更しても、iOSから見えるデバイス名（peripheral.name）が変わらない場合がある。
        // その場合はキャッシュを消すか、kCBAdvDataLocalNameを使う。キャッシュはbleを接続を外せば消せる
        guard let peripheralPrefix = peripheralPrefix else {
            fatalError("peripheralPrefix is not set")
        }
        
        if peripheral.name?.hasPrefix(peripheralPrefix) == true {
            self.haraldDelegate?.bleDiscoverPeripheral(peripheral)
        }
    }
    
    // ペリフェラルに接続したら呼ばれる
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        if isDebug {haraldDelegate?.receiveLog(message: "ペリフェラルとの接続に成功 \(peripheral.identifier.uuidString)")}
        
        if let handler = connectCompletionHandler {
            handler()
        }
        
        // サービス検索結果を受け取るデリゲートをセット
        peripheral.delegate = self
        
        self.haraldDelegate?.bleDidConnectToPeripheral(peripheral)
    }
    
    // centralが周辺機器との接続を作成できないときに呼び出されます。
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if isDebug {
            haraldDelegate?.receiveLog(message: "Failed to connect... \(peripheral.identifier.uuidString) error: \(error!.localizedDescription)")
        }
    }
    
    /// ペリフェラルとの既存の接続が切断されたときに呼び出されます。
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        if isDebug {
            haraldDelegate?.receiveLog(message: "Disconnected from peripheral...: \(peripheral.identifier.uuidString)")
        }
        
        if error != nil {
            if isDebug {
                haraldDelegate?.receiveLog(message: "[Error] \(error!.localizedDescription)")
            }
        }
        
        peripheral.delegate = nil
        
        self.haraldDelegate?.bleDidDisconenctFromPeripheral(peripheral)
    }
    
    // MARK: - CBPeripheralDelegate
    
    /// サービス発見したら呼ばれる
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if isDebug {
            haraldDelegate?.receiveLog(message: "didDiscoverServices")
        }
        
        if error != nil {
            if isDebug {haraldDelegate?.receiveLog(message: "Error: \(String(describing: error))")}
            return
        }
        
        let services = peripheral.services!
        
        if (services.count) <= 0 {
            if isDebug {haraldDelegate?.receiveLog(message: "Service not found")}
            return
        }
        
        if isDebug {
            haraldDelegate?.receiveLog(message: "[DEBUG] Found services for peripheral: \(peripheral.identifier.uuidString)")
            haraldDelegate?.receiveLog(message: "Discover \(services.count) service\n\(services)\n")
            haraldDelegate?.receiveLog(message: "services: \(services)")
        }
        
        for service in services {
            // peripheral.discoverCharacteristics(nil, for: service)
            
            peripheral.discoverCharacteristics(useCharacteristics, for: service)
        }
    }
    
    // キャラクタリスティックを取得したら呼ばれる
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            if isDebug {haraldDelegate?.receiveLog(message: "\(String(describing: error))")}
            return
        }
        
        if (service.characteristics?.count)! <= 0 {
            if isDebug {
                haraldDelegate?.receiveLog(message: "No characteristic found")
            }
            return
        }
        
        let characteristics = service.characteristics!
        
        if isDebug {haraldDelegate?.receiveLog(message: "\(characteristics.count)個のキャラクタリスティックを発見しました。\n")}
        
        for characteristic in characteristics {
            if isDebug {haraldDelegate?.receiveLog(message: "Characteristic is \(characteristic.uuid.uuidString)\n\n")}
            
            if characteristic.uuid.isEqual(txUUID) {
                if isDebug {haraldDelegate?.receiveLog(message: "UART_TX_UUID を発見 / writeWithoutResponse")}
                if isDebug {checkCharacteristic(characteristic: characteristic)}
                
                self.haraldDelegate?.bleDiscoverTxCharacteristic(txCharacteristic:
                    characteristic, peripheral: peripheral)
                
            } else if characteristic.uuid.isEqual(rxNotificationUUID) {
                if isDebug {haraldDelegate?.receiveLog(message: "UART_RX_NOTIFICATION_UUID を発見 / notify")}
                if isDebug {checkCharacteristic(characteristic: characteristic)}
                self.haraldDelegate?.bleDiscoverRxNotificationCharacteristic(rxNotificationCharacteristic:
                    characteristic, peripheral: peripheral)
                
                // 更新通知受け取りを開始する（ペリフェラルからデータの更新通知を受け取り、データ自体も受け取る）
                // データ更新通知の受け取りを開始するには、CBPeripheral の setNotifyValue:forCharac teristic:メソッドの第1引数にYESを渡してコールします。
                peripheral.setNotifyValue(true, for: characteristic)
                
            } else if characteristic.uuid.isEqual(baundrateUUID) {
                if isDebug {haraldDelegate?.receiveLog(message: "Discover UART_BAUDRATE_UUID / writeWithoutResponse")}
                if isDebug {checkCharacteristic(characteristic: characteristic)}
                
                self.haraldDelegate?.bleDiscoverBaudrateCharacteristic(baudrateCharacteristic:
                    characteristic, peripheral: peripheral)
                
            } else if characteristic.uuid.isEqual(configUUID) {
                if isDebug {haraldDelegate?.receiveLog(message: "Discover UART_CONFIG_UUID / writeWithoutResponse")}
                if isDebug {checkCharacteristic(characteristic: characteristic)}
                
                self.haraldDelegate?.bleDiscoverConfigCharacteristic(configCharacteristic:
                    characteristic, peripheral: peripheral)
            }
        }
    }
    
    /**
     * 通知結果
     * データ更新通知受け取り開始/停止結果を取得する
     * データ更新通知受け取り開始/停止処理（setNotifyValue）が完了すると、CBPeripheralDelegate プロトコルの peripheral:didUpdateNotificationStateForCharacteristic:error:メソッドが呼ばれます。
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            if isDebug {haraldDelegate?.receiveLog(message: "Notification state update failure / \(String(describing: error?.localizedDescription))")}
            return
        }
        
        if isDebug {haraldDelegate?.receiveLog(message: "Notification state update success / \(characteristic.isNotifying) uuid: \(characteristic.uuid), value: \(String(describing: characteristic.value))")}
    }
    
    /**
     * 送信結果
     * 書き込み結果の受信
     */
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error {
            if isDebug {haraldDelegate?.receiveLog(message: "Receive write result / \(error)")}
            return
        }
        
        if isDebug {
            haraldDelegate?.receiveLog(message: "Receive write result / characteristic UUID: \(characteristic.uuid), value: \(String(describing: characteristic.value))")
        }
    }
    
    /**
     * 受信結果
     * データ更新通知を受け取る Read結果を取得する
     * Notifyの結果を取得します
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error = error {
            if isDebug {haraldDelegate?.receiveLog(message: "Data update notification error / \(error)")}
            return
        }
        
        if characteristic.uuid == rxNotificationUUID {
            if let data = characteristic.value {
                self.haraldDelegate?.bleDidReceiveData(peripheral, data: data)
            }
        }
    }
    
    /**
     * キャラクタリスティックのプロパティを判定
     */
    private func checkCharacteristic(characteristic: CBCharacteristic) {
        if (characteristic.properties.rawValue & CBCharacteristicProperties.read.rawValue) != 0 {
            haraldDelegate?.receiveLog(message: "property is CBCharacteristicProperties.read")
        }
        
        if (characteristic.properties.rawValue & CBCharacteristicProperties.notify.rawValue) != 0 {
            haraldDelegate?.receiveLog(message: "property is CBCharacteristicProperties.notify")
        }
        
        if (characteristic.properties.rawValue & CBCharacteristicProperties.write.rawValue) != 0 {
            haraldDelegate?.receiveLog(message: "property is CBCharacteristicProperties.write")
        }
        
        if (characteristic.properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0 {
            haraldDelegate?.receiveLog(message: "property is CBCharacteristicProperties.writeWithoutResponse")
        }
    }
}
