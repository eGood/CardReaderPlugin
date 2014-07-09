#import <Cordova/CDV.h>

@interface MagTekUDynamoPlugin : CDVPlugin

- (void)isDeviceConnected: (CDVInvokedUrlCommand*) command;
- (void)isDeviceConnectedOpened: (CDVInvokedUrlCommand*) command;
- (void)openDevice: (CDVInvokedUrlCommand*) command;
- (void)closeDevice: (CDVInvokedUrlCommand*) command;

- (void)registerTrackDataAvailableListener: (CDVInvokedUrlCommand*) command;
- (void)listenForEvents: (CDVInvokedUrlCommand*) command;

@end