

/datum/computer_file/program/aidiag
	filename = "aidiag"
	filedesc = "AI Maintenance Utility"
	program_icon_state = "generic"
	extended_desc = "This program is capable of reconstructing damaged AI systems. Requires direct AI connection via intellicard slot."
	size = 12
	requires_ntnet = 0
	usage_flags = PROGRAM_CONSOLE
	transfer_access = access_heads
	available_on_ntnet = 1
	var/restoring = FALSE

/datum/computer_file/program/aidiag/proc/get_ai()

	var/obj/item/weapon/computer_hardware/ai_slot/ai_slot

	if(computer)
		ai_slot = computer.all_components[MC_AI]

	if(computer && ai_slot && ai_slot.check_functionality() && ai_slot.enabled && ai_slot.stored_card && ai_slot.stored_card.AI)
		return ai_slot.stored_card.AI
	return null

/datum/computer_file/program/aidiag/ui_act(action, params)
	if(..())
		return TRUE

	var/mob/living/silicon/ai/A = get_ai()
	if(!A)
		restoring = FALSE
		return FALSE

	switch("action")
		if("PRG_beginReconstruction")
			if(A.health < 100)
				restoring = TRUE
			return TRUE

/datum/computer_file/program/aidiag/process_tick()
	..()
	if(!restoring)	//Put the check here so we don't check for an ai all the time
		return

	var/mob/living/silicon/ai/A = get_ai()
	if(!A)
		restoring = FALSE	// If the AI was removed, stop the restoration sequence.
		return
	var/obj/item/device/aicard/cardhold = A.loc
	if(cardhold.flush)
		restoring = FALSE
		return
	A.adjustOxyLoss(-1, 0)
	A.adjustFireLoss(-1, 0)
	A.adjustToxLoss(-1, 0)
	A.adjustBruteLoss(-1, 0)
	A.updatehealth()
	if(A.health >= 0 && A.stat == DEAD)
		A.revive()
	// Finished restoring
	if(A.health >= 100)
		restoring = FALSE

	return TRUE


/datum/computer_file/program/aidiag/ui_data(mob/user)
	var/list/data = get_header_data()
	var/mob/living/silicon/ai/AI
	// A shortcut for getting the AI stored inside the computer. The program already does necessary checks.
	AI = get_ai()

	if(!AI)
		data["error"] = "No AI located"
	else
		var/obj/item/device/aicard/cardhold = AI.loc
		if(cardhold.flush)
			data["error"] = "Flush in progress"
		else
			data["name"] = AI.name
			data["restoring"] = restoring
			data["laws"] = AI.laws.get_law_list(include_zeroth = 1)
			data["health"] = (AI.health + 100) / 2
			data["isDead"] = AI.stat == DEAD
			data["ai_laws"] = AI.laws.get_law_list(include_zeroth = 1)

	return data

/datum/computer_file/program/aidiag/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ai_restorer", "Integrity Restorer", 600, 400, master_ui, state)
		ui.open()

datum/computer_file/program/aidiag/kill_program(forced)
	restoring = FALSE
	return ..(forced)