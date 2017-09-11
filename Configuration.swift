//
//  Configuration.swift
//  BLELib
//
//  Created by Arpi Derm on 4/11/17.
//  Copyright © 2017 . All rights reserved.
//



//Error tuple to handler all exceptions

public typealias ERROR = (errorCode:Int,description:String)


//Notificaion Observer Names

let BLE_FAILED_TO_CONNECT_NOTIFICATION                 = "BLE_FAILED_TO_CONNECT"
let BLE_CONNECTED_NOTIFICATION                         = "BLE_CONNECTED"
let BLE_ERROR_ACCURED_NOTIFICATION                     = "BLE_ERROR"
let BLE_DISCONNECT_NOTIFICATION                        = "BLE_DISCONNECTED"
let BLE_RECIEVED_RESPONSE_NOTIFICATION                 = "BLE_RECIEVED_NOTIFICATION"

let BLE_RECIEVED_RESPONSE_NOTIFICATION_USER_INFO_PARAM = "byteArray"


//User Defaults
//parameter names saved in user defaults to access

let PERIPHERAL_DEVICE_NAME_LIST_DEFAULTS    = "PERIPHERAL_DEVICE_NAMES"
let CURRENT_SELECTED_DEVICE_NAME_DEFAULTS   = "CUURENT_SELECTED_DEVICE_NAME"

let CONNECTION_TIMEOUT_VALUE                = 10
