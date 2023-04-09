SUBSYSTEM_DEF(pai)
	name = "pAI"
	flags = SS_NO_INIT|SS_NO_FIRE

	/// List of pAI candidates, including those not submitted.
	var/list/candidates = list()
	/// All pAI cards on the map.
	var/list/pai_card_list = list()
	/// Prevents a pAI from submitting itself repeatedly and sounding an alert.
	var/submit_spam = FALSE

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
		return TRUE
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
			candidate.comments = trim(params["comments"], MAX_BROADCAST_LEN)
			candidate.description = trim(params["description"], MAX_BROADCAST_LEN)
			candidate.name = trim(params["name"], MAX_NAME_LEN)
			candidate.ckey = usr.ckey
			candidate.ready = TRUE
			ui.close()
			submit_alert()
			return TRUE
		if("save")
			candidate.comments = params["comments"]
			candidate.description = params["description"]
			candidate.name = params["name"]
			candidate.savefile_save(usr)
			return TRUE
		if("load")
			candidate.savefile_load(usr)
			ui.send_full_update()
			return TRUE
	return FALSE

/**
 * This is the primary window proc when the pAI candidate
 * hud menu is pressed by observers.
 *
 * @params {mob} user The ghost doing the pressing.
 */
/datum/controller/subsystem/pai/proc/recruit_window(mob/user)
	/// Searches for a previous candidate upon opening the menu
	var/datum/pai_candidate/candidate = candidates[user.ckey]
	if(isnull(candidate))
		candidate = new(user.ckey)
		candidates[user.ckey] = candidate
	ui_interact(user)


/**
 * Pings all pAI cards on the station that new candidates are available.
 */
/datum/controller/subsystem/pai/proc/submit_alert()
	if(submit_spam)
		to_chat(usr, span_warning("Your candidacy has been submitted, but pAI cards have been alerted too recently."))
		return FALSE
	submit_spam = TRUE
	for(var/obj/item/pai_card/pai_card as anything in pai_card_list)
		if(!pai_card.pai)
			pai_card.alert_update()
	to_chat(usr, span_notice("Your pAI candidacy has been submitted!"))
	addtimer(VARSET_CALLBACK(src, submit_spam, FALSE), PAI_SPAM_TIME, TIMER_UNIQUE | TIMER_STOPPABLE | TIMER_CLIENT_TIME | TIMER_DELETE_ME)
	return TRUE
