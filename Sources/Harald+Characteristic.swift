//
//  Harald+Characteristic.swift
//  Harald
//
//  Created by tichise on 2018年9月2日 18/09/02.
//  Copyright © 2018年 tichise. All rights reserved.
//

import Foundation
import CoreBluetooth

extension Harald {
    
    public enum BLEModuleType {
        case Konashi
        case ESP32
    }
    
    public func writeUartTXCharacter(_ peripheral: CBPeripheral, character: String) {
        if bleModuleType == BLEModuleType.Konashi {
            writeUartTXCharacterForKonashi(peripheral: peripheral, character: character)
        } else if bleModuleType == BLEModuleType.ESP32 {
            writeUartTXCharacterForESP32(peripheral: peripheral, sendString: character)
        }
    }
    
    /**
     * for konashi
     */
    public func writeUartTXCharacterForKonashi(peripheral: CBPeripheral, character: String) {
        
        guard let txCharacteristic = self.txCharacteristic else {
            return
        }
        
        // ここがasciiでないと動かない、UTF-8は駄目
        let data: Data = character.data(using: String.Encoding.ascii)!
        
        // revision stringが2.x.xの時はマルチバイトで送信できる
        // 先頭1バイトはデータ長をおくる
        let d: NSMutableData = NSMutableData.init()
        var length: Int = data.count
        
        d.append(&length, length: 1)
        d.append(data)
        
        if isDebug {print("write uart tx character: \(character)")}
        
        peripheral.writeValue(d as Data, for: txCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    /**
     * for ESP32
     */
    public func writeUartTXCharacterForESP32(peripheral: CBPeripheral, sendString: String) {
        
        guard let txCharacteristic = self.txCharacteristic else {
            return
        }
        
        guard let sendData = sendString.data(using: .utf8, allowLossyConversion: true) else {
            return
        }
        
        if isDebug {print("write uart tx character:  \(sendString)")}
        
        peripheral.writeValue(sendData, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    public func writeBaundrate(peripheral: CBPeripheral, baudrateRate: CUnsignedChar) {
        guard let baudrateCharacteristic = self.baudrateCharacteristic else {
            return
        }
        
        var baudrateRateMutable = baudrateRate
        let data = Data(buffer: UnsafeBufferPointer(start: &baudrateRateMutable, count: 2))
        
        peripheral.writeValue(data as Data, for: baudrateCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    public func writeConfigUuid(peripheral: CBPeripheral) {
        guard let configCharacteristic = self.configCharacteristic else {
            return
        }
        
        let buffer: [UInt8] = [1]
        let data = Data(bytes: UnsafePointer<UInt8>(buffer), count: 1)
        
        peripheral.writeValue(data as Data, for: configCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    public func isCompleteCharacteristic() -> Bool {
        
        if configUUID != nil {
            guard self.configCharacteristic != nil else {
                return false
            }
        }
        
        if baundrateUUID != nil {
            guard self.baudrateCharacteristic != nil else {
                return false
            }
        }

        guard self.txCharacteristic != nil else {
            return false
        }
        
        guard self.rxNotificationCharacteristic != nil else {
            return false
        }
        
        return true
    }
}
