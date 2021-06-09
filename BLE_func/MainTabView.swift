////
////  TabView.swift
////  BLE_func
////
////  Created by T  on 2021-06-04.
////
//
import SwiftUI
//
struct MainView: View {
    @EnvironmentObject var bleManager: BLEManager
    var body: some View {
            PeriView(pList: bleManager.getPList(), bleManager: bleManager)
    }
}
