    'use strict';
 
    var MagTek = ( typeof MagTek === 'undefined' ? {} : MagTek );
    var cordova = window.cordova || window.Cordova,
        fail = function(error) {
            console.log('Error running your request: ' + error);
        };
 
    MagTek.isDeviceConnected = function(callback, error) {
        $('.error').html('Making cordova.exec call to isDeviceConnected', []);
        var success = function(connected) {
            callback(connected);
        };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'isDeviceConnected', []);
        $('.error').html('Made cordova.exec call to isDeviceConnected');
    };

    MagTek.isDeviceOpened = function(callback, error) {
        var success = function(opened) { callback(opened); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'isDeviceOpened', []);
    };

    MagTek.openDevice = function(callback, error) {
        var success = function(status) { callback(status); }
        var fail_handler = error || fail;;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'openDevice', []);
    };
    MagTek.closeDevice = function(callback, error) {
        var success = function(status) { callback(status); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'closeDevice', []);
    };
    MagTek.clearCardData = function(callback, error) {
        var success = function(data_cleared) { callback(data_cleared); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'clearCardData', []);
    };
    MagTek.setCardData = function(callback, error) {
        var success = function(data_set) { callback(data_set); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'setCardData', []);
    };
    MagTek.getTrackDecodeStatus = function(callback, error) {
        var success = function(decode_status) { callback(decode_status); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getTrackDecodeStatus', []);
    };
    MagTek.getTrack1 = function(callback, error) {
        var success = function(track) { callback(track); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getTrack1', []);
    };
    MagTek.getTrack2 = function(callback, error) {
        var success = function(track) { callback(track); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getTrack2', []);
    };
    MagTek.getTrack3 = function(callback, error) {
        var success = function(track) { callback(track); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getTrack3', []);
    };
    MagTek.getTrack1Masked = function(callback, error) {
        var success = function(track) { callback(track); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getTrack1Masked', []);
    };
    MagTek.getTrack2Masked = function(callback, error) {
        var success = function(track) { callback(track); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getTrack2Masked', []);
    };
    MagTek.getTrack3Masked = function(callback, error) {
        var success = function(track) { callback(track); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getTrack3Masked', []);
    };
    MagTek.getMagnePrintStatus = function(callback, error) {
        var success = function(status) { callback(status); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getMagnePrintStatus', []);
    };
    MagTek.getMagnePrint = function(callback, error) {
        var success = function(magne_print) { callback(magne_print); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getMagnePrint', []);
    };
    MagTek.getDeviceSerial = function(callback, error) {
        var success = function(device_serial) { callback(device_serial); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getDeviceSerial', []);
    };
    MagTek.getSessionID = function(callback, error) {
        var success = function(session_id) { callback(session_id); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getSessionID', []);
    };


    //..... A few methods skipped


    MagTek.setDeviceProtocolString = function(callback, protocol_string) {
        var success = function(status) { callback(status); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'setDeviceProtocolString', [protocol_string]);
    };
    MagTek.listenForEvents = function(callback, events, error) {
        var success = function(status) { callback(status); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'listenForEvents', events);
    };
    MagTek.getCardName = function(callback, error) {
        var success = function(card_name) { callback(card_name); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getCardName', []);
    };
    MagTek.getCardIIN = function(callback, error) {
        var success = function(card_iin) { callback(card_iin); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getCardIIN', []);
    };
    MagTek.getCardLast4 = function(callback, error) {
        var success = function(card_last4) { callback(card_last4); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getCardLast4', []);
    };
    MagTek.getCardExpDate = function(callback, error) {
        var success = function(card_exp_date) { callback(card_exp_date); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getCardExpDate', []);
    };
    MagTek.getCardServiceCode = function(callback, error) {
        var success = function(card_svc) { callback(card_svc); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getCardServiceCode', []);
    };
    MagTek.getCardStatus = function(callback, error) {
        var success = function(card_status) { callback(card_status); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'getCardStatus', []);
    };


    //..... A few methods skipped


    MagTek.setDeviceType = function(callback, device_type) {
        var success = function(status) { callback(status); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'setDeviceType', [device_type]);
    };
    MagTek.setDeviceType = function(callback, device_type) {
        var success = function(status) { callback(status); };
        var fail_handler = error || fail;

        cordova.exec(success, fail_handler, 'com.egood.magtek-udynamo', 'setDeviceType', [device_type]);
    };
 
    module.exports = MagTek;