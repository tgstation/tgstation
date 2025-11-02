ADMIN_VERB(law_panel, R_ADMIN, "Law Panel", "View the AI laws.", ADMIN_CATEGORY_EVENTS)
	if(!isobserver(user) && SSticker.HasRoundStarted())
		message_admins("[key_name_admin(user)] checked AI laws via the Law Panel.")
	var/datum/law_panel/tgui = new
	tgui.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Law Panel")

/datum/law_panel

/datum/law_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Lawpanel")
		ui.open()

/datum/law_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/law_panel/ui_close(mob/user)
	qdel(src)

/datum/law_panel/proc/add_law_helper(mob/living/user, mob/living/silicon/borgo)
	var/list/lawtypes = list(LAW_ZEROTH, LAW_HACKED, LAW_INHERENT, LAW_SUPPLIED) // in order of priority
	var/lawtype = tgui_input_list(user, "Select law type", "Law type", lawtypes)
	if(isnull(lawtype))
		return FALSE
	var/lawtext = tgui_input_text(user, "Input law text", "Law text") // admin verb so no max length and also any user-level input is config based already so ehhhh
	if(!lawtext)
		return FALSE
	if(QDELETED(src) || QDELETED(borgo))
		return

	switch(lawtype)
		if(LAW_ZEROTH)
			if(borgo.laws.zeroth || borgo.laws.zeroth_borg)
				var/zero_override_alert = tgui_alert(user, "This silicon already has a zeroth law, \
					this will override their existing one. Are you sure?", "Zeroth law override", list("Yes", "No"))
				if(zero_override_alert != "Yes" || QDELETED(src) || QDELETED(borgo))
					return FALSE

			borgo.laws.set_zeroth_law(lawtext)
			borgo.laws.protected_zeroth = TRUE
		if(LAW_HACKED)
			borgo.laws.add_hacked_law(lawtext)
		if(LAW_INHERENT)
			borgo.laws.add_inherent_law(lawtext)
		if(LAW_SUPPLIED)
			borgo.laws.add_supplied_law(lawtext) // Just goes to the end of the list

	log_law_change(user, "added law to [key_name(borgo)] (type: [lawtype], text: [lawtext])")
	log_admin("[key_name(user)] has UPLOADED a [lawtype] law to [key_name(borgo)] stating: [lawtext]")
	message_admins("[key_name(user)] has UPLOADED a [lawtype] law to [key_name(borgo)] stating: [lawtext]")
	return TRUE

/datum/law_panel/proc/move_law_helper(mob/living/user, mob/living/silicon/borgo, direction, law)
	var/list/relevant_laws = borgo.laws.inherent
	var/lawindex = relevant_laws.Find(law)
	if(!lawindex)
		to_chat(user, span_danger("Something went wrong, we couldn't move that law."))
		return FALSE

	switch(direction)
		if("up")
			if(lawindex == length(relevant_laws)) // Already at the top? Sanity
				to_chat(user, span_danger("Something went wrong, we couldn't move that law."))
				return FALSE

			relevant_laws.Swap(lawindex + 1, lawindex)
		if("down")
			if(lawindex == 1) // Already at the bottom? Sanity
				to_chat(user, span_danger("Something went wrong, we couldn't move that law."))
				return FALSE

			relevant_laws.Swap(lawindex - 1, lawindex)
		else
			CRASH("Invalid direction ([direction]) passed to move_law_helper.")

	log_law_change(user, "moved law for [key_name(borgo)] (type: [LAW_INHERENT], law: [law], direction: [direction])")
	log_admin("[key_name(user)] has MOVED a [LAW_INHERENT] law for [key_name(borgo)] [direction]. LAW: [law]")
	message_admins("[key_name(user)] has MOVED a [LAW_INHERENT] law for [key_name(borgo)] [direction]. LAW: [law]")
	return TRUE

/datum/law_panel/proc/edit_law_text_helper(mob/living/user, mob/living/silicon/borgo, lawtype, oldlaw)
	var/newlaw = tgui_input_text(user, "Edit this law's text.", "Edit law", oldlaw)
	if(!newlaw || QDELETED(src) || QDELETED(borgo))
		return FALSE

	var/list/relevant_laws
	switch(lawtype)
		if(LAW_INHERENT)
			relevant_laws = borgo.laws.inherent
		if(LAW_SUPPLIED)
			relevant_laws = borgo.laws.supplied
		if(LAW_HACKED)
			relevant_laws = borgo.laws.hacked
		if(LAW_ZEROTH)
			borgo.laws.set_zeroth_law(newlaw)
			borgo.laws.protected_zeroth = TRUE

		else
			return FALSE

	if(lawtype != LAW_ZEROTH)
		var/lawindex = relevant_laws.Find(oldlaw)
		if(!lawindex)
			to_chat(user, span_danger("Something went wrong, we couldn't edit that law."))
			return FALSE

		relevant_laws[lawindex] = newlaw

	log_law_change(user, "edited law for [key_name(borgo)] (type: [lawtype], old: [oldlaw], new: [newlaw])")
	log_admin("[key_name(user)] has EDITED [key_name(borgo)] [lawtype] law. OLD LAW: [oldlaw] \
		NEW LAW: [newlaw]")
	message_admins("[key_name(user)] has EDITED a [lawtype] law on [key_name(borgo)]")
	return TRUE

/datum/law_panel/proc/remove_law_helper(mob/living/user, mob/living/silicon/borgo, lawtype, law)
	switch(lawtype)
		if(LAW_INHERENT)
			borgo.laws.remove_inherent_law(law)
		if(LAW_SUPPLIED)
			borgo.laws.remove_supplied_law(law)
		if(LAW_HACKED)
			borgo.laws.remove_hacked_law(law)
		if(LAW_ZEROTH)
			borgo.laws.clear_zeroth_law(force = TRUE)
		else
			return FALSE

	log_law_change(user, "removed law from [key_name(borgo)] (type: [lawtype], text: [law])")
	log_admin("[key_name(user)] has REMOVED a law from [key_name(borgo)]. LAW: [law]")
	message_admins("[key_name(user)] has REMOVED a law from [key_name(borgo)]. LAW: [law]")
	return TRUE

/datum/law_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!check_rights(R_ADMIN))
		qdel(src)
		return FALSE

	var/mob/living/silicon/borgo
	if(params["ref"])
		borgo = locate(params["ref"]) in GLOB.silicon_mobs
		if(QDELETED(borgo))
			to_chat(usr, span_danger("That cyborg is invalid."))
			return TRUE

	switch(action)
		if("lawchange_logs")
			ui.user?.client?.holder?.list_law_changes()
			return FALSE

		if("force_state_laws")
			borgo.statelaws()
			return FALSE

		if("announce_law_changes")
			borgo.show_laws()
			return FALSE

		if("laws_updated_alert")
			borgo.announce_law_change()
			return FALSE

		if("give_law_datum")
			borgo.make_laws()
			return TRUE

		if("add_law")
			. = add_law_helper(usr, borgo)

		if("remove_law")
			. = remove_law_helper(usr, borgo, params["lawtype"], params["law"])

		if("move_law")
			. = move_law_helper(usr, borgo, params["direction"], params["law"])

		if("edit_law_text")
			. = edit_law_text_helper(usr, borgo, params["lawtype"], params["law"])

	if(. && !QDELETED(borgo))
		// One of our functions successfully changed a law
		// If it was an AI with connected borgs, we should sync
		borgo.try_sync_laws()


/datum/law_panel/ui_data(mob/user)
	// Iterating over all silicons in existence every UI update is not exactly ideal,
	// but considering this is an admin only UI, I'm considering it okay purely for better UX.
	// If someone's copying this for player user or this becomes too laggy,
	// change this to static data and just add a refresh button.
	// You'll have to update static data every time the user changes a law though.
	var/list/data = list()

	var/list/all_silicons = list()
	for(var/mob/living/silicon/borgo as anything in GLOB.silicon_mobs)
		var/list/borg_information = list()

		if(iscyborg(borgo))
			var/mob/living/silicon/robot/cyborg = borgo
			if(cyborg.shell)
				continue

			borg_information["master_ai"] = cyborg.connected_ai?.real_name
			borg_information["borg_synced"] = cyborg.lawupdate
			borg_information["borg_type"] = "Cyborg"

		else if(isAI(borgo))
			borg_information["borg_type"] = "AI"

		else if(ispAI(borgo))
			borg_information["borg_type"] = "PAI"

		else
			borg_information["borg_type"] = "Unknown"

		borg_information["borg_name"] = borgo.real_name
		borg_information["ref"] = REF(borgo)

		var/datum/ai_laws/lawset = borgo.laws
		if(isnull(lawset))
			// Whoopsie something wrong wrong this isn't supposed to happen
			borg_information["laws"] = null

		else
			var/list/borg_laws = list()
			// zeroth law on top
			if(lawset.zeroth || lawset.zeroth_borg)
				UNTYPED_LIST_ADD(borg_laws, list("lawtype" = LAW_ZEROTH, "law" = lawset.zeroth || lawset.zeroth_borg, "num" = 0))
			// then goes hacked
			for(var/law in lawset.hacked)
				UNTYPED_LIST_ADD(borg_laws, list("lawtype" = LAW_HACKED, "law" = law, "num" = -1))
			// normie laws
			var/lawnum = 1
			for(var/law in lawset.inherent)
				UNTYPED_LIST_ADD(borg_laws, list("lawtype" = LAW_INHERENT, "law" = law, "num" = lawnum))
				lawnum += 1
			for(var/law in lawset.supplied)
				if(law) // Supplied is full of a bunch of empties
					UNTYPED_LIST_ADD(borg_laws, list("lawtype" = LAW_SUPPLIED, "law" = law, "num" = lawnum))
				lawnum += 1

			borg_information["laws"] = borg_laws

		UNTYPED_LIST_ADD(all_silicons, borg_information)

	data["all_silicons"] = all_silicons
	return data
