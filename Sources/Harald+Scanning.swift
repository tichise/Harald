//
//  Harald+Scanning.swift
//  Harald
//
//  Created by tichise on 2018年9月2日 18/09/02.
//  Copyright © 2018年 tichise. All rights reserved.
//

import Foundation
import CoreBluetooth

extension Harald {
    public func startScanning(_ timeout: Double) {
        startScanning(nil, timeout: timeout)
    }
    
    public func startScanning(_ serviceUuid: String?, timeout: Double) {
        if self.centralManager.state != .poweredOn {
            if isDebug {haraldDelegate?.receiveLog(message:"Couldn´t start scanning")}
        }
        
        // 指定した秒数でタイムアウトする
        Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(Harald.scanTimeout), userInfo: nil, repeats: false)
        
        if (serviceUuid != nil) {
            let services: [CBUUID] = [CBUUID(string: serviceUuid!)]
            self.centralManager.scanForPeripherals(withServices: services, options: nil)
        } else {
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    public func stopScanning() {
        self.centralManager.stopScan()
    }
    
    @objc fileprivate func scanTimeout() {
        self.centralManager.stopScan()
    }
}
