#import "MagTekUDynamoPlugin.h"
#import "MTSCRA.h"
#import <Cordova/CDV.h>

@interface MagTekUDynamoPlugin ()

@property (strong, nonatomic) MTSCRA* mMagTek;
@property bool mDeviceConnected;
@property bool mDeviceOpened;

@end

@implementation MagTekUDynamoPlugin

- (void)pluginInitialize
{
	self.mMagTek = [[MTSCRA alloc] init];
	NSLog(@"MagTek Plugin initialized");
}

- (void)isDeviceConnected:(CDVInvokedUrlCommand*)command
{
	CDVPluginResult* pluginResult = nil;

	//Make MagTek call to check if device is connected
	if(self.mMagTek != nil) {
		self.mDeviceConnected = [self.mMagTek isDeviceConnected];
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:self.mDeviceConnected];
	}
	else {
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"MagTek Plugin was not properly initialized."];
	}

	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end