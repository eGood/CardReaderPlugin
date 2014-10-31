#import "MagTekUDynamoPlugin.h"

#import "MTSCRA.h"

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
    /*
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(devConnStatusChange)
     name:@"devConnectionNotification"
     object:nil];
     */
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
        if(![self mDeviceOpened]) {
            [self.mMagTek setDeviceType:(MAGTEKIDYNAMO)];
            [self.mMagTek setDeviceProtocolString:(@"com.magtek.idynamo")];
            
            self.mDeviceOpened = [self.mMagTek openDevice];
            if([self.mMagTek isDeviceConnected]) {
                self.mDeviceConnected = true;
                
                if([self.mMagTek isDeviceOpened]) {
                    self.mDeviceOpened = true;
                }
                else {
                    self.mDeviceOpened = false;
                }
                
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:self.mDeviceOpened];
            }
            else {
                //Lets try an uDynamo Reader
                [self.mMagTek setDeviceType:(MAGTEKAUDIOREADER)];
                [self.mMagTek setDeviceProtocolString:(@"com.magtek.udynamo")];
                
                self.mDeviceOpened = [self.mMagTek openDevice];
                
                if([self.mMagTek isDeviceConnected]) {
                    self.mDeviceConnected = true;
                    
                    if([self.mMagTek isDeviceOpened]) {
                        self.mDeviceOpened = true;
                    }
                    else {
                        self.mDeviceOpened = false;
                    }
                    
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:self.mDeviceOpened];
                }
                else {
                    self.mDeviceOpened = false;
                    self.mDeviceConnected = false;
                    
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No reader attached."];
                }
            }
        }
        else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Reader already open."];
        }
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

- (void)listenForEvents:(CDVInvokedUrlCommand*)command
{
	CDVPluginResult* pluginResult = nil;
    
	//Listen for specific events only
	if(self.mMagTek != nil) {
		int i;
		NSString* event;
		UInt32 event_types = 0;
        
		for(i = 0; i < [command.arguments count]; i++) {
			event = [command.arguments objectAtIndex:i];
            
			if([event  isEqual: @"TRANS_EVENT_OK"]) {
				event_types |= TRANS_EVENT_OK;
			}
			if([event  isEqual: @"TRANS_EVENT_ERROR"]) {
				event_types |= TRANS_EVENT_ERROR;
			}
			if([event  isEqual: @"TRANS_EVENT_START"]) {
				event_types |= TRANS_EVENT_START;
			}
		}
        
		[self.mMagTek listenForEvents:event_types];
        
        self.mTrackDataListenerCallbackId = command.callbackId;
	}
	else {
		pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"MagTek Plugin was not properly initialized."];
		[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
	}
}

- (void)returnData
{
	NSMutableDictionary* data = [NSMutableDictionary dictionaryWithObjectsAndKeys: nil];
    
    if(self.mMagTek != nil)
    {
        if([self.mMagTek getDeviceType] == MAGTEKAUDIOREADER)
        {
            [data setObject:[self.mMagTek getResponseType] forKey:@"Response.Type"];
            [data setObject:[self.mMagTek getTrackDecodeStatus] forKey:@"Track.Status"];
            [data setObject:[self.mMagTek getCardStatus] forKey:@"Card.Status"];
            [data setObject:[self.mMagTek getEncryptionStatus] forKey:@"Encryption.Status"];
            [data setObject:[NSString stringWithFormat:@"%ld", [self.mMagTek getBatteryLevel] ] forKey:@"Battery.Level"];
            [data setObject:[NSString stringWithFormat:@"%ld", [self.mMagTek getSwipeCount]] forKey:@"Swipe.Count"];
            [data setObject:[self.mMagTek getMaskedTracks] forKey:@"Track.Masked"];
            [data setObject:[self.mMagTek getMagnePrintStatus] forKey:@"MagnePrint.Status"];
            [data setObject:[self.mMagTek getSessionID] forKey:@"SessionID"];
            [data setObject:[self.mMagTek getCardServiceCode] forKey:@"Card.SvcCode"];
            [data setObject:[NSString stringWithFormat:@"%d", [self.mMagTek getCardPANLength]] forKey:@"Card.PANLength"];
            [data setObject:[self.mMagTek getKSN] forKey:@"KSN"];
            [data setObject:[self.mMagTek getDeviceSerial] forKey:@"Device.SerialNumber"];
            [data setObject:[self.mMagTek getTagValue:TLV_CARDIIN] forKey:@"TLV.CARDIIN"];
            [data setObject:[self.mMagTek getMagTekDeviceSerial] forKey:@"MagTekSN"];
            [data setObject:[self.mMagTek getFirmware] forKey:@"FirmPartNumber"];
            [data setObject:[self.mMagTek getTLVVersion] forKey:@"TLV.Version"];
            [data setObject:[self.mMagTek getDeviceName] forKey:@"DevModelName"];
            [data setObject:[self.mMagTek getCapMSR] forKey:@"MSR.Capability"];
            [data setObject:[self.mMagTek getCapTracks] forKey:@"Tracks.Capability"];
            [data setObject:[self.mMagTek getCapMagStripeEncryption] forKey:@"Encryption.Capability"];

            [data setObject:[self.mMagTek getCardIIN] forKey:@"Card.IIN"];
        	[data setObject:[self.mMagTek getCardName] forKey:@"Card.Name"];
        	[data setObject:[self.mMagTek getCardLast4] forKey:@"Card.Last4"];
        	[data setObject:[self.mMagTek getCardExpDate] forKey:@"Card.ExpDate"];
        	[data setObject:[self.mMagTek getCardServiceCode] forKey:@"Card.ServiceCode"];
        	[data setObject:[self.mMagTek getTrack1Masked] forKey:@"Track1.Masked"];
        	[data setObject:[self.mMagTek getTrack2Masked] forKey:@"Track2.Masked"];
        	[data setObject:[self.mMagTek getTrack3Masked] forKey:@"Track3.Masked"];
        	[data setObject:[self.mMagTek getTrack1] forKey:@"Track1"];
        	[data setObject:[self.mMagTek getTrack2] forKey:@"Track2"];
        	[data setObject:[self.mMagTek getTrack3] forKey:@"Track3"];
        	[data setObject:[self.mMagTek getMagnePrint] forKey:@"MagnePrint"];
        	[data setObject:[self.mMagTek getResponseData] forKey:@"RawResponse"];
            
            /*
             NSString *pResponse = [NSString stringWithFormat:@"Response.Type: %@\n" - [self.mMagTek getResponseType],
             "Track.Status: %@\n" -[self.mMagTek getTrackDecodeStatus],
             "Card.Status: %@\n" -[self.mMagTek getCardStatus],
             "Encryption.Status: %@\n" -[self.mMagTek getEncryptionStatus],
             "Battery.Level: %ld\n" -[self.mMagTek getBatteryLevel],
             "Swipe.Count: %ld\n" -[self.mMagTek getSwipeCount],
             "Track.Masked: %@\n" -[self.mMagTek getMaskedTracks],
             "MagnePrint.Status: %@\n" -[self.mMagTek getMagnePrintStatus],
             "SessionID: %@\n" -[self.mMagTek getSessionID],
             "Card.SvcCode: %@\n" -[self.mMagTek getCardServiceCode],
             "Card.PANLength: %d\n" -[self.mMagTek getCardPANLength],
             "KSN: %@\n" -[self.mMagTek getKSN],
             "Device.SerialNumber: %@\n" -[self.mMagTek getDeviceSerial],
             "TLV.CARDIIN: %@\n" -[self.mMagTek getTagValue:TLV_CARDIIN],
             "MagTek SN: %@\n" -[self.mMagTek getMagTekDeviceSerial],
             "Firmware Part Number: %@\n" - [self.mMagTek getFirmware],
             "TLV Version: %@\n" -[self.mMagTek getTLVVersion],
             "Device Model Name: %@\n" -[self.mMagTek getDeviceName],
             "Capability MSR: %@\n" -[self.mMagTek getCapMSR],
             "Capability Tracks: %@\n" -[self.mMagTek getCapTracks],
             "Capability Encryption: %@\n", -[self.mMagTek getCapMagStripeEncryption]]
             
             
             "Card.IIN: %@\n" -[self.mMagTek getCardIIN],
             "Card.Name: %@\n" -[self.mMagTek getCardName],
             "Card.Last4: %@\n" -[self.mMagTek getCardLast4],
             "Card.ExpDate: %@\n" -[self.mMagTek getCardExpDate],
             "Track1.Masked: %@\n" -[self.mMagTek getTrack1Masked],
             "Track2.Masked: %@\n" -[self.mMagTek getTrack2Masked],
             "Track3.Masked: %@\n" -[self.mMagTek getTrack3Masked],
             "Track1.Encrypted: %@\n" -[self.mMagTek getTrack1],
             "Track2.Encrypted: %@\n" -[self.mMagTek getTrack2],
             "Track3.Encrypted: %@\n" -[self.mMagTek getTrack3],
             "MagnePrint.Encrypted: %@\n" -[self.mMagTek getMagnePrint],
             ;
             */
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
             [self.mMagTek getTrackDecodeStatus],
             [self.mMagTek getEncryptionStatus],
             [self.mMagTek getMaskedTracks],
             [self.mMagTek getTrack1Masked],
             [self.mMagTek getTrack2Masked],
             [self.mMagTek getTrack3Masked],
             [self.mMagTek getTrack1],
             [self.mMagTek getTrack2],
             [self.mMagTek getTrack3],
             [self.mMagTek getCardIIN],
             [self.mMagTek getCardName],
             [self.mMagTek getCardLast4],
             [self.mMagTek getCardExpDate],
             [self.mMagTek getCardServiceCode],
             [self.mMagTek getCardPANLength],
             [self.mMagTek getKSN],
             [self.mMagTek getDeviceSerial],
             [self.mMagTek getMagnePrint],
             [self.mMagTek getMagnePrintStatus],
             [self.mMagTek getSessionID],
             [self.mMagTek getDeviceName]];
             
             [self.responseData    setText:pResponse];
             [self.rawResponseData setText:[self.mMagTek getResponseData]];
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