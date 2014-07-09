#import "MagTekUDynamoPlugin.h"
#import "MTSCRA.h"
#import <Cordova/CDV.h>

@interface MagTekUDynamoPlugin ()

@property (strong, nonatomic) MTSCRA* mMagTek;
@property bool mDeviceConnected;
@property bool mDeviceOpened;
@property NSString* mTrackDataListenerCallbackId;

@end

@implementation MagTekUDynamoPlugin

- (void)pluginInitialize
{
	self.mMagTek = [[MTSCRA alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(trackDataReady:)
                                                 name:@"trackDataReadyNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devConnStatusChange)
                                                 name:@"devConnectionNotification"
                                               object:nil];
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

- (void)isDeviceOpened:(CDVInvokedUrlCommand*)command
{
	CDVPluginResult* pluginResult = nil;

	//Make MagTek call to check if device is opened
	if(self.mMagTek != nil) {
		self.mDeviceOpened = [self.mMagTek isDeviceOpened];
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:self.mDeviceOpened];
	}
	else {
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"MagTek Plugin was not properly initialized."];
	}

	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openDevice:(CDVInvokedUrlCommand*)command
{
	CDVPluginResult* pluginResult = nil;

	//Open MagTek device to start reading card data
	if(self.mMagTek != nil) {
		[self.mMagTek setDeviceType:(MAGTEKIDYNAMO)];
		[self.mMagTek setDeviceProtocolString:("com.magtek.idynamo")];
		[self.mMagTek setDeviceType:(MAGTEKIDYNAMO)];

		self.mDeviceOpened = [self.mMagTek openDevice];

		if(self.mDeviceOpened) {
			self.mDeviceConnected = true;
		}

		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:self.mDeviceOpened];
	}
	else {
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"MagTek Plugin was not properly initialized."];
	}

	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)closeDevice:(CDVInvokedUrlCommand*)command
{
	CDVPluginResult* pluginResult = nil;

	//Close MagTek device to stop listening to card data and wasting energy
	if(self.mMagTek != nil) {
		self.mDeviceOpened = ![self.mMagTek closeDevice];
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:!self.mDeviceOpened];
	}
	else {
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"MagTek Plugin was not properly initialized."];
	}

	[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)registerTrackDataAvailableListener:(CDVInvokedUrlCommand*)command
{
	CDVPluginResult* pluginResult = nil;

	//Register listener for new TrackData read
	if(self.mMagTek != nil) {
		self.mTrackDataListenerCallbackId = command.callbackid;
	}
	else {
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"MagTek Plugin was not properly initialized."];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}
}

- (void)listenForEvents:(CDVInvokedUrlCommand*)command
{
	CDVPluginResult* pluginResult = nil;

	//Listen for specific events only
	if(self.mMagTek != nil) {
		int i;
		NSString* event;
		UInt32* event_types = 0;

		for(i = 0; i < [command.arguments length]; i++) {
			event = [command.arguments objectAtIndex:i];

			if(event == 'TRANS_EVENT_OK') {
				event_types |= TRANS_EVENT_OK;
			}
			if(event == 'TRANS_EVENT_ERROR') {
				event_types |= TRANS_EVENT_ERROR;
			}
			if(event == 'TRANS_EVENT_START') {
				event_types |= TRANS_EVENT_START;
			}
		}

		[self.mMagTek listenForEvents:event_types];
	}
	else {
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"MagTek Plugin was not properly initialized."];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}
}

- (void)returnData
{
	NSMutableDictionary* data = [NSMutableDictionary dictionaryWithObjectsAndKeys];

    if(self.mMagTek != nil)
    {
        if([self.mMagTek getDeviceType] == MAGTEKAUDIOREADER)
        {
            NSString *pResponse = [NSString stringWithFormat:@"Response.Type: %@\n"
                                                               "Track.Status: %@\n"
                                                               "Card.Status: %@\n"
                                                               "Encryption.Status: %@\n"
                                                               "Battery.Level: %ld\n"
                                                               "Swipe.Count: %ld\n"
                                                               "Track.Masked: %@\n"
                                                               "Track1.Masked: %@\n"
                                                               "Track2.Masked: %@\n"
                                                               "Track3.Masked: %@\n"
                                                               "Track1.Encrypted: %@\n"
                                                               "Track2.Encrypted: %@\n"
                                                               "Track3.Encrypted: %@\n"
                                                               "MagnePrint.Encrypted: %@\n"
                                                               "MagnePrint.Status: %@\n"
                                                               "SessionID: %@\n"
                                                               "Card.IIN: %@\n"
                                                               "Card.Name: %@\n"
                                                               "Card.Last4: %@\n"
                                                               "Card.ExpDate: %@\n"
                                                               "Card.SvcCode: %@\n"
                                                               "Card.PANLength: %d\n"
                                                               "KSN: %@\n"
                                                               "Device.SerialNumber: %@\n"
                                                               "TLV.CARDIIN: %@\n"
                                                               "MagTek SN: %@\n"
                                                               "Firmware Part Number: %@\n"
                                                               "TLV Version: %@\n"
                                                               "Device Model Name: %@\n"
                                                               "Capability MSR: %@\n"
                                                               "Capability Tracks: %@\n"
                                                               "Capability Encryption: %@\n",
                                                               [self.mtSCRALib getResponseType],
                                                               [self.mtSCRALib getTrackDecodeStatus],
                                                               [self.mtSCRALib getCardStatus],
                                                               [self.mtSCRALib getEncryptionStatus],
                                                               [self.mtSCRALib getBatteryLevel],
                                                               [self.mtSCRALib getSwipeCount],
                                                               [self.mtSCRALib getMaskedTracks],
                                                               [self.mtSCRALib getTrack1Masked],
                                                               [self.mtSCRALib getTrack2Masked],
                                                               [self.mtSCRALib getTrack3Masked],
                                                               [self.mtSCRALib getTrack1],
                                                               [self.mtSCRALib getTrack2],
                                                               [self.mtSCRALib getTrack3],
                                                               [self.mtSCRALib getMagnePrint],
                                                               [self.mtSCRALib getMagnePrintStatus],
                                                               [self.mtSCRALib getSessionID],
                                                               [self.mtSCRALib getCardIIN],
                                                               [self.mtSCRALib getCardName],
                                                               [self.mtSCRALib getCardLast4],
                                                               [self.mtSCRALib getCardExpDate],
                                                               [self.mtSCRALib getCardServiceCode],
                                                               [self.mtSCRALib getCardPANLength],
                                                               [self.mtSCRALib getKSN],
                                                               [self.mtSCRALib getDeviceSerial],
                                                               [self.mtSCRALib getTagValue:TLV_CARDIIN],
                                                               [self.mtSCRALib getMagTekDeviceSerial],
                                                               [self.mtSCRALib getFirmware],
                                                               [self.mtSCRALib getTLVVersion],
                                                               [self.mtSCRALib getDeviceName],
                                                               [self.mtSCRALib getCapMSR],
                                                               [self.mtSCRALib getCapTracks],
                                                               [self.mtSCRALib getCapMagStripeEncryption]];
            
            [self.responseData    setText:pResponse];
            [self.rawResponseData setText:[self.mtSCRALib getResponseData]];
        }
        else
        {
        	[data setObject:[self.mMagTek getCardIIN] forKey:@"Card.IIN"];
        	[data setObject:[self.mMagTek getCardName] forKey:@"Card.Name"];
        	[data setObject:[self.mMagTek getCardLast4] forKey:@"Card.Last4"];
        	[data setObject:[self.mMagTek getCardExpDate] forKey:@"Card.ExpDate"];
        	[data setObject:[self.mMagTek getCardServiceCode] forKey:@"Card.ServiceCode"];
        	[data setObject:[self.mMagTek getTrack1Masked] forKey:@"Track1.Masked"];
        	[data setObject:[self.mMagTek getTrack2Masked] forKey:@"Track2.Masked"];
        	[data setObject:[self.mMagTek getTrack3Masked] forKey:@"Track3.Masked"];
        	[data setObject:[self.mMagTek getMagnePrint] forKey:@"MagnePrint"];
        	[data setObject:[self.mMagTek getResponseData] forKey:@"RawResponse"];
/*
            NSString * pResponse = [NSString stringWithFormat:@"Track.Status: %@\n"
                                                                "Encryption.Status: %@\n"
                                                                "Track.Masked: %@\n"
                                                                "Track1.Masked: %@\n"
                                                                "Track2.Masked: %@\n"
                                                                "Track3.Masked: %@\n"
                                                                "Track1.Encrypted: %@\n"
                                                                "Track2.Encrypted: %@\n"
                                                                "Track3.Encrypted: %@\n"
                                                                "Card.IIN: %@\n"
                                                                "Card.Name: %@\n"
                                                                "Card.Last4: %@\n"
                                                                "Card.ExpDate: %@\n"
                                                                "Card.SvcCode: %@\n"
                                                                "Card.PANLength: %d\n"
                                                                "KSN: %@\n"
                                                                "Device.SerialNumber: %@\n"
                                                                "MagnePrint: %@\n"
                                                                "MagnePrintStatus: %@\n"
                                                                "SessionID: %@\n"
                                                                "Device Model Name: %@\n",
                                                                [self.mtSCRALib getTrackDecodeStatus],
                                                                [self.mtSCRALib getEncryptionStatus],
                                                                [self.mtSCRALib getMaskedTracks],
                                                                [self.mtSCRALib getTrack1Masked],
                                                                [self.mtSCRALib getTrack2Masked],
                                                                [self.mtSCRALib getTrack3Masked],
                                                                [self.mtSCRALib getTrack1],
                                                                [self.mtSCRALib getTrack2],
                                                                [self.mtSCRALib getTrack3],
                                                                [self.mtSCRALib getCardIIN],
                                                                [self.mtSCRALib getCardName],
                                                                [self.mtSCRALib getCardLast4],
                                                                [self.mtSCRALib getCardExpDate],
                                                                [self.mtSCRALib getCardServiceCode],
                                                                [self.mtSCRALib getCardPANLength],
                                                                [self.mtSCRALib getKSN],
                                                                [self.mtSCRALib getDeviceSerial],
                                                                [self.mtSCRALib getMagnePrint],
                                                                [self.mtSCRALib getMagnePrintStatus],
                                                                [self.mtSCRALib getSessionID],
                                                                [self.mtSCRALib getDeviceName]];

            [self.responseData    setText:pResponse];
            [self.rawResponseData setText:[self.mtSCRALib getResponseData]];
*/            
        }
        
        [self.mMagTek clearBuffers];

        CDVPluginResult* pluginResult = nil;
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:data];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:self.mTrackDataListenerCallbackId];
    }
}

- (void)onDataEvent:(id)status
{
#ifdef _DGBPRNT
    NSLog(@"onDataEvent: %i", [status intValue]);
#endif
    
	switch ([status intValue])
    {
        case TRANS_STATUS_OK:
        {
            BOOL bTrackError = NO;
                        
            NSString *pstrTrackDecodeStatus = [self.mMagTek getTrackDecodeStatus];
            
            [self returnData];
            
            @try
            {
                if(pstrTrackDecodeStatus)
                {
                    if(pstrTrackDecodeStatus.length >= 6)
                    {
#ifdef _DGBPRNT
                        NSString *pStrTrack1Status = [pstrTrackDecodeStatus substringWithRange:NSMakeRange(0, 2)];
                        NSString *pStrTrack2Status = [pstrTrackDecodeStatus substringWithRange:NSMakeRange(2, 2)];
                        NSString *pStrTrack3Status = [pstrTrackDecodeStatus substringWithRange:NSMakeRange(4, 2)];
                        
                        if(pStrTrack1Status && pStrTrack2Status && pStrTrack3Status)
                        {
                            if([pStrTrack1Status compare:@"01"] == NSOrderedSame)
                            {
                                bTrackError=YES;
                            }
                            
                            if([pStrTrack2Status compare:@"01"] == NSOrderedSame)
                            {
                                bTrackError=YES;
                                
                            }
                            
                            if([pStrTrack3Status compare:@"01"] == NSOrderedSame)
                            {
                                bTrackError=YES;
                                
                            }
                            
                            NSLog(@"Track1.Status=%@",pStrTrack1Status);
                            NSLog(@"Track2.Status=%@",pStrTrack2Status);
                            NSLog(@"Track3.Status=%@",pStrTrack3Status);
                        }
#endif
                    }
                }
                
            }
            @catch(NSException *e)
            {
            }
            
            if(bTrackError == NO)
            {
                //[self closeDevice];
            }
            
            break;
            
        }
        case TRANS_STATUS_START:
            
            /*
             *
             *  NOTE: TRANS_STATUS_START should be used with caution. CPU intensive tasks done after this events and before
             *        TRANS_STATUS_OK may interfere with reader communication.
             *
             */            
            break;
            
        case TRANS_STATUS_ERROR:
            
            if(self.mMagTek != NULL)
            {
#ifdef _DGBPRNT
                NSLog(@"TRANS_STATUS_ERROR");
#endif
                //[self updateConnStatus];
            }
            
            break;
            
        default:
            
            break;
    }
}

- (void)trackDataReady:(NSNotification *)notification
{
    NSNumber *status = [[notification userInfo] valueForKey:@"status"];
    
    [self performSelectorOnMainThread:@selector(onDataEvent:)
                           withObject:status
                        waitUntilDone:NO];
}

@end