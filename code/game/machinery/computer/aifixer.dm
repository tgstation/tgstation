/obj/machinery/computer/aifixer
	name = "\improper AI system integrity restorer"
	desc = "Used with intelliCards containing nonfunctional AIs to restore them to working order."
	req_access = list(ACCESS_CAPTAIN, ACCESS_ROBOTICS, ACCESS_COMMAND)
	circuit = /obj/item/circuitboard/computer/aifixer
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	/// Variable containing transferred AI
	var/mob/living/silicon/ai/occupier
	/// Variable dictating if we are in the process of restoring the occupier AI
	var/restoring = FALSE

/obj/machinery/computer/aifixer/screwdriver_act(mob/living/user, obj/item/I)
	if(occupier)
		if(machine_stat & (NOPOWER|BROKEN))
			to_chat(user, span_warning("The screws on [name]'s screen won't budge."))
		else
			to_chat(user, span_warning("The screws on [name]'s screen won't budge and it emits a warning beep."))
	else
		return ..()

/obj/machinery/computer/aifixer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiRestorer", name)
		ui.open()

/obj/machinery/computer/aifixer/ui_data(mob/user)
	var/list/data = list()

	data["ejectable"] = FALSE
	data["AI_present"] = FALSE
	data["error"] = null
	if(!occupier)
		data["error"] = "Please transfer an AI unit."
	else
		data["AI_present"] = TRUE
		data["name"] = occupier.name
		data["restoring"] = restoring
		data["health"] = (occupier.health + 100) / 2
		data["isDead"] = occupier.stat == DEAD
		data["laws"] = occupier.laws.get_law_list(include_zeroth = TRUE, render_html = FALSE)

	return data

/obj/machinery/computer/aifixer/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(!occupier)
		restoring = FALSE

	switch(action)
		if("PRG_beginReconstruction")
			if(occupier?.health < 100)
				to_chat(usr, span_notice("Reconstruction in progress. This will take several minutes."))
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 25, FALSE)
				restoring = TRUE
				occupier.notify_ghost_cloning("Your core files are being restored!", source = src)
				. = TRUE

/obj/machinery/computer/aifixer/proc/Fix()
	use_power(1000)
	occupier.adjustOxyLoss(-5, FALSE)
	occupier.adjustFireLoss(-5, FALSE)
	occupier.adjustBruteLoss(-5, FALSE)
	occupier.updatehealth()
	if(occupier.health >= 0 && occupier.stat == DEAD)
		occupier.revive(full_heal = FALSE, admin_revive = FALSE)
		if(!occupier.radio_enabled)
			occupier.radio_enabled = TRUE
			to_chat(occupier, span_warning("Your Subspace Transceiver has been enabled!"))
	return occupier.health < 100

/obj/machinery/computer/aifixer/process()
	if(..())
		if(restoring)
			var/oldstat = occupier.stat
			restoring = Fix()
			if(oldstat != occupier.stat)
				update_appearance()

/obj/machinery/computer/aifixer/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(restoring)
		. += "ai-fixer-on"

	if(!occupier)
		. += "ai-fixer-empty"
		return
	switch(occupier.stat)
		if(CONSCIOUS)
			. += "ai-fixer-full"
		if(UNCONSCIOUS, HARD_CRIT)
			. += "ai-fixer-404"

/obj/machinery/computer/aifixer/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return
	//Downloading AI from card to terminal.
	if(interaction == AI_TRANS_FROM_CARD)
		if(machine_stat & (NOPOWER|BROKEN))
			to_chat(user, span_alert("[src] is offline and cannot take an AI at this time."))
			return
		AI.forceMove(src)
		occupier = AI
		AI.control_disabled = TRUE
		AI.radio_enabled = FALSE
		to_chat(AI, span_alert("You have been uploaded to a stationary terminal. Sadly, there is no remote access from here."))
		to_chat(user, "[span_notice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
		card.AI = null
		update_appearance()

	else //Uploading AI from terminal to card
		if(occupier && !restoring)
			to_chat(occupier, span_notice("You have been downloaded to a mobile storage device. Still no remote access."))
			to_chat(user, "[span_notice("Transfer successful")]: [occupier.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.")
			occupier.forceMove(card)
			card.AI = occupier
			occupier = null
			update_appearance()
		else if (restoring)
			to_chat(user, span_alert("ERROR: Reconstruction in progress."))
		else if (!occupier)
			to_chat(user, span_alert("ERROR: Unable to locate artificial intelligence."))

/obj/machinery/computer/aifixer/Destroy()
	if(occupier)
		QDEL_NULL(occupier)
	return ..()

/obj/machinery/computer/aifixer/on_deconstruction()
	if(occupier)
		QDEL_NULL(occupier)
