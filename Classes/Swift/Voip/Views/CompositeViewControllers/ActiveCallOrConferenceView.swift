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


import UIKit
import linphonesw


@objc class ActiveCallOrConferenceView: UIViewController, UICompositeViewDelegate { // Replaces CallView
	
	// Layout constants
	static let content_inset = 12.0
	
	var callPausedByRemoteView : PausedCallOrConferenceView? = nil
	var callPausedByLocalView : PausedCallOrConferenceView? = nil
	
	var conferencePausedView : PausedCallOrConferenceView? = nil
	
	var currentCallView : ActiveCallView? = nil
	var conferenceGridView: VoipConferenceGridView? = nil
	var conferenceActiveSpeakerView: VoipConferenceActiveSpeakerView? = nil
	var conferenceAudioOnlyView: VoipConferenceAudioOnlyView? = nil
	
	let conferenceJoinSpinner = RotatingSpinner()
	
	
	let extraButtonsView = VoipExtraButtonsView()
	var numpadView : NumpadView? = nil
	var currentCallStatsVew : CallStatsView? = nil
	var shadingMask = UIView()
	var videoAcceptDialog : VoipDialog? = nil
	var dismissableView :  DismissableView? = nil
	@objc var participantsListView :  ParticipantsListView? = nil
	
	var audioRoutesView : AudioRoutesView? = nil
	let fullScreenMutableContainerView = UIView()
	let controlsView = ControlsView(showVideo: true, controlsViewModel: ControlsViewModel.shared)
	
	static let compositeDescription = UICompositeViewDescription(ActiveCallOrConferenceView.self, statusBar: StatusBarView.self, tabBar: nil, sideMenu: nil, fullscreen: false, isLeftFragment: false,fragmentWith: nil)
	static func compositeViewDescription() -> UICompositeViewDescription! { return compositeDescription }
	func compositeViewDescription() -> UICompositeViewDescription! { return type(of: self).compositeDescription }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = VoipTheme.voipBackgroundColor.get()
        view.accessibilityIdentifier = "active_call_view"
		
		// Hangup
		let hangup = CallControlButton(width: 65, imageInset:IncomingOutgoingCommonView.answer_decline_inset, buttonTheme: VoipTheme.call_terminate, onClickAction: {
			ControlsViewModel.shared.hangUp()
		})
		view.addSubview(hangup)
		hangup.alignParentLeft(withMargin:SharedLayoutConstants.margin_call_view_side_controls_buttons).alignParentBottom(withMargin:SharedLayoutConstants.buttons_bottom_margin).done()
        hangup.accessibilityIdentifier = "active_call_view_hangup"
        hangup.accessibilityLabel = "Hangup"
		
		
		// Controls
		view.addSubview(controlsView)
		controlsView.alignParentBottom(withMargin:SharedLayoutConstants.buttons_bottom_margin).centerX().done()
		
		// Container view
		fullScreenMutableContainerView.backgroundColor = .clear
		self.view.addSubview(fullScreenMutableContainerView)
		fullScreenMutableContainerView.alignParentLeft(withMargin: ActiveCallOrConferenceView.content_inset).alignParentRight(withMargin: ActiveCallOrConferenceView.content_inset).matchParentHeight().alignAbove(view:controlsView,withMargin:SharedLayoutConstants.buttons_bottom_margin).done()
		
		// Current (Single) Call (VoipCallView)
		currentCallView = ActiveCallView()
		currentCallView!.isHidden = true
		fullScreenMutableContainerView.addSubview(currentCallView!)
		CallsViewModel.shared.currentCallData.readCurrentAndObserve { (currentCallData) in
			self.updateNavigation()
			self.currentCallView!.isHidden = currentCallData == nil || ConferenceViewModel.shared.conferenceExists.value == true
			self.currentCallView!.callData = currentCallData != nil ? currentCallData! : nil
			currentCallData??.isRemotelyPaused.readCurrentAndObserve { remotelyPaused in
				self.callPausedByRemoteView?.isHidden = remotelyPaused != true || ConferenceViewModel.shared.conferenceExists.value == true
			}
			currentCallData??.isPaused.readCurrentAndObserve { locallyPaused in
				self.callPausedByLocalView?.isHidden = locallyPaused != true || ConferenceViewModel.shared.conferenceExists.value == true
			}
			if (currentCallData == nil) {
				self.callPausedByRemoteView?.isHidden = true
				self.callPausedByLocalView?.isHidden = true
				
			} else {
				currentCallData??.isIncoming.readCurrentAndObserve { _ in self.updateNavigation() }
				currentCallData??.isOutgoing.readCurrentAndObserve { _ in self.updateNavigation() }
			}
			self.extraButtonsView.isHidden = true
			self.conferencePausedView?.isHidden = true
			if (ConferenceViewModel.shared.conferenceExists.value != true) {
				self.conferenceGridView?.isHidden = true
				self.conferenceActiveSpeakerView?.isHidden = true
				self.conferenceAudioOnlyView?.isHidden = true
			}
			
		}
		
		currentCallView!.matchParentDimmensions().done()
		
		// Paused by remote (Call)
		callPausedByRemoteView = PausedCallOrConferenceView(iconName: "voip_conference_paused_big",titleText: VoipTexts.call_remotely_paused_title,subTitleText: nil)
		view.addSubview(callPausedByRemoteView!)
		callPausedByRemoteView?.matchParentSideBorders().matchParentHeight().alignAbove(view:controlsView,withMargin:SharedLayoutConstants.buttons_bottom_margin).done()
		callPausedByRemoteView?.isHidden = true
		
		// Paused by local (Call)
        callPausedByLocalView = PausedCallOrConferenceView(iconName: "voip_conference_play_big",titleText: VoipTexts.call_locally_paused_title,subTitleText: VoipTexts.call_locally_paused_subtitle, onClickAction: {
            CallsViewModel.shared.currentCallData.value??.togglePause()
        })
		view.addSubview(callPausedByLocalView!)
		callPausedByLocalView?.matchParentSideBorders().matchParentHeight().alignAbove(view:controlsView,withMargin:SharedLayoutConstants.buttons_bottom_margin).done()
		callPausedByLocalView?.isHidden = true
		
		
		// Conference paused
		conferencePausedView = PausedCallOrConferenceView(iconName: "voip_conference_play_big",titleText: VoipTexts.conference_paused_title,subTitleText: VoipTexts.conference_paused_subtitle, onClickAction: {
			ConferenceViewModel.shared.togglePlayPause()
		})
		view.addSubview(conferencePausedView!)
		conferencePausedView?.matchParentSideBorders().matchParentHeight().alignAbove(view:controlsView,withMargin:SharedLayoutConstants.buttons_bottom_margin).done()
		conferencePausedView?.isHidden = true
		
		// Conference grid
		conferenceGridView = VoipConferenceGridView()
		fullScreenMutableContainerView.addSubview(conferenceGridView!)
		conferenceGridView?.matchParentDimmensions().done()
		conferenceGridView?.isHidden = true
		ConferenceViewModel.shared.conferenceExists.readCurrentAndObserve { (exists) in
			self.updateNavigation()
			if (exists == true) {
				self.currentCallView!.isHidden = true
				self.extraButtonsView.isHidden = true
				self.conferencePausedView?.isHidden = true
				self.displaySelectedConferenceLayout()
			} else {
				self.conferenceGridView?.isHidden = true
				self.conferenceActiveSpeakerView?.isHidden = true
				self.conferenceActiveSpeakerView?.isHidden = true
			}
		}
		
		ConferenceViewModel.shared.conferenceCreationPending.readCurrentAndObserve { isCreationPending in
			if (ConferenceViewModel.shared.conferenceExists.value == true && isCreationPending == true) {
				self.fullScreenMutableContainerView.addSubview(self.conferenceJoinSpinner)
				self.conferenceJoinSpinner.square(IncomingOutgoingCommonView.spinner_size).center().done()
				self.conferenceJoinSpinner.startRotation()
			} else {
				self.conferenceJoinSpinner.removeFromSuperview()
				self.conferenceJoinSpinner.stopRotation()
			}
		}
		
		// Conference active speaker
		conferenceActiveSpeakerView = VoipConferenceActiveSpeakerView()
		fullScreenMutableContainerView.addSubview(conferenceActiveSpeakerView!)
		conferenceActiveSpeakerView?.matchParentDimmensions().done()
		conferenceActiveSpeakerView?.isHidden = true
		
		
		// Conference audio only
		conferenceAudioOnlyView = VoipConferenceAudioOnlyView()
		fullScreenMutableContainerView.addSubview(conferenceAudioOnlyView!)
		conferenceAudioOnlyView?.matchParentDimmensions().done()
		conferenceAudioOnlyView?.isHidden = true
		
		ConferenceViewModel.shared.conferenceDisplayMode.readCurrentAndObserve { (conferenceMode) in
			if (ConferenceViewModel.shared.conferenceExists.value == true) {
				self.displaySelectedConferenceLayout()
			}
		}
		ConferenceViewModel.shared.isConferenceLocallyPaused.readCurrentAndObserve { (paused) in
			self.conferencePausedView?.isHidden = paused != true || ConferenceViewModel.shared.conferenceExists.value != true
		}
		
		
		// Calls List
		ControlsViewModel.shared.goToCallsListEvent.observe { (_) in
			self.dismissableView = CallsListView()
			self.view.addSubview(self.dismissableView!)
			self.dismissableView?.matchParentDimmensions().done()
		}
		
		// Conference Participants List
		ControlsViewModel.shared.goToConferenceParticipantsListEvent.observe { (_) in
			self.participantsListView = ParticipantsListView()
			self.view.addSubview(self.participantsListView!)
			self.participantsListView?.matchParentDimmensions().done()
		}
		
		// Goto chat
		ControlsViewModel.shared.goToChatEvent.observe { (_) in
			self.goToChat()
		}
		
		// Conference mode selection
		ControlsViewModel.shared.goToConferenceLayoutSettings.observe { (_) in
			self.dismissableView = VoipConferenceDisplayModeSelectionView()
			self.view.addSubview(self.dismissableView!)
			self.dismissableView?.matchParentDimmensions().done()
			let activeDisplayMode =  ConferenceViewModel.shared.conferenceDisplayMode.value!
			let indexPath = IndexPath(row: activeDisplayMode == .Grid ? 0 :  activeDisplayMode == .ActiveSpeaker ? 1 : 2, section: 0)
			(self.dismissableView as! VoipConferenceDisplayModeSelectionView).optionsListView.selectRow(at:indexPath, animated: true, scrollPosition: .bottom)
		}
		
		// Shading mask, everything before will be shaded upon displaying of the mask
		shadingMask.backgroundColor = VoipTheme.voip_translucent_popup_background
		shadingMask.isHidden = true
		self.view.addSubview(shadingMask)
		shadingMask.matchParentDimmensions().done()
        shadingMask.accessibilityIdentifier = "active_call_view_shading_mask"
		
		// Extra Buttons
		let showextraButtons = CallControlButton(imageInset:IncomingOutgoingCommonView.answer_decline_inset, buttonTheme: VoipTheme.call_more, onClickAction: {
			self.showModalSubview(view: self.extraButtonsView)
			ControlsViewModel.shared.audioRoutesSelected.value = false
		})
		view.addSubview(showextraButtons)
		showextraButtons.alignParentRight(withMargin:SharedLayoutConstants.margin_call_view_side_controls_buttons).alignParentBottom(withMargin:SharedLayoutConstants.buttons_bottom_margin).done()
        showextraButtons.accessibilityIdentifier = "active_call_view_extra_buttons"
        showextraButtons.accessibilityLabel = "More actions"

		let boucingCounter = BouncingCounter(inButton:showextraButtons)
		view.addSubview(boucingCounter)
		boucingCounter.dataSource = CallsViewModel.shared.chatAndCallsCount
		
		view.addSubview(extraButtonsView)
		extraButtonsView.matchParentSideBorders(insetedByDx: ActiveCallOrConferenceView.content_inset).alignParentBottom(withMargin:SharedLayoutConstants.bottom_margin_notch_clearance).done()
		ControlsViewModel.shared.hideExtraButtons.readCurrentAndObserve { (_) in
			self.hideModalSubview(view: self.extraButtonsView)
		}
		shadingMask.onClick {
			if (!self.extraButtonsView.isHidden) {
				self.hideModalSubview(view: self.extraButtonsView)
			}
			ControlsViewModel.shared.audioRoutesSelected.value = false
		}
		
		// Numpad
		ControlsViewModel.shared.numpadVisible.readCurrentAndObserve { (visible) in
			if (visible == true && CallsViewModel.shared.currentCallData.value != nil ) {
				self.numpadView?.removeFromSuperview()
				self.shadingMask.isHidden = false
				self.numpadView = NumpadView(superView: self.view,callData:  CallsViewModel.shared.currentCallData.value!!,marginTop:self.currentCallView?.centerSection.frame.origin.y ?? 0.0, above:self.controlsView, onDismissAction: {
					ControlsViewModel.shared.numpadVisible.value = false
				})
            } else {
                self.numpadView?.removeFromSuperview()
                self.shadingMask.isHidden = true
            }
		}
		
		// Call stats
		ControlsViewModel.shared.callStatsVisible.readCurrentAndObserve { (visible) in
			if (visible == true && CallsViewModel.shared.currentCallData.value != nil ) {
				self.currentCallStatsVew?.removeFromSuperview()
				self.shadingMask.isHidden = false
				self.currentCallStatsVew = CallStatsView(superView: self.view,callData:  CallsViewModel.shared.currentCallData.value!!,marginTop:self.currentCallView?.centerSection.frame.origin.y ?? 0.0, above:self.controlsView, onDismissAction: {
					ControlsViewModel.shared.callStatsVisible.value = false
				})
            } else {
                self.currentCallStatsVew?.removeFromSuperview()
                self.shadingMask.isHidden = true
            }
		}
		
		// Video and Microphone activation dialog request
		CallsViewModel.shared.callUpdateEvent.observe { (call) in
			let core = Core.get()
			if (call?.state == .StreamsRunning) {
				self.videoAcceptDialog?.removeFromSuperview()
				self.videoAcceptDialog = nil
				if (!ControlsViewModel.shared.micAuthorized() && !ControlsViewModel.shared.microphoneAsking) {
					ControlsViewModel.shared.askMicrophoneAccess()
				}
			} else if (call?.state == .UpdatedByRemote) {
				if (core.videoCaptureEnabled || core.videoDisplayEnabled) {
					if (call?.currentParams?.videoEnabled != call?.remoteParams?.videoEnabled) {
						let accept = ButtonAttributes(text:VoipTexts.dialog_accept, action: {call?.answerVideoUpdateRequest(accept: true)}, isDestructive:false)
						let cancel = ButtonAttributes(text:VoipTexts.dialog_decline, action: {call?.answerVideoUpdateRequest(accept: false)}, isDestructive:true)
						self.videoAcceptDialog = VoipDialog(message:VoipTexts.call_video_update_requested_dialog, givenButtons:  [cancel,accept])
						self.videoAcceptDialog?.show()
					}
				} else {
					Log.w("[Call] Video display & capture are disabled, don't show video dialog")
				}
			}
		}
		
		// Audio Routes
		audioRoutesView = AudioRoutesView()
		view.addSubview(audioRoutesView!)
		audioRoutesView!.alignBottomWith(otherView: controlsView).done()
		ControlsViewModel.shared.audioRoutesSelected.readCurrentAndObserve { (audioRoutesSelected) in
			self.audioRoutesView!.isHidden = audioRoutesSelected != true
		}
		audioRoutesView!.alignAbove(view:controlsView,withMargin:SharedLayoutConstants.buttons_bottom_margin).centerX().done()
		
		// First/Last to join conference :
		
		ConferenceViewModel.shared.allParticipantsLeftEvent.observe { (allLeft) in
			if (allLeft == true) {
				VoipDialog.toast(message: VoipTexts.conference_last_user)
			}
		}
		ConferenceViewModel.shared.firstToJoinEvent.observe { (first) in
			if (first == true) {
				VoipDialog.toast(message: VoipTexts.conference_first_to_join)
			}
		}
		
	} // viewDidLoad
	
	func displaySelectedConferenceLayout() {
		let conferenceMode = ConferenceViewModel.shared.conferenceDisplayMode.value
		self.conferenceGridView!.isHidden = conferenceMode != .Grid
		self.conferenceActiveSpeakerView!.isHidden = conferenceMode != .ActiveSpeaker
		self.conferenceAudioOnlyView!.isHidden = conferenceMode != .AudioOnly
		if (conferenceMode == .Grid) {
			self.conferenceGridView?.conferenceViewModel = ConferenceViewModel.shared
		}
		if (conferenceMode == .AudioOnly) {
			self.conferenceAudioOnlyView?.conferenceViewModel = ConferenceViewModel.shared
		}
		if (conferenceMode == .ActiveSpeaker) {
			self.conferenceActiveSpeakerView?.conferenceViewModel = ConferenceViewModel.shared
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		extraButtonsView.refresh()
		ControlsViewModel.shared.callStatsVisible.notifyValue()
		CallsViewModel.shared.currentCallData.notifyValue()
		ControlsViewModel.shared.audioRoutesSelected.value = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		dismissableView?.removeFromSuperview()
		dismissableView = nil
		
		participantsListView?.removeFromSuperview()
		participantsListView = nil
		
        ControlsViewModel.shared.numpadVisible.value = false
        ControlsViewModel.shared.callStatsVisible.value = false
		ControlsViewModel.shared.fullScreenMode.value = false
		super.viewWillDisappear(animated)
	}
	
	func showModalSubview(view:UIView) {
		view.isHidden = false
		shadingMask.isHidden = false
	}
	func hideModalSubview(view:UIView) {
		view.isHidden = true
		shadingMask.isHidden = true
	}
	
	func updateNavigation() {
		if (Core.get().callsNb == 0) {
			PhoneMainView.instance().popView(self.compositeViewDescription())
		} else {
			if let data = CallsViewModel.shared.currentCallData.value {
				if (data?.isOutgoing.value == true || data?.isIncoming.value == true) {
					PhoneMainView.instance().popView(self.compositeViewDescription())
				} else {
					if (data!.isInRemoteConference.value == true) {
						PhoneMainView.instance().pop(toView: self.compositeViewDescription())
					} else {
						PhoneMainView.instance().changeCurrentView(self.compositeViewDescription())
					}
				}
			} else {
				PhoneMainView.instance().changeCurrentView(self.compositeViewDescription())
			}
		}
	}
	
	func goToChat() {
		/*guard
		 let chatRoom = CallsViewModel.shared.currentCallData.value??.chatRoom
		 else {
		 Log.w("[Call] Failed to find existing chat room associated to call")
		 return
		 }*/
		PhoneMainView.instance().changeCurrentView(ChatsListView.compositeViewDescription())
		
	}
	
	
	func layoutRotatableElements() {
		let leftMargin = UIDevice.current.orientation == .landscapeLeft && UIDevice.hasNotch() ? UIApplication.shared.keyWindow!.safeAreaInsets.left : ActiveCallOrConferenceView.content_inset
		let rightMargin = UIDevice.current.orientation == .landscapeRight && UIDevice.hasNotch() ? UIApplication.shared.keyWindow!.safeAreaInsets.right : ActiveCallOrConferenceView.content_inset
		fullScreenMutableContainerView.updateAlignParentLeft(withMargin: leftMargin).updateAlignParentRight(withMargin: rightMargin).done()
		controlsView.updateAlignParentBottom(withMargin:SharedLayoutConstants.buttons_bottom_margin).centerX().done()
	}
	
	override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
		super.didRotate(from: fromInterfaceOrientation)
		self.layoutRotatableElements()
		self.conferenceActiveSpeakerView?.layoutRotatableElements()
		self.currentCallView?.layoutRotatableElements()
	}
	
	
}
