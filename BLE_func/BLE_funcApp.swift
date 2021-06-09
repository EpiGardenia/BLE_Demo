//
//  BLE_funcApp.swift
//  BLE_func
//
//  Created by T  on 2021-06-03.
//

import SwiftUI

@main
struct BLE_funcApp: App {
    @Environment(\.scenePhase) var scenePhase
    private var bleManager = BLEManager()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(bleManager)
        }
    }
}
