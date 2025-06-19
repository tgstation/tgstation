/obj/machinery/computer/modular_shield
	name = "modular shield control console"
	desc = "Used to remotely monitor and toggle modular shield generators."
	circuit = /obj/item/circuitboard/computer/modular_shield_console

	///the list of generators that are linked to us
	var/list/obj/machinery/modular_shield_generator/generators = list()

//lets monkeys randomly mash buttons to toggle the generators
/obj/machinery/computer/modular_shield/attack_paw(mob/user, list/modifiers)
	balloon_alert(user, "mashing buttons")
	if(!do_after(user, 4 SECONDS, target = src))
		return
	for(var/obj/machinery/modular_shield_generator/generator as anything in generators)
		if(prob(50))
			generator.toggle_shields()

/obj/machinery/computer/modular_shield/multitool_act(mob/living/user, obj/item/multitool/tool)
	. = NONE
	if(!istype(tool.buffer, /obj/machinery/modular_shield_generator))
		return

	generators |= tool.buffer
	RegisterSignal(tool.buffer, COMSIG_QDELETING, PROC_REF(generator_deleted))
	tool.set_buffer(null)
	to_chat(user, span_notice("You upload the data from the [tool] buffer."))
	return ITEM_INTERACT_SUCCESS

///checks if all connected generators exist
/obj/machinery/computer/modular_shield/proc/generator_deleted(obj/machinery/modular_shield_generator/generator)
	SIGNAL_HANDLER
	generators -= generator

/obj/machinery/computer/modular_shield/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ModularShieldConsole")
		ui.open()

/obj/machinery/computer/modular_shield/ui_data(mob/user)
	var/list/data = list()
	var/list/generator_list = list()
	for(var/i in 1 to LAZYLEN(generators))
		var/obj/machinery/modular_shield_generator/generator = generators[i]
		var/list/this_generator = list()
		this_generator["name"] = generator.display_name
		this_generator["id"] = i
		this_generator["max_strength"] = generator.max_strength
		this_generator["current_strength"] = generator.stored_strength
		this_generator["generator_name"] = generator.display_name
		this_generator["active"] = generator.active
		this_generator["recovering"] = generator.recovering || generator.initiating
		this_generator["current_regeneration"] = generator.current_regeneration
		if(generator.machine_stat & NOPOWER)
			this_generator["inactive"] = TRUE
		generator_list += list(this_generator)
	data["generators"] = generator_list
	return data

/obj/machinery/computer/modular_shield/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/obj/machinery/modular_shield_generator/selected_generator = generators[(params["id"])]
	if(QDELETED(selected_generator))
		return
	switch(action)
		if("toggle_shields")
			selected_generator.toggle_shields()
			return TRUE
		if("rename")
			selected_generator.display_name = params["name"]
			return TRUE
