//
//  AppDelegate.swift
//  Sample
//
//  Created by ichise on 2017/07/19.
//  Copyright © 2017年 ichise. All rights reserved.
//

import UIKit
import Harald
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        prepareHarald()
        
        return true
    }
    
    func prepareHarald() {
        let peripheralPrefix = HaraldConstants.PERIPHERAL_PREFIX
        
        let serviceUUID = CBUUID(string: HaraldConstants.SERVICE_UUID)
        
        let configUUID = CBUUID(string: HaraldConstants.UART_CONFIG_UUID)
        let baudrateUUID = CBUUID(string: HaraldConstants.UART_BAUDRATE_UUID)
        let txUUID = CBUUID(string: HaraldConstants.UART_TX_UUID)
        let rxNotificationUUID = CBUUID(string: HaraldConstants.UART_RX_NOTIFICATION_UUID)
        
        Harald.shared.prepareForKonashi(peripheralPrefix: peripheralPrefix, serviceUUID: serviceUUID, txUUID: txUUID, rxNotificationUUID: rxNotificationUUID, configUUID: configUUID, baundrateUUID: baudrateUUID)
    }
}

