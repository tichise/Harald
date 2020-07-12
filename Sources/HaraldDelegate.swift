//
//  HaraldDelegate.swift
//  Harald
//
//  Created by tichise on 2018年9月2日 18/09/02.
//  Copyright © 2018年 tichise. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol HaraldDelegate {
    func bleDidUpdateState(_ state: CBManagerState)
    func bleDiscoverPeripheral(_ peripheral: CBPeripheral)
    func bleDidConnectToPeripheral(_ peripheral: CBPeripheral)
    func bleDidDisconenctFromPeripheral(_ peripheral: CBPeripheral)
    func bleDidReceiveData(_ peripheral: CBPeripheral, data: Data?)
    
    func bleDiscoverTxCharacteristic(txCharacteristic: CBCharacteristic?, peripheral: CBPeripheral)
    func bleDiscoverRxNotificationCharacteristic(rxNotificationCharacteristic:
        CBCharacteristic?, peripheral: CBPeripheral)
    func bleDiscoverBaudrateCharacteristic(baudrateCharacteristic:
        CBCharacteristic?, peripheral: CBPeripheral)
    func bleDiscoverConfigCharacteristic(configCharacteristic:
        CBCharacteristic?, peripheral: CBPeripheral)
    func receiveLog(message: String)
}
