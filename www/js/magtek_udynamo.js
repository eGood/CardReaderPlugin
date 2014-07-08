MagTek = ( typeof MagTek === 'undefined' ? {} : MagTek );

var cordova = window.cordova || window.Cordova;

var fail = function(error) {
    console.log('Something went wrong: ' + error);
}

MagTek.prototype.isDeviceConnected = function(callback) {
    var success = function(connected) {
        callback(connected);
    };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'isDeviceConnected');
};
MagTek.prototype.isDeviceOpened = function(callback) {
    var success = function(opened) { callback(opened); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'isDeviceOpened');
};

MagTek.prototype.openDevice = function(callback) {
    var success = function(status) { callback(status); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'openDevice');
};
MagTek.prototype.closeDevice = function(callback) {
    var success = function(status) { callback(status); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'closeDevice');
};
MagTek.prototype.clearCardData = function(callback) {
    var success = function(data_cleared) { callback(data_cleared); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'clearCardData');
};
MagTek.prototype.setCardData = function(callback) {
    var success = function(data_set) { callback(data_set); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'setCardData');
};
MagTek.prototype.getTrackDecodeStatus = function(callback) {
    var success = function(decode_status) { callback(decode_status); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getTrackDecodeStatus');
};
MagTek.prototype.getTrack1 = function(callback) {
    var success = function(track) { callback(track); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getTrack1');
};
MagTek.prototype.getTrack2 = function(callback) {
    var success = function(track) { callback(track); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getTrack2');
};
MagTek.prototype.getTrack3 = function(callback) {
    var success = function(track) { callback(track); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getTrack3');
};
MagTek.prototype.getTrack1Masked = function(callback) {
    var success = function(track) { callback(track); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getTrack1Masked');
};
MagTek.prototype.getTrack2Masked = function(callback) {
    var success = function(track) { callback(track); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getTrack2Masked');
};
MagTek.prototype.getTrack3Masked = function(callback) {
    var success = function(track) { callback(track); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getTrack3Masked');
};
MagTek.prototype.getMagnePrintStatus = function(callback) {
    var success = function(status) { callback(status); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getMagnePrintStatus');
};
MagTek.prototype.getMagnePrint = function(callback) {
    var success = function(magne_print) { callback(magne_print); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getMagnePrint');
};
MagTek.prototype.getDeviceSerial = function(callback) {
    var success = function(device_serial) { callback(device_serial); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getDeviceSerial');
};
MagTek.prototype.getSessionID = function(callback) {
    var success = function(session_id) { callback(session_id); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getSessionID');
};


//..... A few methods skipped


MagTek.prototype.setDeviceProtocolString = function(callback, protocol_string) {
    var success = function(status) { callback(status); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'setDeviceProtocolString', [protocol_string]);
};
MagTek.prototype.listenFoEvents = function(callback, events) {
    var success = function(status) { callback(status); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'listenFoEvents', [events]);
};
MagTek.prototype.getCardName = function(callback) {
    var success = function(card_name) { callback(card_name); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getCardName');
};
MagTek.prototype.getCardIIN = function(callback) {
    var success = function(card_iin) { callback(card_iin); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getCardIIN');
};
MagTek.prototype.getCardLast4 = function(callback) {
    var success = function(card_last4) { callback(card_last4); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getCardLast4');
};
MagTek.prototype.getCardExpDate = function(callback) {
    var success = function(card_exp_date) { callback(card_exp_date); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getCardExpDate');
};
MagTek.prototype.getCardServiceCode = function(callback) {
    var success = function(card_svc) { callback(card_svc); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getCardServiceCode');
};
MagTek.prototype.getCardStatus = function(callback) {
    var success = function(card_status) { callback(card_status); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'getCardStatus');
};


//..... A few methods skipped


MagTek.prototype.setDeviceType = function(callback, device_type) {
    var success = function(status) { callback(status); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'setDeviceType', [device_type]);
};
MagTek.prototype.setDeviceType = function(callback, device_type) {
    var success = function(status) { callback(status); };

    cordova.exec(success, fail, 'com.egood.magtek-udynamo', 'setDeviceType', [device_type]);
};