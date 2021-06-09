//
//  CBPeripheralState_ext.swift
//  BLE_func
//
//  Created by T  on 2021-06-07.
//

import CoreBluetooth
extension CBPeripheralState {
    var desc: String {
        switch self {
            case .connected:
                return "Connected"
            case .disconnected:
                return "Disconnected"
            case .connecting:
                return "Connecting"
            case .disconnecting:
                return "Disconnecting"
            @unknown default:
                fatalError()
        }
    }
}

extension CBPeripheral {
    func toggleAction(bleManager: BLEManager) {
        switch self.state {
            case CBPeripheralState.connected:
                bleManager.disconnecting(peripheral: self)
            case CBPeripheralState.disconnected:
                bleManager.connecting(peripheral: self)
            default:
                print("toggleAction: state\(self.state)")
        }
    }
}
