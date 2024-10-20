//
//  ContentView.swift
//  BLESearchDemo
//
//  Created by Andrew Wang on 2024/10/21.
//

import SwiftUI
import SwiftData
import CoreBluetooth

struct BluetoothDevice: Identifiable {
    let id = UUID()
    let name: String
    let peripheral: CBPeripheral
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    @Published var discoveredPeripherals: [(peripheral: CBPeripheral, rssi: Int)] = []

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        discoveredPeripherals.removeAll() // 清空之前的扫描结果
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // 检查设备是否已经存在于已发现的设备列表中
        if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral.identifier == peripheral.identifier }) {
            // 如果设备已经存在，则更新其RSSI值
            discoveredPeripherals[index].rssi = RSSI.intValue
        } else {
            // 如果设备不存在，则添加到已发现设备列表
            discoveredPeripherals.append((peripheral: peripheral, rssi: RSSI.intValue))
        }
        // 按照RSSI值从高到低排序
        discoveredPeripherals.sort { $0.rssi > $1.rssi }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Bluetooth is not available.")
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown device")")
    }
}


struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()

    var body: some View {
        VStack {
            Button("Search for Bluetooth Devices") {
                bluetoothManager.startScanning()
            }
            List(bluetoothManager.discoveredPeripherals, id: \.peripheral.identifier) { device in
                Text("\(device.peripheral.name ?? "Unknown") - RSSI: \(device.rssi)")
                    .onTapGesture {
                        bluetoothManager.connect(to: device.peripheral)
                    }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
