//
//  Harald+Peripheral.swift
//  Harald
//
//  Created by tichise on 2018年9月2日 18/09/02.
//  Copyright © 2018年 tichise. All rights reserved.
//

import Foundation
import CoreBluetooth

extension Harald {
    
    /**
     * 機器に接続する
     */
    public func connect(peripheral: CBPeripheral) {
        if self.centralManager.state != .poweredOn {
            if isDebug {haraldDelegate?.receiveLog(message: "Couldn´t connect to peripheral")}
            return
        }
                
        self.centralManager.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : NSNumber(value: true)])
    }
    
    /**
     * 機器の接続を解除する
     */
    public func disconnect(peripheral: CBPeripheral) {
        if self.centralManager.state != .poweredOn {
            if isDebug {haraldDelegate?.receiveLog(message: "Couldn´t disconnect from peripheral")}
            return
        }
        
        self.centralManager.cancelPeripheralConnection(peripheral)
    }
}
