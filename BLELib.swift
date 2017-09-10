//
//  BLELib.swift
//
//  Created by Arpi Derm on 9/9/17.
//  Copyright © 2017 Arpi Derm. All rights reserved.
//

import Foundation
import CoreBluetooth


public class BLELib:NSObject,CBCentralManagerDelegate,CBPeripheralDelegate{
    
    
    private var DebugMode = false
    
    private var CB_Central_Manager = CBCentralManager()
    private var PeripheralDevice:CBPeripheral?              //Discovered Peripheral Device
    private var TrasnmitCharacteristic:CBCharacteristic?    //Sercice Characteristic For reading and writing
    private var PeripheralDevices:[CBPeripheral] = []       //List Of Filtered Peripheral Devices
    private var PeripheralDeviceNames:[String]   = []       //List of Filtered Peripheral Device Names
  
    private var DataFromPeriperalAscii:String?              //Incomming Data From BT Peripheral In ASCII Mode
    private var DataFromPeriperalByteArray:[UInt8]?         //Incomming Data From BT Peripheral In Byte Array Mode
    
    
    //Services and Characteristics
    
    private var selectedCharacteristic  = ""

    /*****************************************************************************
     * Function :   Initialize
     * Input    :   debugMode (Bool) , characteristic UUID to read/write
     * Output   :   none
     * Comment  :   Initialize Central Manager To Handle all BLE Connections
     *              TO Untegrate this library we have to start from here
     ****************************************************************************/
    
    public func Initialize(debugMode:Bool,characteristicUUID:String){
        
        self.Cleanup()
        
        self.DebugMode = debugMode
        self.selectedCharacteristic = characteristicUUID
        
        //Instantiate New Central Manager
        CB_Central_Manager = CBCentralManager(delegate: self, queue: nil)
        
        self.logger(msg: "INITIALIZING THE CENTRAL DEVICE MANAGER")
        
    }
    
    /*****************************************************************************
     * Function :   centralManagerDidUpdateState
     * Input    :   CBCentralManager
     * Output   :   none
     * Comment  :   This function is fired on notifications
     *              It gets fired, when there is a change is state
     ****************************************************************************/
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager){
        
        switch central.state{
            
        case .poweredOn:
            
            self.logger(msg: "GOING TO SCAN FOR DEVICES")
            
            //As soon as we detect bluetooth is on, start scanning for nearby devices
            self.startScanning()
            
        case .resetting:
            
            self.logger(msg: "RESETTING")
            //TODO: We will decide what to do here later on
            break
            
        case .unauthorized:
            
            self.logger(msg: "UNAUtHORIZED")
            //TODO: We will decide what to do here later on
            break
            
        case .unknown:
            
            self.logger(msg: "UNKNOWN")
            //TODO: We will decide what to do here later on
            break
            
        case .unsupported:
            
            self.logger(msg: "UNSOPPORTED")
            //TODO: We will decide what to do here later on
            break
            
        }
        
    }
    
    /*****************************************************************************
     * Function :   StartScanning
     * Input    :   none
     * Output   :   none
     * Comment  :   Trigger Peripheral Device Scan Function
     ****************************************************************************/
    
    private func startScanning(){
        
        //Before scanning for devices, we want to reset all the containters
        self.PeripheralDevices = []
        self.PeripheralDeviceNames = []
        
        self.CB_Central_Manager.scanForPeripherals(withServices: nil, options: nil)
        self.logger(msg: "START SCANNING FORE DEVICCES")
        
    }

    /*****************************************************************************
     * Function :   DidDiscoverPeripheral
     * Input    :   none
     * Output   :   none
     * Comment  :   Notification Triggered When Peripheral Device Is Discovered
     ****************************************************************************/
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        

        //We will add all the devices in separate array and all device names in another array
        //These arrays will be used for connection to compare the desired BT name against the list to see if it is even discovered
        self.PeripheralDevices.append(peripheral)
        
        if peripheral.name != nil{
            
            self.PeripheralDeviceNames.append(peripheral.name!)
            
        }
    
    }
    
    /*****************************************************************************
     * Function :   ConnectToPeripheralDevice
     * Input    :   Device Name - String
     * Output   :   none
     * Comment  :   Connect to selected device specified by the user
     ****************************************************************************/
    
    public func ConnectToPeripheralDevice(deviceName:String){
        
        for device in PeripheralDevices{
            
            if device.name != nil{
                
                if device.name! == deviceName{
                    
                    self.PeripheralDevice = device
                    self.CB_Central_Manager.connect(self.PeripheralDevice!, options: nil)
                    
                }
            }
        }
    }
    
    /*****************************************************************************
     * Function :   DidFailToConnect
     * Input    :   none
     * Output   :   none
     * Comment  :   Notification Triggered when Failed to connect to device
     ****************************************************************************/
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_FAILED_TO_CONNECT_NOTIFICATION), object: nil)
        
    }
    
    /*****************************************************************************
     * Function :   DidConnect
     * Input    :   none
     * Output   :   none
     * Comment  :   Notification Triggered when connection to peripheral device is successfull
     ****************************************************************************/
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        
        //Notify the libaray that connection was successfull
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_CONNECTED_NOTIFICATION), object: nil)
        
        self.PeripheralDevice = peripheral
        self.CB_Central_Manager.stopScan()
        self.PeripheralDevice!.delegate = self
        
        //Start Discovering Services
        self.PeripheralDevice!.discoverServices(nil)
        
    }
    
    /*****************************************************************************
     * Function :   DidDiscoverServices
     * Input    :   none
     * Output   :   none
     * Comment  :   Notification Triggered when services are discovered
     ****************************************************************************/
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        
        guard ((error) == nil) else{
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_ERROR_ACCURED_NOTIFICATION), object: nil)
            self.Cleanup()
            return
            
        }
        
        //Discover characteristics for each service
        for service in peripheral.services!{
            
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
    }
    
    /*****************************************************************************
     * Function :   DidDiscoverCharacteristicsForService
     * Input    :   none
     * Output   :   none
     * Comment  :   Notification Triggered when characteristics are discovered. Then notifications are enabled for RX and TX
     ****************************************************************************/
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        
        guard (error) == nil else{
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_ERROR_ACCURED_NOTIFICATION), object: nil)
            self.Cleanup()
            return
            
        }
        
        self.logger(msg: "SERVICE CHARACTERISTICS: \(String(describing: service.characteristics))")
        
        for characteristic in service.characteristics!{
            
            if characteristic.uuid == CBUUID(string: selectedCharacteristic){
                
                //Enable the notification
                self.TrasnmitCharacteristic = characteristic
                self.logger(msg: "ENABLED NOTIFICATION FOR RX/TX OPERATIONS")
                self.PeripheralDevice!.setNotifyValue(true, for: characteristic)
                
            }
            
        }
        
    }
    
    /*****************************************************************************
     * Function :   logger
     * Input    :   none
     * Output   :   none
     * Comment  :   If Debug Mode Is True, logs data on terminal
     ****************************************************************************/
    
    private func logger(msg:String){
        
        if self.DebugMode == true{
            
            print("BLELib ===== \(msg)")
            
        }
        
    }
    
    /*****************************************************************************
     * Function :   TransmitData
     * Input    :   Byte Array : Hex Values in Decimal Number Format
     * Output   :   none
     * Comment  :   Notification gets triggered when there is incomming value from BT Module
     ****************************************************************************/
    
    public func TransmitData(byteArray:[UInt8]){
        
        guard TrasnmitCharacteristic != nil else{
            return
        }
        
        let data = Data(bytes: byteArray)
        self.logger(msg: "DATA TO TRANSMIT: \(byteArray)")
        
        self.PeripheralDevice!.writeValue(data as Data, for: TrasnmitCharacteristic!, type: .withoutResponse)
        
    }
    
    /*****************************************************************************
     * Function :   DidUpdateValueForCharacteristic
     * Input    :   none
     * Output   :   none
     * Comment  :   Notification gets triggered when there is incomming value from BT Module
     ****************************************************************************/
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        
        guard error == nil else{
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_ERROR_ACCURED_NOTIFICATION), object: nil)
            return
            
        }
        
        if characteristic.value != nil{
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_RECIEVED_RESPONSE_NOTIFICATION), object: nil)
            
            DataFromPeriperalAscii = String(data: characteristic.value!, encoding: String.Encoding.utf8)
            DataFromPeriperalByteArray = [UInt8](characteristic.value!)
            
            self.logger(msg: "DATA FROM BT - BLE MODULE - ASCII: \(String(describing: DataFromPeriperalAscii))")
            self.logger(msg: "DATA FROM BT - BLE MODULE - BYTE ARRAY: \(String(describing: DataFromPeriperalByteArray))")
            
        }
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?){
        
        //NOTE: I am not sure if we want to use this at this point. We might do something with it later
        self.logger(msg: "CHARACTERISTIC NOTIFICATION STATE CHANGED TO : \(characteristic.isNotifying)")
        
    }
    
    /*****************************************************************************
     * Function :   didDisconnectPeripheral
     * Input    :   none
     * Output   :   none
     * Comment  :   Notification Triggered when Peripheral Device Gets Disconnected
     *              This notification gets triggered from Apple's Core Bluetooth Framework
     *              We dont have control over how this notification gets triggered
     ****************************************************************************/
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_DISCONNECT_NOTIFICATION), object: nil)
        
    }
    
    /*****************************************************************************
     * Function :   Cleanup
     * Input    :   none
     * Output   :   none
     * Comment  :   Disables all the notifications for specified characteristics
     *              and cancels connection with the peripheral device
     ****************************************************************************/
    
    private func Cleanup(){
        
        //Just making sure we dont modify a characteristic that is not there
        //This is just a way of cleaning things up before we open up new connections
        
        guard TrasnmitCharacteristic != nil else{
            
            return
            
        }
        
        //Disable Notification
        self.PeripheralDevice?.setNotifyValue(false, for: TrasnmitCharacteristic!)
        
        //Close connection
        self.CB_Central_Manager.cancelPeripheralConnection(self.PeripheralDevice!)
        
    }
    
    /*****************************************************************************
     * Function :   Disconnect
     * Input    :   none
     * Output   :   none
     * Comment  :   Disconnect From BT Module
     *              This closes the connection between Peripheral and Central
     *              Device
     ****************************************************************************/
    
    public func DisconnectFromPeripheralDevice(){
        
        //Just making sure we dont modify a characteristic that is not there
        
        guard TrasnmitCharacteristic != nil else{
            
            return
            
        }
        
        self.PeripheralDevice?.setNotifyValue(false, for: TrasnmitCharacteristic!)
        self.CB_Central_Manager.cancelPeripheralConnection(self.PeripheralDevice!)
        
    }
    
    /*****************************************************************************
     * Function :   GetDeviceNames
     * Input    :   none
     * Output   :   Array of Strings
     * Comment  :   Fetch all the devices saved in the Non Volatile Memory
     ****************************************************************************/
    
    public func GetDeviceNames()->[String]?{
        
        return self.PeripheralDeviceNames
        
    }
    
}