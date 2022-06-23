/*
 * Copyright (c) 2010-2020 Belledonne Communications SARL.
 *
 * This file is part of linphone-iphone
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation
import linphonesw
import UserNotifications
import os
import CallKit
import AVFoundation

@objc class CallAppData: NSObject {
    @objc var batteryWarningShown = false
    @objc var videoRequested = false /*set when user has requested for video*/
}

/*
 * CallManager is a class that manages application calls and supports callkit.
 * There is only one CallManager by calling CallManager.instance().
 */
@objc class CallManager: NSObject {
    
    static var theCallManager: CallManager?
    let providerDelegate: ProviderDelegate! // to support callkit
    let callController: CXCallController! // to support callkit
    let manager: CoreManagerDelegate! // callbacks of the linphonecore
    var lc: Core?
    @objc var speakerBeforePause : Bool = false
    @objc var speakerEnabled : Bool = false
    @objc var bluetoothEnabled : Bool = false
    @objc var nextCallIsTransfer: Bool = false
    @objc var alreadyRegisteredForNotification: Bool = false
    var referedFromCall: String?
    var referedToCall: String?
    var endCallkit: Bool = false
    
    
    fileprivate override init() {
        providerDelegate = ProviderDelegate()
        callController = CXCallController()
        manager = CoreManagerDelegate()
    }
    
    @objc static func instance() -> CallManager {
        if (theCallManager == nil) {
            theCallManager = CallManager()
        }
        return theCallManager!
    }
    
    @objc func setCore(core: OpaquePointer) {
        lc = Core.getSwiftObject(cObject: core)
        lc?.addDelegate(delegate: manager)
    }
    
    @objc static func getAppData(call: OpaquePointer) -> CallAppData? {
        let sCall = Call.getSwiftObject(cObject: call)
        return getAppData(sCall: sCall)
    }
    
    static func getAppData(sCall:Call) -> CallAppData? {
        if (sCall.userData == nil) {
            return nil
        }
        return Unmanaged<CallAppData>.fromOpaque(sCall.userData!).takeUnretainedValue()
    }
    
    @objc static func setAppData(call:OpaquePointer, appData: CallAppData) {
        let sCall = Call.getSwiftObject(cObject: call)
        setAppData(sCall: sCall, appData: appData)
    }
    
    static func setAppData(sCall:Call, appData:CallAppData?) {
        if (sCall.userData != nil) {
            Unmanaged<CallAppData>.fromOpaque(sCall.userData!).release()
        }
        if (appData == nil) {
            sCall.userData = nil
        } else {
            sCall.userData = UnsafeMutableRawPointer(Unmanaged.passRetained(appData!).toOpaque())
        }
    }
    
    @objc func findCall(callId: String?) -> OpaquePointer? {
        let call = callByCallId(callId: callId)
        return call?.getCobject
    }
    
    func callByCallId(callId: String?) -> Call? {
        if (callId == nil) {
            return nil
        }
        let calls = lc?.calls
        if let callTmp = calls?.first(where: { $0.callLog?.callId == callId }) {
            return callTmp
        }
        return nil
    }
    
    @objc static func callKitEnabled() -> Bool {
        #if !targetEnvironment(simulator)
        if ConfigManager.instance().lpConfigBoolForKey(key: "use_callkit", section: "app") {
            return true
        }
        #endif
        return false
    }
    
    @objc func allowSpeaker() -> Bool {
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            // For now, ipad support only speaker.
            return true
        }
        
        var allow = true
        let newRoute = AVAudioSession.sharedInstance().currentRoute
        if (newRoute.outputs.count > 0) {
            let route = newRoute.outputs[0].portType
            allow = !( route == .lineOut || route == .headphones || (AudioHelper.bluetoothRoutes() as Array).contains(where: {($0 as! AVAudioSession.Port) == route}))
        }
        
        return allow
    }
    
    @objc func enableSpeaker(enable: Bool) {
        speakerEnabled = enable
        do {
            if (enable && allowSpeaker()) {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                UIDevice.current.isProximityMonitoringEnabled = false
                bluetoothEnabled = false
            } else {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                let buildinPort = AudioHelper.builtinAudioDevice()
                try AVAudioSession.sharedInstance().setPreferredInput(buildinPort)
                UIDevice.current.isProximityMonitoringEnabled = (lc!.callsNb > 0)
            }
        } catch {
            Log.directLog(BCTBX_LOG_ERROR, text: "Failed to change audio route: err \(error)")
        }
    }
    
    func requestTransaction(_ transaction: CXTransaction, action: String) {
        callController.request(transaction) { error in
            if let error = error {
                Log.directLog(BCTBX_LOG_ERROR, text: "CallKit: Requested transaction \(action) failed because: \(error)")
            } else {
                Log.directLog(BCTBX_LOG_MESSAGE, text: "CallKit: Requested transaction \(action) successfully")
            }
        }
    }
    
    
    // From ios13, display the callkit view when the notification is received.
    @objc func displayIncomingCall(callId: String) {
        
        let uuid = CallManager.instance().providerDelegate.uuids["\(callId)"]
        
        if (uuid != nil) {
            
            let callInfo = providerDelegate.callInfos[uuid!]
            if (callInfo?.declined ?? false) {
                // This call was declined.
                providerDelegate.reportIncomingCall(call:nil, uuid: uuid!, handle: "Calling", hasVideo: true, displayName: callInfo?.displayName ?? "Calling")
                providerDelegate.endCall(uuid: uuid!)
            }
            return
        }
        
        let call = CallManager.instance().callByCallId(callId: callId)
        
        if (call != nil) {
            
            let displayName = FastAddressBook.displayName(for: call?.remoteAddress?.getCobject) ?? "Unknow"
            let video = UIApplication.shared.applicationState == .active && (lc!.videoActivationPolicy?.automaticallyAccept ?? false) && (call!.remoteParams?.videoEnabled ?? false)
            // Calllkit mostra tutti i dettagli della chiamata.
            displayIncomingCall(call: call, handle: (call!.remoteAddress?.asStringUriOnly())!, hasVideo: video, callId: callId, displayName: displayName)
            
        }else {
            //let video = UIApplication.shared.applicationState == .active && (lc?.videoActivationPolicy?.automaticallyAccept ?? false) && (call?.remoteParams?.videoEnabled ?? false)
            
            // Callkit mostra solo la chiamata ricevuta.
            displayIncomingCall(call: nil, handle: "Calling", hasVideo: true, callId: callId, displayName: "Calling")
        }
    }
    
    func displayIncomingCall(call:Call?, handle: String, hasVideo: Bool, callId: String, displayName:String) {
        
        let uuid = UUID()
        let callInfo = CallInfo.newIncomingCallInfo(callId: callId)
        
        providerDelegate.callInfos.updateValue(callInfo, forKey: uuid)
        providerDelegate.uuids.updateValue(uuid, forKey: callId)
        providerDelegate.reportIncomingCall(call:call, uuid: uuid, handle: handle, hasVideo: hasVideo, displayName: displayName)
    }
    
    @objc func acceptCall(call: OpaquePointer?, hasVideo:Bool) {
        if (call == nil) {
            Log.directLog(BCTBX_LOG_ERROR, text: "Can not accept null call!")
            return
        }
        let call = Call.getSwiftObject(cObject: call!)
        acceptCall(call: call, hasVideo: hasVideo)
    }
    
    func acceptCall(call: Call, hasVideo:Bool) {
        do {
            Log.directLog(BCTBX_LOG_MESSAGE, text: hasVideo ? "WEDO: HASVIDEO: true" : "HASVIDEO: false")
            let callParams = try lc!.createCallParams(call: call)
            callParams.videoEnabled = hasVideo
            if (ConfigManager.instance().lpConfigBoolForKey(key: "edge_opt_preference")) {
                let low_bandwidth = (AppManager.network() == .network_2g)
                if (low_bandwidth) {
                    Log.directLog(BCTBX_LOG_MESSAGE, text: "Low bandwidth mode")
                }
                callParams.lowBandwidthEnabled = low_bandwidth
            }
            
            //We set the record file name here because we can't do it after the call is started.
            let address = call.callLog?.fromAddress
            let writablePath = AppManager.recordingFilePathFromCall(address: address?.username ?? "")
            Log.directLog(BCTBX_LOG_MESSAGE, text: "Record file path: \(String(describing: writablePath))")
            callParams.recordFile = writablePath
            
            try call.acceptWithParams(params: callParams)
        } catch {
            Log.directLog(BCTBX_LOG_ERROR, text: "accept call failed \(error)")
        }
    }
    
    // for outgoing call. There is not yet callId
    @objc func startCall(addr: OpaquePointer?, isSas: Bool) {
        
        if (addr == nil) {
            print("Can not start a call with null address!")
            return
        }
        
        let sAddr = Address.getSwiftObject(cObject: addr!)
        //Removed check "nextCallIsTransfer" to support correctly attended transfer
        if (CallManager.callKitEnabled()) {
            
            let uuid = UUID()
            let name = FastAddressBook.displayName(for: addr) ?? "unknow"
            let handle = CXHandle(type: .generic, value: sAddr.asStringUriOnly())
            let startCallAction = CXStartCallAction(call: uuid, handle: handle)
            let transaction = CXTransaction(action: startCallAction)
            
            let callInfo = CallInfo.newOutgoingCallInfo(addr: sAddr, isSas: isSas, displayName: name)
            providerDelegate.callInfos.updateValue(callInfo, forKey: uuid)
            providerDelegate.uuids.updateValue(uuid, forKey: "")
            
            setHeldOtherCalls(exceptCallid: "")
            requestTransaction(transaction, action: "startCall")
            
        }else {
            
            try? doCall(addr: sAddr, isSas: isSas)
        }
    }
    
    
    func doCall(addr: Address, isSas: Bool) throws {
        
        Log.directLog(BCTBX_LOG_DEBUG, text: "doCall addr: \(addr)");

        let displayName = FastAddressBook.displayName(for: addr.getCobject)
        
        let lcallParams = try CallManager.instance().lc!.createCallParams(call: nil)
        //lcallParams.videoEnabled = false//Force video to be disabled
        if ConfigManager.instance().lpConfigBoolForKey(key: "edge_opt_preference") && AppManager.network() == .network_2g {
            Log.directLog(BCTBX_LOG_MESSAGE, text: "Enabling low bandwidth mode")
            lcallParams.lowBandwidthEnabled = true
        }
        
        if (displayName != nil) {
            try addr.setDisplayname(newValue: displayName!)
        }
        
        if (ConfigManager.instance().lpConfigBoolForKey(key: "override_domain_with_default_one")) {
            try addr.setDomain(newValue: ConfigManager.instance().lpConfigStringForKey(key: "domain", section: "assistant"))
        }
        
        // TODO: Qui dovrei mettere la gestione del trasferimento o no della chiamata.
        if (CallManager.instance().nextCallIsTransfer && false) {
            
            let call = CallManager.instance().lc!.currentCall
            try call?.transfer(referTo: addr.asString())
            CallManager.instance().nextCallIsTransfer = false
            
        } else {
            //We set the record file name here because we can't do it after the call is started.
            let writablePath = AppManager.recordingFilePathFromCall(address: addr.username )
            
            Log.directLog(BCTBX_LOG_DEBUG, text: "record file path: \(writablePath)")
            Log.directLog(BCTBX_LOG_DEBUG, text: "Wedo - VideoParams: \(lcallParams.videoEnabled)")
            
            lcallParams.recordFile = writablePath
            if (isSas) {
                lcallParams.mediaEncryption = .ZRTP
            }
            let call = CallManager.instance().lc!.inviteAddressWithParams(addr: addr, params: lcallParams)
            if (call != nil) {
                // The LinphoneCallAppData object should be set on call creation with callback
                // - (void)onCall:StateChanged:withMessage:. If not, we are in big trouble and expect it to crash
                // We are NOT responsible for creating the AppData.
                let data = CallManager.getAppData(sCall: call!)
                if (data == nil) {
                    
                    Log.directLog(BCTBX_LOG_ERROR, text: "New call instanciated but app data was not set. Expect it to crash.")
                    /* will be used later to notify user if video was not activated because of the linphone core*/
                } else {
                    
                    data!.videoRequested = lcallParams.videoEnabled
                    
                    Log.directLog(BCTBX_LOG_DEBUG, text: "WEDO: doCall()->data.videoRequested \(data!.videoRequested)")
                    
                    CallManager.setAppData(sCall: call!, appData: data)
                }
                
                // If starting transfering a call, save destination call pointer.
                if TransferCallManager.instance().isCallTransfer, let _ = TransferCallManager.instance().origin {
                    TransferCallManager.instance().destination = call
                }
            }
        }
    }
    
    /**
     Transfer the current call to another, like attended transfer.
     */
    @objc func transferCall() {
        if TransferCallManager.instance().isCallTransfer,
           let origin = TransferCallManager.instance().origin,
           let destination = TransferCallManager.instance().destination {
            do{
                // Get the call pointer unwrapped from optional.
                // Execute the transfer.
                try destination.transferToAnother(dest: origin)
                // Reset state of Transfer Call Manager after doing his work.
                TransferCallManager.instance().isCallTransfer = false
                CallManager.instance().nextCallIsTransfer = false
            } catch (let errorThrown) {
                print("[WEDO] Error in transfer to another: \(errorThrown.localizedDescription)")
                return
            }
        }
    }
    
    @objc func groupCall() {
        if (CallManager.callKitEnabled()) {
            let calls = lc?.calls
            if (calls == nil || calls!.isEmpty) {
                return
            }
            let firstCall = calls!.first?.callLog?.callId ?? ""
            let lastCall = (calls!.count > 1) ? calls!.last?.callLog?.callId ?? "" : ""
            
            let currentUuid = CallManager.instance().providerDelegate.uuids["\(firstCall)"]
            if (currentUuid == nil) {
                Log.directLog(BCTBX_LOG_ERROR, text: "Can not find correspondant call to group.")
                return
            }
            
            let newUuid = CallManager.instance().providerDelegate.uuids["\(lastCall)"]
            let groupAction = CXSetGroupCallAction(call: currentUuid!, callUUIDToGroupWith: newUuid)
            let transcation = CXTransaction(action: groupAction)
            requestTransaction(transcation, action: "groupCall")
        } else {
            try? lc?.addAllToConference()
        }
    }
    
    @objc func removeAllCallInfos() {
        providerDelegate.callInfos.removeAll()
        providerDelegate.uuids.removeAll()
    }
    
    // To be removed.
    static func configAudioSession(audioSession: AVAudioSession) {
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: AVAudioSession.CategoryOptions(rawValue: AVAudioSession.CategoryOptions.allowBluetooth.rawValue | AVAudioSession.CategoryOptions.allowBluetoothA2DP.rawValue))
            try audioSession.setMode(AVAudioSession.Mode.voiceChat)
            try audioSession.setPreferredSampleRate(48000.0)
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            Log.directLog(BCTBX_LOG_WARNING, text: "CallKit: Unable to config audio session because : \(error)")
        }
    }
    
    @objc func terminateCall(call: OpaquePointer?) {
        if (call == nil) {
            Log.directLog(BCTBX_LOG_ERROR, text: "Can not terminate null call!")
            return
        }
        let call = Call.getSwiftObject(cObject: call!)
        do {
            try call.terminate()
            Log.directLog(BCTBX_LOG_DEBUG, text: "Call terminated")
        } catch {
            Log.directLog(BCTBX_LOG_ERROR, text: "Failed to terminate call failed because \(error)")
        }
        if (UIApplication.shared.applicationState == .background) {
            CoreManager.instance().stopLinphoneCore()
        }
    }
    
    @objc func markCallAsDeclined(callId: String) {
        if !CallManager.callKitEnabled() {
            return
        }
        
        let uuid = providerDelegate.uuids["\(callId)"]
        if (uuid == nil) {
            Log.directLog(BCTBX_LOG_MESSAGE, text: "Mark call \(callId) as declined.")
            let uuid = UUID()
            providerDelegate.uuids.updateValue(uuid, forKey: callId)
            let callInfo = CallInfo.newIncomingCallInfo(callId: callId)
            callInfo.declined = true
            providerDelegate.callInfos.updateValue(callInfo, forKey: uuid)
        } else {
            // end call
            providerDelegate.endCall(uuid: uuid!)
        }
    }
    
    @objc func setHeld(call: OpaquePointer, hold: Bool) {
        let sCall = Call.getSwiftObject(cObject: call)
        if (!hold) {
            setHeldOtherCalls(exceptCallid: sCall.callLog?.callId ?? "")
        }
        setHeld(call: sCall, hold: hold)
    }
    
    func setHeld(call: Call, hold: Bool) {
        let callid = call.callLog?.callId ?? ""
        let uuid = providerDelegate.uuids["\(callid)"]
        if (uuid == nil) {
            Log.directLog(BCTBX_LOG_ERROR, text: "Can not find correspondant call to set held.")
            return
        }
        let setHeldAction = CXSetHeldCallAction(call: uuid!, onHold: hold)
        let transaction = CXTransaction(action: setHeldAction)
        requestTransaction(transaction, action: "setHeld")
    }
    
    @objc func setHeldOtherCalls(exceptCallid: String) {
        for call in CallManager.instance().lc!.calls {
            if (call.callLog?.callId != exceptCallid && call.state != .Paused && call.state != .Pausing && call.state != .PausedByRemote) {
                setHeld(call: call, hold: true)
            }
        }
    }
    
    @objc func performActionWhenCoreIsOn(action:  @escaping ()->Void ) {
        if (manager.globalState == .On) {
            action()
        } else {
            manager.actionsToPerformOnceWhenCoreIsOn.append(action)
        }
    }
}



class CoreManagerDelegate: CoreDelegate {
    
    static var speaker_already_enabled : Bool = false
    var globalState : GlobalState = .Off
    var actionsToPerformOnceWhenCoreIsOn : [(()->Void)] = []
    
    override func onGlobalStateChanged(lc: Core, gstate: GlobalState, message: String) {
        if (gstate == .On) {
            actionsToPerformOnceWhenCoreIsOn.forEach {
                $0()
            }
            actionsToPerformOnceWhenCoreIsOn.removeAll()
        }
        globalState = gstate
    }
    
    override func onRegistrationStateChanged(lc: Core, cfg: ProxyConfig, cstate: RegistrationState, message: String) {
        if lc.proxyConfigList.count == 1 && (cstate == .Failed || cstate == .Cleared){
            // terminate callkit immediately when registration failed or cleared, supporting single proxy configuration
            CallManager.instance().endCallkit = true
            for call in CallManager.instance().providerDelegate.uuids {
                CallManager.instance().providerDelegate.endCall(uuid: call.value)
            }
        } else {
            CallManager.instance().endCallkit = false
        }
    }
    
    
    override func onCallStateChanged(lc: Core, call: Call, cstate: Call.State, message: String) {
        let addr = call.remoteAddress;
        let displayName = FastAddressBook.displayName(for: addr?.getCobject) ?? "Unknow"
        let callLog = call.callLog
        let uuid : UUID? = CallManager.instance().providerDelegate.uuids[CallIdTest.instance().callId!]
        
        /*  Gestione CallId assente in notifica push  */
        if(cstate == .IncomingReceived && uuid != nil && CallIdTest.instance().callId! != callLog!.callId) {
            CallManager.instance().providerDelegate.uuids.removeValue(forKey: CallIdTest.instance().callId!)
            CallManager.instance().providerDelegate.uuids.updateValue(uuid!, forKey: callLog!.callId)
            
            let ci : CallInfo = CallManager.instance().providerDelegate.callInfos[uuid!] ?? CallInfo.newIncomingCallInfo(callId: callLog!.callId)
            ci.callId = callLog!.callId
            CallManager.instance().providerDelegate.callInfos.updateValue(ci, forKey: uuid!)
        }
        
        let callId = callLog!.callId
        
        Log.directLog(BCTBX_LOG_DEBUG, text: "WEDO - CallId: \(callId), state: \(cstate), message: \(message)")
        
        /* Catch 488 Not Acceptable Here  */
        if((cstate == .OutgoingRinging || cstate == .Error || cstate == .OutgoingEarlyMedia || cstate == .End) && CallManager.instance().providerDelegate.uuids[callId] == nil && !TransferCallManager.instance().isCallTransfer) {
            var uuids = CallManager.instance().providerDelegate.uuids
            if(uuids.count > 1) {
                for (k, _) in CallManager.instance().providerDelegate.uuids {
                    if (CallManager.instance().findCall(callId: k) != nil) {
                        uuids.removeValue(forKey: k)
                    }
                }
                Log.directLog(BCTBX_LOG_DEBUG, text: "WEDO - uuids count = \(uuids.count)")
                if(uuids.count != 1) {
                    uuids = CallManager.instance().providerDelegate.uuids
                }
                
            }
            let map = uuids.first
            if(map != nil) {
                let lastuuid = map?.1
                let oldCallInfos = CallManager.instance().providerDelegate.callInfos[lastuuid!]
                
                Log.directLog(BCTBX_LOG_DEBUG, text: "WEDO - CallIdSwitch: Old: \(String(describing: map?.0)), New: \(callId)")
                
                CallManager.instance().providerDelegate.uuids.removeValue(forKey: map!.0)
                CallManager.instance().providerDelegate.uuids.updateValue(lastuuid!, forKey: callId)
                oldCallInfos?.callId = callId
            }
            
        }
        
        let video = UIApplication.shared.applicationState == .active && (lc.videoActivationPolicy?.automaticallyAccept ?? false) && (call.remoteParams?.videoEnabled ?? false)
        // we keep the speaker auto-enabled state in this static so that we don't
        // force-enable it on ICE re-invite if the user disabled it.
        CoreManagerDelegate.speaker_already_enabled = false
        
        if (call.userData == nil) {
            let appData = CallAppData()
            CallManager.setAppData(sCall: call, appData: appData)
        }
        
        switch cstate {
        case .IncomingReceived:
            if (CallManager.callKitEnabled()) {
                let uuid = CallManager.instance().providerDelegate.uuids["\(callId)"]
                if (uuid != nil) {
                    // Tha app is now registered, updated the call already existed.
                    CallManager.instance().providerDelegate.updateCall(uuid: uuid!, handle: addr!.asStringUriOnly(), hasVideo: video, displayName: displayName)
                    let callInfo = CallManager.instance().providerDelegate.callInfos[uuid!]
                    if (callInfo?.declined ?? false) {
                        // The call is already declined.
                        try? call.decline(reason: Reason.Unknown)
                    } else if (callInfo?.accepted ?? false) {
                        // The call is already answered.
                        CallManager.instance().acceptCall(call: call, hasVideo: video)
                    }
                } else {
                    CallManager.instance().displayIncomingCall(call: call, handle: addr!.asStringUriOnly(), hasVideo: video, callId: callId, displayName: displayName)
                }
            } else if (UIApplication.shared.applicationState != .active) {
                // not support callkit , use notif
                let content = UNMutableNotificationContent()
                content.title = NSLocalizedString("Incoming call", comment: "")
                content.body = displayName
                content.sound = UNNotificationSound.init(named: UNNotificationSoundName.init("notes_of_the_optimistic.caf"))
                content.categoryIdentifier = "call_cat"
                content.userInfo = ["CallId" : callId]
                let req = UNNotificationRequest.init(identifier: "call_request", content: content, trigger: nil)
                UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
            }
            break
        case .StreamsRunning:
            if (CallManager.callKitEnabled()) {
                let uuid = CallManager.instance().providerDelegate.uuids["\(callId)"]
                if (uuid != nil) {
                    let callInfo = CallManager.instance().providerDelegate.callInfos[uuid!]
                    if (callInfo != nil && callInfo!.isOutgoing && !callInfo!.connected) {
                        Log.directLog(BCTBX_LOG_MESSAGE, text: "WEDO: CallKit: outgoing call connected with uuid \(uuid!) and callId \(callId)")
                        CallManager.instance().providerDelegate.reportOutgoingCallConnected(uuid: uuid!)
                        callInfo!.connected = true
                        CallManager.instance().providerDelegate.callInfos.updateValue(callInfo!, forKey: uuid!)
                    }
                }
            }
            
            if (CallManager.instance().speakerBeforePause) {
                CallManager.instance().speakerBeforePause = false
                CallManager.instance().enableSpeaker(enable: true)
                CoreManagerDelegate.speaker_already_enabled = true
            }
            break
        case .OutgoingInit,
             .OutgoingProgress,
             .OutgoingRinging,
             .OutgoingEarlyMedia:
            if (CallManager.callKitEnabled()) {
                let uuid = CallManager.instance().providerDelegate.uuids[""]
                if (uuid != nil) {
                    let callInfo = CallManager.instance().providerDelegate.callInfos[uuid!]
                    callInfo!.callId = callId
                    CallManager.instance().providerDelegate.callInfos.updateValue(callInfo!, forKey: uuid!)
                    CallManager.instance().providerDelegate.uuids.removeValue(forKey: "")
                    CallManager.instance().providerDelegate.uuids.updateValue(uuid!, forKey: callId)
                    
                    Log.directLog(BCTBX_LOG_MESSAGE, text: "WEDO: CallKit: outgoing call started connecting with uuid \(uuid!) and callId \(callId)")
                    CallManager.instance().providerDelegate.reportOutgoingCallStartedConnecting(uuid: uuid!)
                } else {
                    CallManager.instance().referedToCall = callId
                }
            }
            break
        case .End,
             .Error:
            // Try to resume a previous call.
            if(TransferCallManager.instance().isCallTransfer &&
                TransferCallManager.instance().mTransferCallOrigin != nil) {
                guard let pointer = TransferCallManager.instance().mTransferCallOrigin else { return }
                let call = Call.getSwiftObject(cObject: pointer)
                do {
                    try call.resume()
                } catch (let errorThrown) {
                    print("[WEDO] Error in resuming previous call: \(errorThrown.localizedDescription)")
                    return
                }
            }
            
            // No more call transfer.
            TransferCallManager.instance().isCallTransfer = false
            
            // Other Linphone stuff.
            UIDevice.current.isProximityMonitoringEnabled = false
            CoreManagerDelegate.speaker_already_enabled = false
            if (CallManager.instance().lc!.callsNb == 0) {
                CallManager.instance().enableSpeaker(enable: false)
                // disable this because I don't find anygood reason for it: _bluetoothAvailable = FALSE;
                // furthermore it introduces a bug when calling multiple times since route may not be
                // reconfigured between cause leading to bluetooth being disabled while it should not
                CallManager.instance().bluetoothEnabled = false
            }
            
            if UIApplication.shared.applicationState != .active && (callLog == nil || callLog?.status == .Missed || callLog?.status == .Aborted || callLog?.status == .EarlyAborted)  {
                // Configure the notification's payload.
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: NSLocalizedString("Missed call", comment: ""), arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: displayName, arguments: nil)
                
                // Deliver the notification.
                let request = UNNotificationRequest(identifier: "call_request", content: content, trigger: nil) // Schedule the notification.
                let center = UNUserNotificationCenter.current()
                center.add(request) { (error : Error?) in
                    if error != nil {
                        Log.directLog(BCTBX_LOG_ERROR, text: "Error while adding notification request : \(error!.localizedDescription)")
                    }
                }
            }
            
            if (CallManager.callKitEnabled()) {
                var uuid = CallManager.instance().providerDelegate.uuids["\(callId)"]
                if (callId == CallManager.instance().referedToCall) {
                    // refered call ended before connecting
                    Log.directLog(BCTBX_LOG_MESSAGE, text: "Callkit: end refered to call :  \(String(describing: CallManager.instance().referedToCall))")
                    CallManager.instance().referedFromCall = nil
                    CallManager.instance().referedToCall = nil
                }
                if uuid == nil {
                    // the call not yet connected
                    uuid = CallManager.instance().providerDelegate.uuids[""]
                }
                if (uuid != nil) {
                    if (callId == CallManager.instance().referedFromCall) {
                        Log.directLog(BCTBX_LOG_MESSAGE, text: "Callkit: end refered from call : \(String(describing: CallManager.instance().referedFromCall))")
                        CallManager.instance().referedFromCall = nil
                        let callInfo = CallManager.instance().providerDelegate.callInfos[uuid!]
                        callInfo!.callId = CallManager.instance().referedToCall ?? ""
                        CallManager.instance().providerDelegate.callInfos.updateValue(callInfo!, forKey: uuid!)
                        CallManager.instance().providerDelegate.uuids.removeValue(forKey: callId)
                        CallManager.instance().providerDelegate.uuids.updateValue(uuid!, forKey: callInfo!.callId)
                        CallManager.instance().referedToCall = nil
                        break
                    }
                    
                    let transaction = CXTransaction(action:
                                                        CXEndCallAction(call: uuid!))
                    CallManager.instance().requestTransaction(transaction, action: "endCall")
                }
            }
            break
        case .Released:
            call.userData = nil
            break
        case .Referred:
            CallManager.instance().referedFromCall = call.callLog?.callId
            break
        default:
            break
        }
        
        if (cstate == .IncomingReceived || cstate == .OutgoingInit || cstate == .Connected || cstate == .StreamsRunning) {
            if ((call.currentParams?.videoEnabled ?? false) && !CoreManagerDelegate.speaker_already_enabled && !CallManager.instance().bluetoothEnabled) {
                CallManager.instance().enableSpeaker(enable: true)
                CoreManagerDelegate.speaker_already_enabled = true
            }
        }
        
        // post Notification kLinphoneCallUpdate
        NotificationCenter.default.post(name: Notification.Name("LinphoneCallUpdate"), object: self, userInfo: [
            AnyHashable("call"): NSValue.init(pointer:UnsafeRawPointer(call.getCobject)),
            AnyHashable("state"): NSNumber(value: cstate.rawValue),
            AnyHashable("message"): message
        ])
    }
}


