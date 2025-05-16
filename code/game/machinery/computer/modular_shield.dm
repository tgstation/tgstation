/obj/machinery/computer/modular_shield
	name = "modular shield control console"
	desc = "Used to remotely monitor and toggle modular shield generators."
	circuit = /obj/item/circuitboard/computer/modular_shield_console

	var/selected_id
	var/list/obj/machinery/modular_shield_generator/generators

/obj/machinery/computer/modular_shield/Initialize(mapload)
	generators = list()
	. = ..()

//maybe let monkeys do a do_after to just spam buttons and toggle shields randomly?
/obj/machinery/computer/modular_shield/attack_paw(mob/user, list/modifiers)
	to_chat(user, span_warning("You are too primitive to use this computer!"))
	return

/obj/machinery/computer/modular_shield/multitool_act(mob/living/user, obj/item/multitool/tool)
	. = NONE
	if(!istype(tool.buffer, /obj/machinery/modular_shield_generator))
		return

	generators |= tool.buffer
	tool.set_buffer(null)
	to_chat(user, span_notice("You upload the data from the [tool] buffer."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/modular_shield/proc/generator_exists(number)
	var/obj/machinery/modular_shield_generator/generator = generators[number]
	if(QDELETED(generator))
		return FALSE
	return TRUE

/obj/machinery/computer/modular_shield/proc/get_generator(number)
	var/obj/machinery/modular_shield_generator/generator = generators[number]
	return generator

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
		if(generator_exists(i))
			var/obj/machinery/modular_shield_generator/generator = get_generator(i)
			var/list/this_generator = list()
			this_generator["name"] = generator.display_name
			this_generator["id"] = i
			this_generator["max_strength"] = generator.max_strength
			this_generator["current_strength"] = generator.stored_strength
			this_generator["generator_name"] = generator.display_name
			this_generator["active"] = generator.active
			this_generator["recovering"] = generator.recovering || generator.initiating
			if(generator.machine_stat & NOPOWER)
				this_generator["inactive"] = TRUE
			generator_list += list(this_generator)
		else
			generators -= get_generator(i)
	data["generators"] = generator_list
	return data
/obj/machinery/computer/modular_shield/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/obj/machinery/modular_shield_generator/selected_generator = get_generator(params["id"])
	switch(action)
		if("toggle_shields")
			selected_generator.toggle_shields()
			. = TRUE
		if("rename")
			selected_generator.display_name = params["name"]
			. = TRUE
	. = TRUE
