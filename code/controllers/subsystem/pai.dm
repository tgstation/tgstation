SUBSYSTEM_DEF(pai)
	name = "pAI"

	flags = SS_NO_INIT|SS_NO_FIRE

	/// List of pAI candidates, including those not submitted.
	var/list/candidates = list()
	/// Prevents a crew member from hitting "request pAI"
	var/request_spam = FALSE
	/// Prevents a pAI from submitting itself repeatedly and sounding an alert.
	var/submit_spam = FALSE
	/// All pAI cards on the map.
	var/list/pai_card_list = list()

/// Created when a user clicks the "pAI candidate" window
/datum/pai_candidate
	/// User inputted OOC comments
	var/comments
	/// User inputted behavior description
	var/description
	/// User's ckey - not input
	var/key
	/// User's pAI name. If blank, ninja name.
	var/name
	/// If the user has hit "submit"
	var/ready = FALSE

/**
 * Pings ghosts to announce that someone is requesting a pAI
 *
 * Arguments
 * @pai - The card requesting assistance
 * @user - The player requesting a pAI
*/
/datum/controller/subsystem/pai/proc/findPAI(obj/item/paicard/pai, mob/user)
	if(!(GLOB.ghost_role_flags & GHOSTROLE_SILICONS))
		to_chat(user, span_warning("Due to growing incidents of SELF corrupted independent artificial intelligences, freeform personality devices have been temporarily banned in this sector."))
		return
	if(request_spam)
		to_chat(user, span_warning("Request sent too recently."))
		return
	request_spam = TRUE
	playsound(src, 'sound/machines/ping.ogg', 20, TRUE)
	to_chat(user, span_notice("You have requested pAI assistance."))
	var/mutable_appearance/alert_overlay = mutable_appearance('icons/obj/aicards.dmi', "pai")
	notify_ghosts("[user] is requesting a pAI personality! Use the pAI button to submit yourself as one.", source=user, alert_overlay = alert_overlay, action=NOTIFY_ORBIT, header="pAI Request!", ignore_key = POLL_IGNORE_PAI)
	addtimer(CALLBACK(src, .proc/request_again), 10 SECONDS)
	return TRUE

/**
 * This is the primary window proc when the pAI candidate
 * hud menu is pressed by observers.
 *
 * Arguments
 * @user - The ghost doing the pressing.
 */
/datum/controller/subsystem/pai/proc/recruitWindow(mob/user)
	/// Searches for a previous candidate upon opening the menu
	var/datum/pai_candidate/candidate = check_candidate(user)
	if(isnull(candidate))
		candidate = new /datum/pai_candidate()
		candidate.key = user.key
		candidates.Add(candidate)
	ui_interact(user)

/datum/controller/subsystem/pai/ui_state(mob/user)
	return GLOB.observer_state

/datum/controller/subsystem/pai/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiSubmit")
		ui.open()

/datum/controller/subsystem/pai/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()
	/// The matching candidate from search
	var/datum/pai_candidate/candidate = check_candidate(user)
	if(isnull(candidate))
		return data
	data["comments"] = candidate.comments
	data["description"] = candidate.description
	data["name"] = candidate.name
	return data

/datum/controller/subsystem/pai/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	/// The matching candidate from search
	var/datum/pai_candidate/candidate = check_candidate(usr)
	if(isnull(candidate))
		to_chat(usr, span_warning("There was an error. Please resubmit."))
		ui.close()
		return FALSE
	switch(action)
		if("submit")
			candidate.comments = params["candidate"]["comments"]
			candidate.description = params["candidate"]["description"]
			candidate.name = params["candidate"]["name"]
			candidate.ready = TRUE
			ui.close()
			submit_alert()
		if("save")
			candidate.comments = params["candidate"]["comments"]
			candidate.description = params["candidate"]["description"]
			candidate.name = params["candidate"]["name"]
			candidate.savefile_save(usr)
		if("load")
			candidate.savefile_load(usr)
			//In case people have saved unsanitized stuff.
			if(candidate.comments)
				candidate.comments = copytext_char(candidate.comments,1,MAX_MESSAGE_LEN)
			if(candidate.description)
				candidate.description = copytext_char(candidate.description,1,MAX_MESSAGE_LEN)
			if(candidate.name)
				candidate.name = copytext_char(candidate.name,1,MAX_NAME_LEN)
			ui.send_full_update()
	return

/**
 * Finds the candidate in question from the list of candidates.
 */
/datum/controller/subsystem/pai/proc/check_candidate(mob/user)
	/// Finds a matching candidate.
	var/datum/pai_candidate/candidate
	for(var/datum/pai_candidate/checked_candidate as anything in candidates)
		if(checked_candidate.key == user.key)
			candidate = checked_candidate
			return candidate
	return null

/**
 * Pings all pAI cards on the station that new candidates are available.
 */
/datum/controller/subsystem/pai/proc/submit_alert()
	if(submit_spam)
		to_chat(usr, span_warning("Your candidacy has been submitted, but pAI cards have been alerted too recently."))
		return FALSE
	submit_spam = TRUE
	for(var/obj/item/paicard/paicard in pai_card_list)
		if(!paicard.pai)
			paicard.alertUpdate()
	to_chat(usr, span_notice("Your pAI candidacy has been submitted!"))
	addtimer(CALLBACK(src, .proc/submit_again), 10 SECONDS)
	return TRUE

/datum/controller/subsystem/pai/proc/request_again()
	request_spam = FALSE

/datum/controller/subsystem/pai/proc/submit_again()
	submit_spam = FALSE

/**
 * Checks if a candidate is ready so that they may be displayed in the pAI
 * card's candidate window
 */
/datum/controller/subsystem/pai/proc/check_ready(datum/pai_candidate/candidate)
	if(!candidate.ready)
		return FALSE
	for(var/mob/dead/observer/observer in GLOB.player_list)
		if(observer.key == candidate.key)
			return candidate
	return FALSE

