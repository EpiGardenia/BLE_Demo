//
//  BLEManager.swift
//  BLE_func
//
//  Created by T  on 2021-06-03.
//

import CoreBluetooth

class BLEManager:  NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    let timeout: Double = 0.5
    @Published var myCentralManager : CBCentralManager!
    @Published var logging: String = "" 
    @Published var periAdvertList: [CBPeripheral: [String : Any]] = [:]

    required override init(){
        super.init()
        logging.append("\ninit()")
        myCentralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func getManager() -> String {
        return myCentralManager.debugDescription
    }

    func connecting(peripheral: CBPeripheral) {
        logging.append("\nconnecting()")
        peripheral.delegate = self
        myCentralManager.connect(peripheral, options: nil)
    }

    func isConnect(peri: CBPeripheral) -> Bool {
        return peri.state == .connected
    }

    func getPList() -> [CBPeripheral: [String: Any]] {
        return periAdvertList
    }

    func stopScan() {
        logging.append("\nStop Scanning..")
        myCentralManager.stopScan()
    }

    func startScan() {
        logging.append("\nStart Scanning..")
        _ = Timer.scheduledTimer(withTimeInterval: timeout, repeats: true) { [self] timer in
            myCentralManager.scanForPeripherals(withServices: nil, options:nil)
        }
    }

    func disconnecting(peripheral: CBPeripheral) {
        myCentralManager.cancelPeripheralConnection(peripheral)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // if bluetooth powerOn, start scanning for peripherals
        logging.append("\ncentralManagerDidUpdateState:")
        switch central.state {
            case .poweredOn:// 5
                logging.append("\nBluetooth Power On")
                print("\nBluetooth Power On")
                startScan()
            case .poweredOff:
                logging.append("\nBluetooth Power Off")
                stopScan()
            case .resetting:
                logging.append("\nBluetooth resetting")
            case .unauthorized:
                logging.append("\nBluetooth unauthorized")
            case .unknown:
                logging.append("\nBluetooth unknown")
            default:
                print("nBluetooth default")
        }
        print("New state: \(central.state.rawValue) ")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // clean up
        // start connect again
        logging.append("\nDisconnected to peripheral: \(peripheral.name ?? peripheral.identifier.description )")
        print("\nDisconnected to peripheral: \(peripheral.name ?? peripheral.identifier.description )")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        logging.append("\nConnected to peripheral: \(peripheral.name ?? peripheral.identifier.description )")
        // Stop scanning
        myCentralManager.stopScan()
        /* Optionals:
                reset characteristic values
                set the peripheral's delegate property
         */

        // call peripheral's discoverServices
        print("Connected to peripheral: \(peripheral.description)")
        peripheral.discoverServices(nil)
    }


    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        logging.append("\nFailed to connect to peripheral: \(peripheral.name ?? peripheral.identifier.description)")
        // if error is transient, try connect again
        print("Fail to connect")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        logging.append("\nDiscover peripheral: \(peripheral.name ?? peripheral.identifier.description)")
        if periAdvertList[peripheral] == nil {
            periAdvertList[peripheral] = advertisementData
        } else {
            advertisementData.forEach { adv in
                periAdvertList[peripheral]![adv.key] = adv.value
            }
        }
        /* Example of accessing specific advertisementData */
        //        if let localName = advertisementData["KCBAdvDataLocalName"] {
        //            if (advertisementData["KCBAdvDataLocalName"] as! String) != required_name {
        //                return
        //            }
        //        } else {
        //            return
        //        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        logging.append("\nDiscover peripheral service")
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
                print(service.description)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let descpriptVal = descriptor.value as? String {
            print(descpriptVal)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let charVal = characteristic.value {
            let text = String(decoding: charVal, as: UTF8.self)
            print("characteristic: \(characteristic.uuid.description): \(text)")
        }

    }



    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        logging.append("\nDiscover peripheral service Characteristics")
        service.characteristics?.forEach{ char in
            peripheral.discoverDescriptors(for: char)
            if char.properties.contains(.write) {
                print("Write")
            }
            if char.properties.contains(.read) {
                print("Read")
            }
            if char.properties.contains(.read) {
                peripheral.readValue(for: char)
            }
        }
    }


    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let descpts = characteristic.descriptors {
            descpts.forEach {
                peripheral.readValue(for: $0)
            }
        }
    }
}


extension CBCharacteristic {
    var isWritable: Bool {
        return   self.properties.contains(.write) ||
            self.properties.contains(.writeWithoutResponse)
    }
}
