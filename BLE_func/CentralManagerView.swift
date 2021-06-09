//
//  CentralManagerView.swift
//  BLE_func
//
//  Created by T  on 2021-06-04.
//

import SwiftUI
import CoreBluetooth

struct PeriView: View {
    let pList: [CBPeripheral: [String: Any]]
    var bleManager: BLEManager
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(pList.sorted { $0.key.name ?? "" > $1.key.name ?? ""}, id:\.key) { peripheral in
                    NavigationLink(destination: PeripheralView(peri: peripheral.key, advertisment: peripheral.value)) {
                        VStack{
                            GroupBox(label:  Text(peripheral.key.state.desc)
                                        .font(.subheadline)) {
                                Text(peripheral.key.name ?? peripheral.key.identifier.uuidString)
                                    .font(.headline)
                            }
                        }
                    }.isDetailLink(false)
                }
            }.navigationTitle("Nearby Devices")
        }
    }
}
