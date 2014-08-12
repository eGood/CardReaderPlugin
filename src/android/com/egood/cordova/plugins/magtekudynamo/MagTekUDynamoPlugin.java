package com.egood.cordova.plugins.magtekudynamo;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.MalformedURLException;
import java.util.*;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;

import com.magtek.mobile.android.scra.MTSCRAException;
import com.magtek.mobile.android.scra.MagTekSCRA;
import com.magtek.mobile.android.scra.ProcessMessageResponse;
import com.magtek.mobile.android.scra.SCRAConfiguration;
import com.magtek.mobile.android.scra.ConfigParam;
import com.magtek.mobile.android.scra.SCRAConfigurationDeviceInfo;
import com.magtek.mobile.android.scra.SCRAConfigurationReaderType;
import com.magtek.mobile.android.scra.StatusCode;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.graphics.Color;
import android.media.AudioManager;
import android.os.Handler;
import android.os.Message;
import android.os.Handler.Callback;

import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.ImageButton;
import android.widget.RelativeLayout;

import android.util.Log;
import android.view.inputmethod.*;
import android.view.*;

public class MagTekUDynamoPlugin extends CordovaPlugin {
	// Message types sent from the BluetoothChatService Handler
	public static final int MESSAGE_STATE_CHANGE = 1;
	public static final int MESSAGE_READ = 2;
	public static final int MESSAGE_WRITE = 3;
	public static final int MESSAGE_DEVICE_NAME = 4;
	public static final int MESSAGE_TOAST = 5;
	public static final int STATUS_IDLE = 1;
	public static final int STATUS_PROCESSCARD = 2;
//	private static final int MESSAGE_UPDATE_GUI = 6;
	public static final String CONFIGWS_URL = "https://deviceconfig.magensa.net/service.asmx";//Production URL

	private static final int CONFIGWS_READERTYPE = 0;
	private static final String CONFIGWS_USERNAME = "magtek";
	private static final String CONFIGWS_PASSWORD = "p@ssword";

	private AudioManager mAudioMgr;	

	//May not need
	public static final String CONFIG_FILE = "MTSCRADevConfig.cfg";
//	public static final String TOAST = "toast";


	public static final String DEVICE_NAME = "device_name";
	public static final String PARTIAL_AUTH_INDICATOR = "1";
	// Intent request codes
	private static final int REQUEST_CONNECT_DEVICE = 1;
	
	private MagTekSCRA mMTSCRA;
	//private int miDeviceType=MagTekSCRA.DEVICE_TYPE_NONE;
	private Handler mSCRADataHandler = new Handler(new SCRAHandlerCallback());
	final headSetBroadCastReceiver mHeadsetReceiver = new headSetBroadCastReceiver();
	final NoisyAudioStreamReceiver mNoisyAudioStreamReceiver = new NoisyAudioStreamReceiver();

	String mStringLocalConfig;

	private int mIntCurrentDeviceStatus;

	private boolean mbAudioConnected;

	private long mLongTimerInterval;

	private int mIntCurrentStatus;

	private int mIntCurrentVolume;
	
	private String mStringAudioConfigResult;
	private CallbackContext mEventListenerCb;


	private void InitializeDevice() {
		if(mMTSCRA == null) {
			mMTSCRA = new MagTekSCRA(mSCRADataHandler);
		}
		if(mAudioMgr == null) {
			mAudioMgr = (AudioManager) cordova.getActivity().getSystemService(Context.AUDIO_SERVICE);
		}

		InitializeData();

		mIntCurrentVolume = mAudioMgr.getStreamVolume(AudioManager.STREAM_MUSIC);
	}

	private void InitializeData() {
		mMTSCRA.clearBuffers();
		mLongTimerInterval = 0;

		mbAudioConnected = false;
		mIntCurrentVolume = 0;
		mIntCurrentStatus = STATUS_IDLE;
		mIntCurrentDeviceStatus = MagTekSCRA.DEVICE_STATE_DISCONNECTED;

		mStringAudioConfigResult = "";
	}

	String setupAudioParameters() throws MTSCRAException {
		mStringLocalConfig = "";

		String strResult = "OK";

		try {
			String strXMLConfig = "";

			//strXMLConfig = getConfigurationLocal

			if(strXMLConfig.length() <= 0) {
				//Get config from web, if possible
				//Otherwise, try to configure manually
				setAudioConfigManual();
			}
			else {
				mMTSCRA.setConfigurationXML(strXMLConfig);
				mStringLocalConfig = strXMLConfig;
				return strResult;
			}
		} catch(MTSCRAException ex) {
			throw ex;
		}

		return strResult;
	}

	void setAudioConfigManual() throws MTSCRAException {
		String model = android.os.Build.MODEL.toUpperCase();

		try {
			if(model.contains("DROID RAZR") || model.toUpperCase().contains("XT910")) {
				mMTSCRA.setConfigurationParams("INPUT_SAMPLE_RATE_IN_HZ=480000,");
			}
			else if(model.equals("DROID PRO") || model.equals("MB508") || model.equals("DROIDX") || model.equals("DROID2") || model.equals("MB525")) {
				mMTSCRA.setConfigurationParams("INPUT_SAMPLE_RATE_IN_HZ=32000,");
			}
			else if(model.equals("GT-I9300")||//S3 GSM Unlocked
	        		 model.equals("SPH-L710")||//S3 Sprint
	        		 model.equals("SGH-T999")||//S3 T-Mobile
	        		 model.equals("SCH-I535")||//S3 Verizon
	        		 model.equals("SCH-R530")||//S3 US Cellular
	        		 model.equals("SAMSUNG-SGH-I747")||// S3 AT&T
	        		 model.equals("M532")||//Fujitsu
	        		 model.equals("GT-N7100")||//Notes 2 
	        		 model.equals("GT-N7105")||//Notes 2 
	        		 model.equals("SAMSUNG-SGH-I317")||// Notes 2
	        		 model.equals("SCH-I605")||// Notes 2
	        		 model.equals("SCH-R950")||// Notes 2
	        		 model.equals("SGH-T889")||// Notes 2
	        		 model.equals("SPH-L900")||// Notes 2
	        		 model.equals("SAMSUNG-SGH-I337")||// S4
	        		 model.equals("SAMSUNG-SM-G900A")||// S5
	        		 model.equals("GT-P3113"))//Galaxy Tab 2, 7.0
    		{
    			mMTSCRA.setConfigurationParams("INPUT_AUDIO_SOURCE=VRECOG,");
			}
			else if(model.equals("XT907")) {
				mMTSCRA.setConfigurationParams("INPUT_WAVE_FORM=0,");
			}
			else {
				//Using Default Settings for device
			}
		} catch(MTSCRAException ex) {
			throw new MTSCRAException(ex.getMessage());
		}
	}

	String getConfigurationLocal()
	{
		String strXMLConfig="";
		try		{
			strXMLConfig = ReadSettings(cordova.getActivity().getApplicationContext(),CONFIG_FILE);
			if(strXMLConfig==null)strXMLConfig="";
		}
		catch (Exception ex)
		{
		}
		
		return strXMLConfig;
	
	}

	void setConfigurationLocal(String lpstrConfig)
	{
		try
		{
			WriteSettings(cordova.getActivity().getApplicationContext(),lpstrConfig,CONFIG_FILE);
		}
		catch (Exception ex)
		{
			
		}
		
	}

	public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
		PluginResult pr = new PluginResult(PluginResult.Status.ERROR, "Unhandled execute call: " + action);

		if(action.equals("openDevice")) {
			if(mMTSCRA == null) {
				InitializeDevice();
			}			

			if(mMTSCRA.getDeviceType() == MagTekSCRA.DEVICE_TYPE_AUDIO) {
				//Thread tSetupAudioParams = new Thread() {
				//	public void run() {
				try {
					mStringAudioConfigResult = setupAudioParameters();
				} catch(Exception ex) {
					mStringAudioConfigResult = "Error:" + ex.getMessage();
				}
				//	}
				//}

				//tSetupAudioParams.start();
			}
			else {
			}
			mMTSCRA.openDevice();

			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.isDeviceConnected());
		}
		else if(action.equals("closeDevice")) {
			mMTSCRA.closeDevice();

			pr = new PluginResult(PluginResult.Status.OK, !mMTSCRA.isDeviceConnected());
		}
		else if(action.equals("isDeviceConnected")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.isDeviceConnected());
		}
		else if(action.equals("isDeviceOpened")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.isDeviceConnected());
		}
		else if(action.equals("clearCardData")) {
			pr = new PluginResult(PluginResult.Status.OK);
		}
/*		else if(action.equals("setCardData")) {
			try {
				;
			}
		}
		else if(action.equals("getTrackDecodeStatus")) {
			try {
				;
			}
		}
*/		
		else if(action.equals("getTrack1")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getTrack1());
		}
		else if(action.equals("getTrack2")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getTrack2());
		}
		else if(action.equals("getTrack3")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getTrack3());
		}
		else if(action.equals("getTrack1Masked")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getTrack1Masked());
		}
		else if(action.equals("getTrack2Masked")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getTrack2Masked());
		}
		else if(action.equals("getTrack3Masked")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getTrack3Masked());
		}
		else if(action.equals("getMagnePrintStatus")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getMagnePrintStatus());
		}
		else if(action.equals("getMagnePrint")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getMagnePrint());
		}
		else if(action.equals("getDeviceSerial")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getDeviceSerial());
		}
		else if(action.equals("getSessionID")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getSessionID());
		}
/*		else if(action.equals("setDeviceProtocolString")) {
			try {
				;
			}
		}
*/		
		else if(action.equals("listenForEvents")) {
			pr = new PluginResult(PluginResult.Status.NO_RESULT);
			pr.setKeepCallback(true);
			
			mEventListenerCb = callbackContext;
		}
		else if(action.equals("getCardName")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getCardName());
		}
		else if(action.equals("getCardIIN")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getCardIIN());
		}
		else if(action.equals("getCardLast4")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getCardLast4());
		}
		else if(action.equals("getCardExpDate")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getCardExpDate());
		}
		else if(action.equals("getCardServiceCode")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getCardServiceCode());
		}
		else if(action.equals("getCardStatus")) {
			pr = new PluginResult(PluginResult.Status.OK, mMTSCRA.getCardStatus());
		}
/*
		else if(action.equals("setDeviceType")) {
			try {
				;
			}
		}
*/
		else if(action.equals("setDeviceType")) {
			;
		}

		callbackContext.sendPluginResult(pr);

		return true;
	}

	private void maxVolume() {
		mAudioMgr.setStreamVolume(AudioManager.STREAM_MUSIC, mAudioMgr.getStreamMaxVolume(AudioManager.STREAM_MUSIC), AudioManager.FLAG_SHOW_UI);
	}

	private void minVolume() {
		mAudioMgr.setStreamVolume(AudioManager.STREAM_MUSIC, mIntCurrentVolume, AudioManager.FLAG_SHOW_UI);
	}

	private void sendCardData() throws JSONException {
		JSONObject response = new JSONObject();

		response.put("Response.Type", mMTSCRA.getResponseType());
		response.put("Track.Status", mMTSCRA.getTrackDecodeStatus());
		response.put("Card.Status", mMTSCRA.getCardStatus());
		response.put("Encryption.Status", mMTSCRA.getEncryptionStatus());
		response.put("Battery.Level", mMTSCRA.getBatteryLevel());
//		response.put("Swipe.Count", mMTSCRA.getSwipeCount());
		response.put("Track.Masked", mMTSCRA.getMaskedTracks());
		response.put("MagnePrint.Status", mMTSCRA.getMagnePrintStatus());
		response.put("SessionID", mMTSCRA.getSessionID());
		response.put("Card.SvcCode", mMTSCRA.getCardServiceCode());
		response.put("Card.PANLength", mMTSCRA.getCardPANLength());
		response.put("KSN", mMTSCRA.getKSN());
		response.put("Device.SerialNumber", mMTSCRA.getDeviceSerial());
		response.put("TLV.CARDIIN", mMTSCRA.getTagValue("TLV_CARDIIN", ""));
		response.put("MagTekSN", mMTSCRA.getMagTekDeviceSerial());
		response.put("FirmPartNumber", mMTSCRA.getFirmware());
		response.put("TLV.Version", mMTSCRA.getTLVVersion());
		response.put("DevModelName", mMTSCRA.getDeviceName());
		response.put("MSR.Capability", mMTSCRA.getCapMSR());
		response.put("Tracks.Capability", mMTSCRA.getCapTracks());
		response.put("Encryption.Capability", mMTSCRA.getCapMagStripeEncryption());
		response.put("Card.IIN", mMTSCRA.getCardIIN());
		response.put("Card.Name", mMTSCRA.getCardName());
		response.put("Card.Last4", mMTSCRA.getCardLast4());
		response.put("Card.ExpDate", mMTSCRA.getCardExpDate());
		response.put("Track1.Masked", mMTSCRA.getTrack1Masked());
		response.put("Track2.Masked", mMTSCRA.getTrack2Masked());
		response.put("Track3.Masked", mMTSCRA.getTrack3Masked());
		response.put("Track1", mMTSCRA.getTrack1());
		response.put("Track2", mMTSCRA.getTrack2());
		response.put("Track3", mMTSCRA.getTrack3());
		response.put("MagnePrint", mMTSCRA.getMagnePrint());
		response.put("RawResponse", mMTSCRA.getResponseData());

		mEventListenerCb.success(response);
	}

	private void sendCardError() {
		mEventListenerCb.error("That card was not swiped properly. Please try again.");
	}

	private class SCRAHandlerCallback implements Callback {
		public boolean handleMessage(Message msg) {
			try {
				switch(msg.what) {
					case MagTekSCRA.DEVICE_MESSAGE_STATE_CHANGE:
						switch(msg.arg1) {
							case MagTekSCRA.DEVICE_STATE_CONNECTED:
								mIntCurrentStatus = STATUS_IDLE;
								mIntCurrentDeviceStatus = MagTekSCRA.DEVICE_STATE_CONNECTED;
								maxVolume();
								break;
							
							case MagTekSCRA.DEVICE_STATE_CONNECTING:
								mIntCurrentDeviceStatus = MagTekSCRA.DEVICE_STATE_CONNECTING;
								break;
							
							case MagTekSCRA.DEVICE_STATE_DISCONNECTED:
								mIntCurrentDeviceStatus = MagTekSCRA.DEVICE_STATE_DISCONNECTED;
								minVolume();
								break;
						}
						break;
					
					case MagTekSCRA.DEVICE_MESSAGE_DATA_START:
						if(msg.obj != null) {
							//Unhandled event
							return true;
						}
						break;
					
					case MagTekSCRA.DEVICE_MESSAGE_DATA_CHANGE:
						if(msg.obj != null) {
							sendCardData();

							msg.obj = null;

							if(mStringLocalConfig.length() > 0) {
								setConfigurationLocal(mStringLocalConfig);
								mStringLocalConfig = "";
							}

							return true;
						}
						break;

					case MagTekSCRA.DEVICE_MESSAGE_DATA_ERROR:
						sendCardError();
						break;

					default:
						if(msg.obj != null) {
							return true;
						}
						break;
				};
			} catch(Exception ex) {
				;
			}

			return false;
		}
	}

	public class NoisyAudioStreamReceiver extends BroadcastReceiver
    {
    	@Override
    	public void onReceive(Context context, Intent intent)
    	{
    		/* If the device is unplugged, this will immediately detect that action,
    		 * and close the device.
    		 */
    		if(AudioManager.ACTION_AUDIO_BECOMING_NOISY.equals(intent.getAction()))
    		{
            	mbAudioConnected=false;
            	if(mMTSCRA.getDeviceType()==MagTekSCRA.DEVICE_TYPE_AUDIO)
            	{
            		if(mMTSCRA.isDeviceConnected())
            		{
            			mMTSCRA.closeDevice();
            		}
            	}
    		}
    	}
    }
	
	public class headSetBroadCastReceiver extends BroadcastReceiver
    {

        @Override
        public void onReceive(Context context, Intent intent) {

            // TODO Auto-generated method stub

        	try
        	{
                String action = intent.getAction();
                //Log.i("Broadcast Receiver", action);
                if( (action.compareTo(Intent.ACTION_HEADSET_PLUG))  == 0)   //if the action match a headset one
                {
                    int headSetState = intent.getIntExtra("state", 0);      //get the headset state property
                    int hasMicrophone = intent.getIntExtra("microphone", 0);//get the headset microphone property
  				    //mCardDataEditText.setText("Headset.Detected=" + headSetState + ",Microphone.Detected=" + hasMicrophone);

                    if( (headSetState == 1) && (hasMicrophone == 1))        //headset was unplugged & has no microphone
                    {
                    	mbAudioConnected=true;
                    }
                    else 
                    {
                    	mbAudioConnected=false;
                    	if(mMTSCRA.getDeviceType()==MagTekSCRA.DEVICE_TYPE_AUDIO)
                    	{
                    		if(mMTSCRA.isDeviceConnected())
                    		{
                    			mMTSCRA.closeDevice();
                    		}
                    	}
                	
                    }

                }           
        		
        	}
        	catch(Exception ex)
        	{
        		
        	}

        }

    }

    public static String ReadSettings(Context context, String file) throws IOException {
		FileInputStream fis = null;
		InputStreamReader isr = null;
		String data = null;
		fis = context.openFileInput(file);
		isr = new InputStreamReader(fis);
		char[] inputBuffer = new char[fis.available()];
		isr.read(inputBuffer);
		data = new String(inputBuffer);
		isr.close();
		fis.close();
		return data;
	}
	
	public static void WriteSettings(Context context, String data, String file) throws IOException {
		FileOutputStream fos= null;
		OutputStreamWriter osw = null;
		fos= context.openFileOutput(file,Context.MODE_PRIVATE);
		osw = new OutputStreamWriter(fos);
		osw.write(data);
		osw.close();
		fos.close();
	}
	
}