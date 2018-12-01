//
//  SampleViewController
//  Sample
//
//  Copyright © 2017年 ichise. All rights reserved.
//

import UIKit
import Harald
import CoreBluetooth

class SampleViewController: UIViewController, HaraldDelegate {
    
    @IBOutlet weak var baseTextView:UITextView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Harald.shared.haraldDelegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - HaraldDelegate
    
    func bleDidUpdateState(_ state: CBManagerState) {
        switch state {
        case .unknown:
            print("Central manager state: Unknown")
        case .resetting:
            print("Central manager state: Resseting")
        case .unsupported:
            print("Central manager state: Unsopported")
        case .unauthorized:
            print("Central manager state: Unauthorized")
        case .poweredOff:
            print("Central manager state: Powered off")
        case .poweredOn:
            print("Central manager state: Powered on")
            
            // このタイミング以外でstartScanningを実行するとエラーが出る
            Harald.shared.startScanning(30)
        }
    }
    
    func bleDiscoverPeripheral(_ peripheral: CBPeripheral) {
        Harald.shared.connect(peripheral: peripheral) {
        }
    }
    
    func bleDidConnectToPeripheral(_ peripheral: CBPeripheral) {
        // The application connected to Bluetooth
    }
    
    func bleDidDisconenctFromPeripheral(_ peripheral: CBPeripheral) {
        
        // The application has disconnected the Bluetooth connection
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 1.0秒後に実行したい処理
            NotificationCenter.default.post(name: Notification.Name(rawValue:"connectPeripheral"), object: nil)
        }
    }
    
    func bleDidReceiveData(_ peripheral: CBPeripheral, data: Data?) {
    }
}
