#define SPAM_TIME 30 SECONDS

SUBSYSTEM_DEF(pai)
	name = "pAI"

	flags = SS_NO_INIT|SS_NO_FIRE

	/// List of pAI candidates, including those not submitted.
	var/list/candidates = list()
	/// Prevents a pAI from submitting itself repeatedly and sounding an alert.
	var/submit_spam = FALSE
	/// All pAI cards on the map.
	var/list/pai_card_list = list()

/datum/controller/subsystem/pai/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PaiSubmit")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/controller/subsystem/pai/ui_state(mob/user)
	return GLOB.observer_state

/datum/controller/subsystem/pai/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()
	var/datum/pai_candidate/candidate = candidates[user.ckey]
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
	var/datum/pai_candidate/candidate = candidates[usr.ckey]
	if(is_banned_from(usr.ckey, ROLE_PAI))
		to_chat(usr, span_warning("You are banned from playing pAI!"))
		ui.close()
		return FALSE
	if(isnull(candidate))
		to_chat(usr, span_warning("There was an error. Please resubmit."))
		ui.close()
		return FALSE
	switch(action)
		if("submit")
			candidate.comments = params["comments"]
			candidate.description = params["description"]
			candidate.name = params["name"]
			candidate.user = usr
			sanitize_details(candidate)
			candidate.ready = TRUE
			ui.close()
			submit_alert()
			return TRUE
		if("save")
			candidate.comments = params["comments"]
			candidate.description = params["description"]
			candidate.name = params["name"]
			candidate.user = usr
			sanitize_details(candidate)
			candidate.savefile_save(usr)
			return TRUE
		if("load")
			candidate.savefile_load(usr)
			sanitize_details(candidate)
			ui.send_full_update()
			return TRUE
	return FALSE

/**
 * This is the primary window proc when the pAI candidate
 * hud menu is pressed by observers.
 *
 * Arguments
 *
 * @user - The ghost doing the pressing.
 */
/datum/controller/subsystem/pai/proc/recruit_window(mob/user)
	/// Searches for a previous candidate upon opening the menu
	var/datum/pai_candidate/candidate = candidates[user.ckey]
	if(isnull(candidate))
		candidate = new /datum/pai_candidate(user)
		candidates[user.ckey] = candidate
	ui_interact(user)

/** Sanitizes PAI details */
/datum/controller/subsystem/pai/proc/sanitize_details(datum/pai_candidate/candidate)
	if(candidate.comments)
		candidate.comments = copytext_char(candidate.comments, 1, MAX_MESSAGE_LEN)
	if(candidate.description)
		candidate.description = copytext_char(candidate.description, 1, MAX_MESSAGE_LEN)
	if(candidate.name)
		candidate.name = copytext_char(candidate.name, 1, MAX_NAME_LEN)
	return TRUE

/** Allows the candidate to spam pai_cards again. */
/datum/controller/subsystem/pai/proc/submit_again()
	submit_spam = FALSE

/**
 * Pings all pAI cards on the station that new candidates are available.
 */
/datum/controller/subsystem/pai/proc/submit_alert()
	if(submit_spam)
		to_chat(usr, span_warning("Your candidacy has been submitted, but pAI cards have been alerted too recently."))
		return FALSE
	submit_spam = TRUE
	for(var/obj/item/pai_card/pai_card in pai_card_list)
		if(!pai_card.pai)
			pai_card.alert_update()
	to_chat(usr, span_notice("Your pAI candidacy has been submitted!"))
	addtimer(CALLBACK(src, .proc/submit_again), SPAM_TIME, TIMER_UNIQUE | TIMER_STOPPABLE | TIMER_CLIENT_TIME | TIMER_DELETE_ME)
	return TRUE

#undef SPAM_TIME
