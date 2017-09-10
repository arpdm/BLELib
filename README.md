# BLELib

  This library helps developing Bluetooth Low Energy software to communicate with peripheral devices. This library is notification based. Instead of polling regularly for incoming data and state change, notifications will be triggered as soon as new data is received or state changes occur. 
  
  Language | Version | OS Support
------------ | -------------  | -------------
Swift 3.0 | 1.0.0 | IOS/OSX


### Library Specifications:

Following notifications are sent by the library. When implementing this code, observers should be added for following notifications.

  Notification Name | Description
------------ | -------------  
BLE_FAILED_TO_CONNECT | This notification is triggered when central device fails to establish connection with peripheral device
BLE_CONNECTED | This notification is triggered when central device successfully establishes connection with peripheral device
BLE_ERROR | This notification is triggered when any unexpected error occurs
BLE_DISCONNECTED | This notification is triggered when connection between central and peripheral devices is closed
BLE_DATA_RECEIVED | This notification is triggered when data is received from peripheral device

**Debug Mode**

This library allows the option to enable all logs for debugging purposes. During implementation, debug mode can be either enabled or disabled.


### Functions:


### Implementation Example:
