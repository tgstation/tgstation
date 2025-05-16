/obj/machinery/computer/modular_shield
	name = "modular shield control console"
	desc = "Used to remotely toggle shield generators."
	circuit = /obj/item/circuitboard/computer/modular_shield_console

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

