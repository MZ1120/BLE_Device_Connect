//
//  ViewController.swift
//  BLE_Device_Connect
//
//  Created by Max_Zheng on 2022/7/3.
//

import UIKit
import CoreBluetooth

struct BTConstants {
    // These are sample GATT service strings. Your accessory will need to include these services/characteristics in its GATT database
    static let sampleServiceUUID = CBUUID(string: "1fee6acf-a826-4e37-9635-4d8a01642c5d")
    static let sampleCharacteristicUUID = CBUUID(string: "7691b78a-9015-4367-9b95-fc631c412cc6")
}

class CentralConnectController: UIViewController {

    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet internal var tableView: UITableView!
    private var cbManager: CBCentralManager!
    private var cbState = CBManagerState.unknown
    private var cbPeripherals = [CBPeripheral]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    func setUp() {
        cbManager = CBCentralManager(delegate: self, queue: nil)
    }

    @IBAction func scanButtonClick(_ sender: UIButton) {
        if cbManager.isScanning {
            stopScan()
        }else {
            startScan()
        }
    }

    func startScan() {
        print("Scanning...")
        scanButton.setTitle("Scanning...", for: .normal)
        cbPeripherals.removeAll()

//        let matchingOptions = [CBConnectionEventMatchingOption.serviceUUIDs: [BTConstants.sampleServiceUUID]]
//        cbManager.registerForConnectionEvents(options: matchingOptions)

        cbManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }

    func stopScan() {
        print("Stop Scan")
        scanButton.setTitle("Scan", for: .normal)
        cbManager.stopScan()
    }
}

// CBCentralManager Delegate
extension CentralConnectController:CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // In your application, you would address each possible value of central.state and central.authorization
        switch central.state {
        case .resetting:
            print("Connection with the system service was momentarily lost. Update imminent")
        case .unsupported:
            print("Platform does not support the Bluetooth Low Energy Central/Client role")
        case .unauthorized:
            print("The application is not authorized to use the Bluetooth Low Energy role")
        case .poweredOff:
            print("Bluetooth is currently powered off")
        case .poweredOn:
            print("Starting cbManager")
        default:
            print("Cleaning up cbManager")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        preparePeripheralsFound(peripheral: peripheral)
    }

    func preparePeripheralsFound(peripheral:CBPeripheral) {

        if cbPeripherals.contains(peripheral){

        }else {
            print("-------------")
            print("identifier:",peripheral.identifier)
            print("name:",peripheral.name)
            print("services:",peripheral.services)

            cbPeripherals.append(peripheral)
            tableView.reloadData()
        }

    }

//    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
//        print("connectionEventDidOccur for peripheral: %@", peripheral)
//        switch event {
//        case .peerConnected:
//            cbPeripherals.append(peripheral)
//        case .peerDisconnected:
//            print("Peer %@ disconnected!", peripheral)
//        default:
//            if let idx = cbPeripherals.firstIndex(where: { $0 === peripheral }) {
//                cbPeripherals.remove(at: idx)
//            }
//        }
//        tableView.reloadData()
//    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("peripheral: %@ connected", peripheral)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("peripheral: %@ failed to connect", peripheral)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("peripheral: %@ disconnected", peripheral)
    }
}

//TableView Delegate
extension CentralConnectController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cbPeripherals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "peripheralCell")
        let index = cbPeripherals.count - (indexPath.row + 1)
        cell.textLabel?.text = "\(cbPeripherals[index].name ?? "unknown")"
        cell.detailTextLabel?.text = "\(cbPeripherals[index].identifier)"
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let index = cbPeripherals.count - (indexPath.row + 1)

        let al = UIAlertController(title: "\(cbPeripherals[index].identifier)", message: "\(cbPeripherals[index].name ?? "unknown")", preferredStyle: .alert)
        let ac = UIAlertAction(title: "ok", style: .cancel)
        al.addAction(ac)
        self.present(al, animated: true)

    }

}
