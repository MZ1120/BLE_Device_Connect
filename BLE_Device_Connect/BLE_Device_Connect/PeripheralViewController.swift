//
//  PeripheralViewController.swift
//  BLE_Device_Connect
//
//  Created by Max_Zheng on 2022/7/3.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController {

    @IBOutlet weak var pTableView: UITableView!
    
    var cbManager: CBCentralManager?
    var selectedPeripheral: CBPeripheral?
    private var peripheralInfo = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    func setUp() {
        cbManager?.delegate = self
        selectedPeripheral?.delegate = self

        cbManager?.connect(selectedPeripheral!)
    }

    deinit {
    }
}

// CBCentralManager Delegate
extension PeripheralViewController:CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("peripheral: %@ connected", peripheral)

        peripheralInfo.append("peripheral:  " + peripheral.identifier.uuidString + "  connected")
        pTableView.reloadData()

        peripheral.discoverServices([BTConstants.sampleServiceUUID])

//        guard let services = peripheral.services else {
//            return
//        }
//        var serviceCBUUID:[CBUUID] = []
//        for service in services {
//            serviceCBUUID.append(service.uuid)
//        }
//        peripheral.discoverServices(serviceCBUUID)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("peripheral: %@ failed to connect", peripheral)
        let al = UIAlertController(title: "\(peripheral.identifier)", message: "failed to connect", preferredStyle: .alert)
        let ac = UIAlertAction(title: "ok", style: .cancel)
        al.addAction(ac)
        self.present(al, animated: true)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("peripheral: %@ disconnected", peripheral)
    }
}

//CBPeripheralDelegate
extension PeripheralViewController:CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error != nil)){
            print(error!.localizedDescription)
        }


        guard let service = peripheral.services?.first else {
            return
        }
        peripheral.discoverCharacteristics([BTConstants.sampleCharacteristicUUID], for: service)

//        guard let services = peripheral.services else{
//            return
//        }

//        for service in services {
//            peripheral.discoverCharacteristics(nil, for: service)
//        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        if ((error != nil)){
            print(error!.localizedDescription)
        }

        guard let characteristics = service.characteristics else{
            return
        }

        for characteristic in characteristics {
            peripheralInfo.append("service" + service.uuid.uuidString + "characteristic: " + characteristic.uuid.uuidString)
            peripheral.setNotifyValue(true, for: characteristic)
        }
        pTableView.reloadData()
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
    }
}

//TableView Delegate
extension PeripheralViewController:UITableViewDelegate,UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralInfo.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "attributeCell")
        cell.textLabel?.text = peripheralInfo[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }

}
