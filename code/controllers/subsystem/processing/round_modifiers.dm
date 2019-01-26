PROCESSING_SUBSYSTEM_DEF(round_modifiers)
	name = "Round Modifiers"
	init_order = INIT_ORDER_ROUND_MODIFIERS
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME

	var/list/modifiers = list()
	var/list/active_modifiers = list()

/datum/controller/subsystem/processing/round_modifiers/Initialize(timeofday)
	for(var/d in subtypesof(/datum/round_modifier))
		var/datum/round_modifier/d_type = d

		var/datum/round_modifier/D = new d_type
		if(D.name)
			modifiers += D
		else
			qdel(D)

	return ..()

/datum/controller/subsystem/processing/round_modifiers/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.admin_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "round_modifiers", name, 800, 600, master_ui, state)
		ui.open()

/datum/controller/subsystem/processing/round_modifiers/ui_data(mob/user)
	var/list/data = list()

	data["modifiers"] = list()

	for(var/datum/round_modifier/modifier in modifiers)
		var/list/L = list()
		L["name"] = modifier.name
		if(modifier in active_modifiers)
			L["active"] = TRUE
		else
			L["active"] = FALSE

		data["modifiers"] += list(L)

	return data

/datum/controller/subsystem/processing/round_modifiers/ui_act(action, params)
	if(..())
		return

	var/datum/round_modifier/modifier

	for(var/datum/round_modifier/M in modifiers)
		if(M.name == params["name"])
			modifier = M
			break

	switch(action)
		if("toggle")
			if(!modifier)
				to_chat(world, "<span class='warning'>Modifier not found: [name]</span>")
				return
			. = TRUE
			if(!(modifier in active_modifiers))
				active_modifiers += modifier
				modifier.on_apply()
				START_PROCESSING(SSround_modifiers, modifier)
			else
				active_modifiers -= modifier
				modifier.on_remove()
				STOP_PROCESSING(SSround_modifiers, modifier)
