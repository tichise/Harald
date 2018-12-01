//
//  Harald+Service.swift
//  Harald
//
//  Created by tichise on 2018年9月2日 18/09/02.
//  Copyright © 2018年 tichise. All rights reserved.
//

import Foundation
import CoreBluetooth

extension Harald {
    
    public func discoverServices(peripheral: CBPeripheral) {
        if isDebug {print("Start service search")}
        
        guard let serviceUUID = self.serviceUUID else {
            fatalError("ServiceUUID is not set")
        }
        
        // サービス検索開始
        peripheral.discoverServices([serviceUUID])
    }
}
