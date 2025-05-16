/obj/machinery/computer/modular_shield
	name = "modular shield control console"
	desc = "Used to remotely toggle shield generators."
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

/obj/machinery/modular_shield_generator/ui_interact(mob/user, datum/tgui/ui)
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
			if(generator.machine_stat & NOPOWER)
				this_generator["inactive"] = TRUE
			generator_list += list(this_generator)
		else
			generators -= get_generator(i)
	data["generators"] = generator_list
	data["selected_id"] = selected_id
	if(selected_id)
		var/obj/machinery/modular_shield_generator/current_generator = generators[selected_id]
		data["max_strength"] = current_generator.max_strength
		data["current_strength"] = current_generator.max_strength
		data["generator_name"] = current_generator.display_name
		data["active"] = current_generator.active
		data["selected_generator"] = current_generator
		data["recovering}"] = current_generator.recovering
	return data
/obj/machinery/computer/modular_shield/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/obj/machinery/modular_shield_generator/current_generator = generators[selected_id]
	switch(action)
		if("toggle_shields")
			current_generator.toggle_shields()
			. = TRUE
		if("select_generator")
			selected_id = text2num(params["id"])
			. = TRUE
	. = TRUE
