//
//  CoreBTLib.swift
//  CoreBTLib
//
//  Created by Arpi Derm on 4/11/17.
//  Copyright © 2017. All rights reserved.
//
//
//
//  NOTE: Packet byte construction Order: Hex - >  Decimal -> Data -> BT Module
//


import UIKit

@objc public class CoreBTLib:NSObject{
    
    public var DEBUG_MODE               =   true                //User Parameter
    public var AUTO_CONNECT             =   true                //User Parameter for enablign auto connection option
    public var CORE_BT_ST               =   CORE_BT_STATE()     //Current State Of The BT
   
    private let CORE_BT_BLE             =   BTSmart()           //BLE Module
    private let CORE_BT_CLASSIC         =   BTClassic()         //Classic Module
    
    private var timeoutTimer:Timer?                             //Timout Routine Parameters
    
    var ConnectionTimeEllapsed          = 0                     //Time ellapsed while trying to connect
    var RecievedDataByte:[UInt8]?                               //Byte array recieved from peripheral device
    var BTName                          = ""                    //Peripheral Device Name
    var Characteristic                  = ""                    //Characteristic UUID used for transmitting data
    
    
    /*****************************************************************************
     * Function :   InitializeCoreBTLib
     * Input    :   none
     * Output   :   none
     * Comment  :   Initialization checks for Pairing state with the light hub.
     *              It tries to pair if not paired alread, establish connection
     *              and finally enables the notifications for desired service characteristics
     *
     ****************************************************************************/
    
    @objc public func InitializeCoreBTLib(characteristic:String){
        
        ConnectionTimeEllapsed = 0
        
        self.timeoutTimer?.invalidate()
        CORE_BT_ST = CORE_BT_STATE()
        
        self.Characteristic = characteristic
        NotificationCenter.default.removeObserver(self)
        
        //Erase al saed peripheral device names before initialization
        UserDefaults.standard.set(nil, forKey: PERIPHERAL_DEVICE_NAME_LIST_DEFAULTS)
        
        //Initialize BLE Module
        self.CORE_BT_BLE.Initialize(characteristic: self.Characteristic)
        
        //Activate the notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(CoreBTLib.ConnectedToPeripheralDevice), name: NSNotification.Name(rawValue: BLE_CONNECTED_NOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CoreBTLib.DisconnectedFromPeripheralDevice), name: NSNotification.Name(rawValue: BLE_DISCONNECT_NOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CoreBTLib.ErrorAccured), name: NSNotification.Name(rawValue: BLE_ERROR_ACCURED_NOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CoreBTLib.ConnecionFailed), name: NSNotification.Name(rawValue: BLE_FAILED_TO_CONNECT_NOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CoreBTLib.RecievedData), name: NSNotification.Name(rawValue: BLE_RECIEVED_RESPONSE_NOTIFICATION), object: nil)

    }
    
    /*****************************************************************************
     * Function :   ConnectedToPeripheralDevice
     * Input    :   Notification Object
     * Output   :   None
     * Comment  :   This notification gets recieved when Centeal and Peripheral
     *              connection has been established
     *
     ****************************************************************************/
    
    @objc private func ConnectedToPeripheralDevice(notification:Notification){
    
        CORE_BT_ST.peripheralState = PERIPHERAL_STATE.CONNECTED
    
    }
    
    /*****************************************************************************
     * Function :   DisconnectedFromsPeripheralDevice
     * Input    :   Notification Object
     * Output   :   None
     * Comment  :   This notification gets recieved when Central and Peripheral
     *              connection gets closed
     *
     ****************************************************************************/
    
    @objc private func DisconnectedFromPeripheralDevice(notification:Notification){
        
        CORE_BT_ST.peripheralState = PERIPHERAL_STATE.IDLE
        
    }
    
    /*****************************************************************************
     * Function :   ErrorAccured
     * Input    :   Notification Object
     * Output   :   None
     * Comment  :
     *
     *
     ****************************************************************************/
    
    @objc private func ErrorAccured(notification:Notification){
        
        //TODO: Decide What to do here
        
    }
    
    /*****************************************************************************
     * Function :   ConnecionFailed
     * Input    :   Notification Object
     * Output   :   None
     * Comment  :
     *
     *
     ****************************************************************************/
    
    @objc private func ConnecionFailed(notification:Notification){
        
        CORE_BT_ST.peripheralState = PERIPHERAL_STATE.CONNECTION_FAILED

    }
    
    /*****************************************************************************
     * Function :   GetCoreBTState
     * Input    :   none
     * Output   :   CORE_BT_STATE Data Structure
     * Comment  :   Send necessary BT Connection Information To Requester
     *
     *
     ****************************************************************************/
    
    public func GetCoreBTState()->CORE_BT_STATE{
        
        return CORE_BT_ST
        
    }
    
    /*****************************************************************************
     * Function :   GetDeviceNames
     * Input    :   none
     * Output   :   Array of Strings
     * Comment  :   Fetch all the devices saved in the Non Volatile Memory
     *
     *
     ****************************************************************************/
    
    public func GetDeviceNames()->[String]?{
        
        let deviceNames = UserDefaults.standard.object(forKey: PERIPHERAL_DEVICE_NAME_LIST_DEFAULTS) as? [String]
        return deviceNames
        
    }
    
    /*****************************************************************************
     * Function :   ConnectToDevice
     * Input    :   Selected Device Name - String
     * Output   :   none
     * Comment  :   Sets which device to connect to and starts the paring/connection
     *              process
     *
     ****************************************************************************/

    public func ConnectToDevice(deviceName:String){
    
        UserDefaults.standard.set(deviceName, forKey: CURRENT_SELECTED_DEVICE_NAME_DEFAULTS)
       
        self.logger(msg: "Connecting to Peripgeral device with name: \(deviceName)")
        
        CORE_BT_BLE.ConnectToPeripheralDevice(deviceName: deviceName)
        
        //Activate the timeout routine timer
        self.timeoutTimer?.invalidate()
        self.timeoutTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(CoreBTLib.ConnectionTimeoutRoutine), userInfo: nil, repeats: true)
        self.timeoutTimer?.fire()
    
    }
    
    /*****************************************************************************
     * Function :   CloseBTConnection
     * Input    :   none
     * Output   :   none
     * Comment  :   Closes current BT COnnection
     *
     *
     ****************************************************************************/
    
    public func CloseBTConnection(){
    
        CORE_BT_BLE.DisconnectFromBTModule()

    }
    
    /*****************************************************************************
     * Function :   logger
     * Input    :   none
     * Output   :   none
     * Comment  :   If Debug Mode Is True, logs data on terminal
     *
     *
     ****************************************************************************/
    
    private func logger(msg:String){
        
        if DEBUG_MODE == true{
            
            print("CoreBTLib ===== \(msg)")
            
        }
        
    }
    
    /*****************************************************************************
     * Function :   ConnectionTimeoutRoutine
     * Input    :   none
     * Output   :   none
     * Comment  :   This routine checks for the time ellapsed after conenction request
     *              handles the timeout based on timeout set
     *
     ****************************************************************************/
    
    @objc private func ConnectionTimeoutRoutine(){
        
        //We want to make sure that user presets get passed down to other classes in the framework
        self.CORE_BT_BLE.DEBUG_MODE = self.DEBUG_MODE
        
        if ConnectionTimeEllapsed != CONNECTION_TIMEOUT_VALUE{
        
            ConnectionTimeEllapsed += 1
            self.logger(msg: "CONNECTION TIME ELLAPSED: \(self.ConnectionTimeEllapsed)")
            
            if CORE_BT_ST.peripheralState == .CONNECTED{
                
                //Get out of the loop
                self.timeoutTimer?.invalidate()
                ConnectionTimeEllapsed = 0
            
            }else{
                
                CORE_BT_ST.peripheralState = .CONNECTING
            
            }
        
        }else{
        
            CORE_BT_ST.peripheralState = .CONNECTION_FAILED

        }

    }

    /*****************************************************************************
     * Function :   StartThroughputTests
     * Input    :   None
     * Output   :   None
     * Comment  :   Start transmitting packets continously with specific time interval
     *              This test function is intented for testing connection throughput
     *
     ****************************************************************************/
    
    public func TransmitData(data:[UInt8]){
        
        self.CORE_BT_BLE.TransmitData(byteArray:data)

    
    }
    
    /*****************************************************************************
     * Function :   StartThroughputTests
     * Input    :   None
     * Output   :   None
     * Comment  :
     *
     *
     ****************************************************************************/
    
    @objc private func RecievedData(){
        
        RecievedDataByte = self.CORE_BT_BLE.DataFromPeriperalByteArray
        
    }
    
    /*****************************************************************************
     * Function :   Read Data
     * Input    :   None
     * Output   :   [UInt8] Data Byte Array Recieved from Central Device
     * Comment  :
     *
     *
     ****************************************************************************/
    
    public func ReadData()->[UInt8]?{
        
        return RecievedDataByte
        
    }

}
