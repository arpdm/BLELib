//
//  CoreBTLibConfig.swift
//  CoreBTLib
//
//  Created by Arpi Derm on 4/11/17.
//  Copyright © 2017 . All rights reserved.
//



//Error tuple to handler all exceptions

public typealias ERROR = (errorCode:Int,description:String)

//Peripheral States Hold All The Possible States the are Bluetooth Module Connection Can Be In

public enum PERIPHERAL_STATE{
    
    case IDLE
    case CONNECTING
    case CONNECTED
    case CONNECTION_FAILED
    case DISCONNECTED
    
}

let DEVICE_PAIRING_STATE_PARAM  = "DEVICE_PAIRING_STATE"                                //Parameter To Keep Track Of Pairing State
let CORE_BT_BLE_ENABLED         = true                                                  //Low Energy / Class Mode  Configuration. true = Low Energy, false = Classic


//This Structure Contains all the nceseccary parameters to monitor the BT Peripheral Device

public struct CORE_BT_STATE{
    
    public var peripheralState     = PERIPHERAL_STATE.IDLE                                     //Current State Of Connection With Peripheral Device
    public var RSSISignalStrength  = 0                                                         //Value Range: 0 - 100
    public var bluetoothON         = false                                                     //State of device bluetooth (ON/OFF)
    
}

//Error Codes

let TRANSMISSION_ERROR  = ERROR(errorCode:200,description:"FAILED TO TRANSMIT DATA")

//Notificaion Observer Names

let BLE_FAILED_TO_CONNECT_NOTIFICATION      = "BLE_FAILED_TO_CONNECT"
let BLE_CONNECTED_NOTIFICATION              = "BLE_CONNECTED"
let BLE_ERROR_ACCURED_NOTIFICATION          = "BLE_ERROR"
let BLE_DISCONNECT_NOTIFICATION             = "BLE_DISCONNECTED"
let BLE_RECIEVED_RESPONSE_NOTIFICATION      = "BLE_RECIEVED_NOTIFICATION"

//User Defaults
//Small parameters to save in non volatile memory with easy access

let PERIPHERAL_DEVICE_NAME_LIST_DEFAULTS    = "PERIPHERAL_DEVICE_NAMES"
let CURRENT_SELECTED_DEVICE_NAME_DEFAULTS   = "CUURENT_SELECTED_DEVICE_NAME"

let CONNECTION_TIMEOUT_VALUE                = 10
