//
//  PeripheralView.swift
//  BLE_func
//
//  Created by T  on 2021-06-07.
//

import SwiftUI
import CoreBluetooth

struct PeripheralView: View {
    @EnvironmentObject var bleManager: BLEManager
    let peri: CBPeripheral
    let advertisment: [String: Any]

    var body: some View {
        Form {
            Section(header: Text("Status")) { Text(peri.state.desc) }
            Section(header: Text("Name")) { Text(peri.name ?? "") }
            Section(header: Text("Identifier")) { Text(peri.identifier.uuidString) }
            Section { NavigationLink(destination: advertisementView) { Text("Advertisement") }.isDetailLink(false) }
            Section { NavigationLink(destination: servicesView) { Text("Service") }.isDetailLink(false) }
        }
        .navigationTitle("\(peri.name ?? peri.identifier.uuidString)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {  peri.toggleAction(bleManager: bleManager)}) {
                    toggleButton
                }
            }
        }
    }

    @ViewBuilder private var toggleButton: some View {
        switch peri.state {
            case CBPeripheralState.connected:
                Text("Disconnect")
            case CBPeripheralState.disconnected:
                Text("Connect")
            case .connecting:
                Text("Disconnect")
            case .disconnecting:
                Text("Connect")
            @unknown default:
                fatalError()
        }
    }

    @ViewBuilder private var advertisementView: some View {
        Form {
            ForEach(advertisment.sorted(by: { $0.key > $1.key }), id: \.key) { (key,value) in
                Section(header: Text("\(key)")) {
                    Text(String(describing: value))
                }
            }
        }.navigationTitle("Advertisement")
    }
    @ViewBuilder private var servicesView: some View {
        List{
            if let services = peri.services {
                ForEach(services.sorted(by: { $0.uuid.uuidString < $1.uuid.uuidString}), id: \.self) { service in
                    DisclosureGroup("\(service.uuid)") {
                        if let chars = service.characteristics {
                            DisclosureGroup("Characteristics") {
                                ForEach(chars.sorted(by: { $0.uuid.uuidString > $1.uuid.uuidString}), id: \.self) { characteristic in
                                    HStack {
                                        Text(characteristic.uuid.description)
                                        Spacer()
                                        if let charVal = characteristic.value {
                                  
                                                Text(String(decoding: charVal, as: UTF8.self))
                                        }
                                    }
                                    if let descripts = characteristic.descriptors {
                                        if !descripts.isEmpty {
                                            DisclosureGroup("Descriptors") {
                                                ForEach(descripts.sorted(by: { $0.uuid.uuidString > $1.uuid.uuidString}), id: \.self) {
                                                    Text($0.uuid.description)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }.padding()
                }
            }
        }.navigationTitle("Services")
    }
}
