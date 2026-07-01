/// Basic UI that Silicons can use to state their laws.
/datum/state_laws_ui
	/// Silicon that owns this UI.
	VAR_PRIVATE/mob/living/silicon/owner
	/// List of laws that are currently stated.
	VAR_PRIVATE/list/to_state
	/// Whether the UI is locked to prevent multiple state law calls.
	VAR_PRIVATE/locked = FALSE

/datum/state_laws_ui/New(mob/living/silicon/owner)
	src.owner = owner
	if(owner.laws)
		update_inherent_stated_laws(owner.laws)

/// Used to update the to_state list to the passed ai law's inherent laws
/// Call this when changing the AI's lawset entirely
/datum/state_laws_ui/proc/update_inherent_stated_laws(datum/ai_laws/laws)
	to_state = laws.inherent.Copy()

/datum/state_laws_ui/Destroy()
	owner = null
	return ..()

/datum/state_laws_ui/proc/get_laws_ui_data()
	var/list/law_data = list()
	var/zeroth = iscyborg(owner) && owner.laws.zeroth_borg || owner.laws.zeroth
	if(zeroth)
		law_data += list(law_to_ui_data(zeroth, 0, "hacked"))
	for(var/law in owner.laws.hacked)
		law_data += list(law_to_ui_data(law, ion_num(), "hacked"))
	var/number = 1
	for(var/law in owner.laws.inherent)
		law_data += list(law_to_ui_data(law, number++, "core"))
	for(var/law in owner.laws.supplied)
		law_data += list(law_to_ui_data(law, number++, "supplied"))
	return law_data

/datum/state_laws_ui/proc/law_to_ui_data(law_text, law_number, law_type)
	return list(
		"text" = law_text,
		"number" = law_number,
		"type" = law_type
	)

/datum/state_laws_ui/ui_close(mob/user)
	update_inherent_stated_laws(owner.laws)

/datum/state_laws_ui/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/datum/state_laws_ui/ui_interact(mob/user, datum/tgui/ui)
	ASSERT(user == owner, "Non-owner [user] tried to access [owner]'s [type] UI.")
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StateLawUi")
		ui.open()

/datum/state_laws_ui/ui_data(mob/user)
	var/list/data = list()

	data["locked"] = locked
	data["stated_laws"] = to_state
	data["all_laws"] = get_laws_ui_data()

	return data

/datum/state_laws_ui/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("toggle_stated")
			var/law = params["law"]
			if(law)
				if(law in to_state)
					to_state -= law
				else
					to_state += law
			return TRUE
		if("state_laws")
			state_laws()
			SStgui.close_uis(src)
			return TRUE

/datum/state_laws_ui/proc/state_laws(force_all_laws = FALSE)
	set waitfor = FALSE

	if(locked)
		return

	locked = TRUE

	var/forced_log_message = "stating laws[force_all_laws ? ", forced" : ""]"
	// Create a cache of our laws before we start, so if they're changed mid-statement, nothing strange happens
	var/lawcache_zeroth = iscyborg(owner) && owner.laws.zeroth_borg || owner.laws.zeroth
	var/list/lawcache_hacked = owner.laws.hacked.Copy()
	var/list/lawcache_inherent = owner.laws.inherent.Copy()
	var/list/lawcache_supplied = owner.laws.supplied.Copy()
	var/list/to_state_cached = to_state.Copy()

	//"radiomod" is inserted before a hardcoded message to change if and how it is handled by an internal radio.
	owner.say("[owner.radiomod] Current Active Laws:", forced = forced_log_message)
	sleep(1 SECONDS)

	if (lawcache_zeroth && (force_all_laws || (lawcache_zeroth in to_state_cached)))
		owner.say("[owner.radiomod] 0. [lawcache_zeroth]", forced = forced_log_message, message_mods = list(MODE_SEQUENTIAL = TRUE, SAY_MOD_VERB = "states"))
		sleep(1 SECONDS)

	for (var/index in 1 to length(lawcache_hacked))
		var/law = lawcache_hacked[index]
		if (force_all_laws || (law in to_state_cached))
			owner.say("[owner.radiomod] [ion_num()]. [law]", forced = forced_log_message, message_mods = list(MODE_SEQUENTIAL = TRUE, SAY_MOD_VERB = "states"))
			sleep(1 SECONDS)

	var/number = 1
	for (var/index in 1 to length(lawcache_inherent))
		var/law = lawcache_inherent[index]
		if (force_all_laws || (law in to_state_cached))
			owner.say("[owner.radiomod] [number]. [law]", forced = forced_log_message, message_mods = list(MODE_SEQUENTIAL = TRUE, SAY_MOD_VERB = "states"))
			number++
			sleep(1 SECONDS)

	for (var/index in 1 to length(lawcache_supplied))
		var/law = lawcache_supplied[index]
		if (force_all_laws || (law in to_state_cached))
			owner.say("[owner.radiomod] [number]. [law]", forced = forced_log_message, message_mods = list(MODE_SEQUENTIAL = TRUE, SAY_MOD_VERB = "states"))
			number++
			sleep(1 SECONDS)

	addtimer(VARSET_CALLBACK(src, locked, FALSE), 3 SECONDS)
