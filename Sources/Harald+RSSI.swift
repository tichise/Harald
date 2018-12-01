//
//  Harald+RSSI.swift
//  Harald
//
//  Created by tichise on 2018年9月2日 18/09/02.
//  Copyright © 2018年 tichise. All rights reserved.
//

import Foundation
import CoreBluetooth

extension Harald {
    
    public func readRSSI(peripheral: CBPeripheral, rssiCompletionHandler: ((NSNumber?, Error?) -> Void)?) {
        self.rssiCompletionHandler = rssiCompletionHandler
        
        peripheral.readRSSI()
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if let rssiCompletionHandler = rssiCompletionHandler {
            rssiCompletionHandler(RSSI, error)
        }
    }
}
