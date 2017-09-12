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

**Initialize**

```swift
public func Initialize (debugMode: Bool, characteristicUUID: String);
```

**Connect To Peripheral Device**

```swift
public func ConnectToPeripheralDevice (deviceName: Bool);
```

**Transmit Data**

```swift
public func TransmitData (byteArray: [Uint8]);
```

**Get Device Names**

```swift
public func GetDeviceNames ()-> [String];
```

**DISCONNECT**

```swift
public func DisconnectFromPeripheralDevice ()-> [String];
```


### Implementation Example:

```swift
NotificationCenter.default.addObserver(self, selector: #selector(BLECentralViewController.connectionFailed), name: NSNotification.Name(rawValue:BLE_FAILED_TO_CONNECT_NOTIFICATION), object: nil)
NotificationCenter.default.addObserver(self, selector: #selector(BLECentralViewController.connectionSuccessfull), name: NSNotification.Name(rawValue:BLE_CONNECTED_NOTIFICATION), object: nil) 
NotificationCenter.default.addObserver(self, selector: #selector(BLECentralViewController.readData(notification:)), name: NSNotification.Name(rawValue:BLE_RECIEVED_RESPONSE_NOTIFICATION), object: nil)
NotificationCenter.default.addObserver(self, selector: #selector(BLECentralViewController.disconnectedFromDevice), name: NSNotification.Name(rawValue:BLE_DISCONNECT_NOTIFICATION), object: nil)

/*****************************************************************************
* Function :   initialize
* Input    :   none
* Output   :   none
* Comment  :   Initializes the central device station and prepares for
*              connection
****************************************************************************/

func initialize(){
  CENTRAL_DEVICE.Initialize(debugMode: debugMode, characteristicUUID: "49535343-1E4D-4BD9-BA61-23C647249616")        
}
    
/*****************************************************************************
* Function :   connectToPeripheralDevice
* Input    :   none
* Output   :   none
* Comment  :   Try to establish connection with peripheral device that was
*              selected by the user
****************************************************************************/

func connectToPeripheralDevice(){
        
  let deviceName = UserDefaults.standard.value(forKey: "PeripheralDeviceName") as? String
      
  if deviceName != nil{
     CENTRAL_DEVICE.ConnectToPeripheralDevice(deviceName: deviceName!)
  }
}
    
/*****************************************************************************
* Function :   disconnectedFromDevice
* Input    :   none
* Output   :   none
* Comment  :
****************************************************************************/

func disconnectedFromDevice(){
  state = .CONNECTION_FAILED
}
    
/*****************************************************************************
* Function :   connectionFailed
* Input    :   none
* Output   :   none
* Comment  :
****************************************************************************/
    
func connectionFailed(){
  state = .CONNECTION_FAILED
}
    
/*****************************************************************************
* Function :   connectionSuccessfull
* Input    :   none
* Output   :   none
* Comment  :
****************************************************************************/
    
func connectionSuccessfull(){   
  state = .CONNECTED       
}
    
/*****************************************************************************
* Function :   readData
* Input    :   none
* Output   :   none
* Comment  :   Reads Incomming Data From BTRelay HUB
****************************************************************************/
func readData(notification:Notification){
        
  let data = notification.userInfo?["byteArray"] as? [UInt8]
  print("Incomming Data: \(data)")

}
```
