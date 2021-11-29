SUBSYSTEM_DEF(pai)
	name = "pAI"

	flags = SS_NO_INIT|SS_NO_FIRE

	var/list/candidates = list()
	var/ghost_spam = FALSE
	var/list/pai_card_list = list()

/datum/pai_candidate
	var/comments
	var/description
	var/key
	var/name
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
	if(ghost_spam)
		return
	ghost_spam = TRUE
	to_chat(user, span_notice("You have requested PAI assistance."))
	for(var/mob/dead/observer/ghost in GLOB.player_list)
		if(!ghost.key)
			continue
		if(!(ROLE_PAI in ghost.client.prefs.be_special))
			continue
		to_chat(ghost, span_ghostalert("[user] is requesting a pAI personality! Use the pAI button to submit yourself as one."))
	addtimer(CALLBACK(src, .proc/spam_again), 10 SECONDS)
	return TRUE

/**
 * This is the primary window proc when the pAI candidate
 * hud menu is pressed by observers.
 *
 * Arguments
 * @user - The ghost doing the pressing.
 */
/datum/controller/subsystem/pai/proc/recruitWindow(mob/user)
	/// Created candidate upon opening the menu
	var/datum/pai_candidate/candidate = check_candidate(user)
	if(isnull(candidate))
		return FALSE
	candidate = new /datum/pai_candidate()
	candidate.key = user.key
	candidates.Add(candidate)
	ui_interact(user)

/// Ensures an observer has the window open
/datum/controller/subsystem/pai/ui_state(mob/user)
	return GLOB.observer_state

/// Opens the TGUI window
/datum/controller/subsystem/pai/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiSubmit")
		ui.open()

/// The data sent to the window.
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

/// Actions sent by TGUI
/datum/controller/subsystem/pai/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(action == "submit")
		/// The matching candidate from search
		var/datum/pai_candidate/candidate = check_candidate(usr)
		if(isnull(candidate))
			return FALSE
		candidate.comments = params["candidate"]["comments"]
		candidate.description = params["candidate"]["description"]
		candidate.name = params["candidate"]["name"]
		candidate.ready = TRUE
		ui.close()
		submit_alert()
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
	if(ghost_spam)
		to_chat(usr, span_warning("You sent an alert to pAI cards too recently."))
		return FALSE
	ghost_spam = TRUE
	for(var/obj/item/paicard/paicard in pai_card_list)
		if(!paicard.pai)
			paicard.alertUpdate()
	to_chat(usr, span_notice("Your pAI candidacy has been submitted!"))
	addtimer(CALLBACK(src, .proc/spam_again), 10 SECONDS)
	return TRUE

/datum/controller/subsystem/pai/proc/spam_again()
	ghost_spam = FALSE

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

