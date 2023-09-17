/datum/computer_file/program/ai_restorer
	filename = "ai_restore"
	filedesc = "AI Manager & Restorer"
	category = PROGRAM_CATEGORY_SCI
	program_icon_state = "generic"
	extended_desc = "Firmware Restoration Kit, capable of reconstructing damaged AI systems. Requires direct AI connection via intellicard slot."
	size = 12
	requires_ntnet = FALSE
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP
	transfer_access = list(ACCESS_RD)
	available_on_ntnet = TRUE
	tgui_id = "NtosAiRestorer"
	program_icon = "laptop-code"

	/// The AI stored in the program
	var/obj/item/aicard/stored_card
	/// Variable dictating if we are in the process of restoring the AI in the inserted intellicard
	var/restoring = FALSE

/datum/computer_file/program/ai_restorer/on_examine(obj/item/modular_computer/source, mob/user)
	var/list/examine_text = list()
	if(!stored_card)
		examine_text += "It has a slot installed for an intelliCard."
		return examine_text

	if(computer.Adjacent(user))
		examine_text += "It has a slot installed for an intelliCard which contains: [stored_card.name]"
	else
		examine_text += "It has a slot installed for an intelliCard, which appears to be occupied."
	examine_text += span_info("Alt-click to eject the intelliCard.")
	return examine_text

/datum/computer_file/program/ai_restorer/kill_program(mob/user)
	try_eject(forced = TRUE)
	return ..()

/datum/computer_file/program/ai_restorer/process_tick(seconds_per_tick)
	. = ..()
	if(!restoring) //Put the check here so we don't check for an ai all the time
		return

	var/mob/living/silicon/ai/A = stored_card.AI
	if(stored_card.flush)
		restoring = FALSE
		return
	A.adjustOxyLoss(-5, FALSE)
	A.adjustFireLoss(-5, FALSE)
	A.adjustBruteLoss(-5, FALSE)

	// Please don't forget to update health, otherwise the below if statements will probably always fail.
	A.updatehealth()
	if(A.health >= 0 && A.stat == DEAD)
		A.revive()
		stored_card.update_appearance()

	// Finished restoring
	if(A.health >= 100)
		restoring = FALSE

	return TRUE

/datum/computer_file/program/ai_restorer/application_attackby(obj/item/attacking_item, mob/living/user)
	if(!computer)
		return FALSE
	if(!istype(attacking_item, /obj/item/aicard))
		return FALSE

	if(stored_card)
		to_chat(user, span_warning("You try to insert \the [attacking_item] into \the [computer.name], but the slot is occupied."))
		return FALSE
	if(user && !user.transferItemToLoc(attacking_item, computer))
		return FALSE

	stored_card = attacking_item
	to_chat(user, span_notice("You insert \the [attacking_item] into \the [computer.name]."))

	return TRUE

/datum/computer_file/program/ai_restorer/try_eject(mob/living/user, forced = FALSE)
	if(!stored_card)
		if(user)
			to_chat(user, span_warning("There is no card in \the [computer.name]."))
		return FALSE

	if(restoring && !forced)
		if(user)
			to_chat(user, span_warning("Safeties prevent you from removing the card until reconstruction is complete..."))
		return FALSE

	if(user && computer.Adjacent(user))
		to_chat(user, span_notice("You remove [stored_card] from [computer.name]."))
		user.put_in_hands(stored_card)
	else
		stored_card.forceMove(computer.drop_location())

	stored_card = null
	restoring = FALSE
	return TRUE


/datum/computer_file/program/ai_restorer/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	switch(action)
		if("PRG_beginReconstruction")
			if(!stored_card || !stored_card.AI)
				return FALSE
			var/mob/living/silicon/ai/A = stored_card.AI
			if(A && A.health < 100)
				restoring = TRUE
				A.notify_ghost_cloning("Your core files are being restored!", source = computer)
			return TRUE
		if("PRG_eject")
			if(stored_card)
				try_eject(usr)
				return TRUE

/datum/computer_file/program/ai_restorer/ui_data(mob/user)
	var/list/data = list()

	data["ejectable"] = TRUE
	data["AI_present"] = !!stored_card?.AI
	data["error"] = null

	if(!stored_card)
		data["error"] = "Please insert an intelliCard."
	else if(!stored_card.AI)
		data["error"] = "No AI located..."
	else if(stored_card.flush)
		data["error"] = "Flush in progress!"
	else
		data["name"] = stored_card.AI.name
		data["restoring"] = restoring
		data["health"] = (stored_card.AI.health + 100) / 2
		data["isDead"] = stored_card.AI.stat == DEAD
		data["laws"] = stored_card.AI.laws.get_law_list(include_zeroth = TRUE, render_html = FALSE)

	return data
