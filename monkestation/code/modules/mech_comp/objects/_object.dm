/obj/item/mcobject
	name = "mechcomp object"
	icon = 'goon/icons/obj/mechcomp.dmi'

	///Our interface for communicating with other mcobjects
	var/datum/mcinterface/interface
	///Configuration options
	var/list/configs
	///Inputs, basically pre-set acts. use MC_ADD_INPUT() to add.
	var/list/inputs

/obj/item/mcobject/Initialize(mapload)
	. = ..()
	interface = new(src)
	configs = list()
	inputs = list()
	update_icon_state()

	MC_ADD_CONFIG(MC_CFG_UNLINK_ALL, unlink_all)
	MC_ADD_CONFIG(MC_CFG_UNLINK, unlink)
	MC_ADD_CONFIG(MC_CFG_LINK, add_linker)

/obj/item/mcobject/Destroy(force)
	qdel(interface)
	return ..()

/obj/item/mcobject/update_icon_state()
	. = ..()
	icon_state = anchored ? "u[base_icon_state]" : base_icon_state

/obj/item/mcobject/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool))
		log_message("[anchored ? "wrenched down" : "unwrenched"] by [key_name(user)]", LOG_MECHCOMP)

/obj/item/mcobject/set_anchored(anchorvalue)
	. = ..()
	update_icon_state()
	if(!anchored)
		interface.ClearConnections()
	else
		pixel_x = base_pixel_x
		pixel_y = base_pixel_y

/obj/item/mcobject/attack_self_secondary(mob/user, modifiers)
	. = ..()
	var/datum/component/mclinker/link = src.GetComponent(/datum/component/mclinker)
	if(link)
		to_chat(user, span_warning("Link buffer cleared."))
		qdel(link)

/obj/item/mcobject/multitool_act(mob/living/user, obj/item/tool)
	var/datum/component/mclinker/link = tool.GetComponent(/datum/component/mclinker)
	if(link)
		if(!create_link(user, link.target))
			to_chat(user, span_warning("Unsucessful link buffer cleared."))
			qdel(link)
			return
		qdel(link)
		return

	var/action = tgui_input_list(user, "Select a config to modify", "Configure Component", configs)
	if(!action)
		return

	call(src, configs[action])(user, tool)

/obj/item/mcobject/proc/unlink(mob/user, obj/item/tool)
	var/list/options = list()

	for(var/datum/mcinterface/input in interface.inputs)
		var/input_name = interface.inputs[input]
		options["[input_name] ([input.owner])"] = input

	if(!length(options))
		to_chat(user, span_warning("There are no inputs being used!"))
		return FALSE

	var/remove = tgui_input_list(user, "Remove an input", "Configure Component", options)
	if(!remove)
		return

	interface.RemoveInput(options[remove])
	to_chat(user, span_notice("You clear [remove] from [src]."))
	return TRUE

///A multitool interaction is happening. Let's act on it.
/obj/item/mcobject/proc/unlink_all(mob/user, obj/item/tool)
	interface.ClearConnections()
	to_chat(user, span_notice("You remove all connections from [src]."))
	return TRUE

/obj/item/mcobject/proc/add_linker(mob/user, obj/item/tool)
	if(!tool)
		CRASH("Something tried to create a multitool linker without a multitool.")
	if(!anchored)
		to_chat(user, span_warning("You cannot link an unsecured device!"))
		return
	tool.AddComponent(/datum/component/mclinker, src)
	to_chat(user, span_notice("You prepare to link [src] with another device."))
	return TRUE

/obj/item/mcobject/proc/create_link(mob/user, obj/item/mcobject/target)
	SHOULD_CALL_PARENT(TRUE)

	if(!anchored)
		to_chat(user, span_warning("You cannot link an unsecured device!"))
		return

	if(src == target)
		to_chat(user, span_warning("You cannot link a device to itself!"))
		return

	if(get_dist(src, target) > MC_LINK_RANGE)
		to_chat(user, span_warning("Those devices are too far apart to be linked!"))
		return
	if(interface.inputs[target.interface])
		to_chat(user, span_warning("You cannot have multiple inputs taken by the same device!"))
		return

	var/list/options = inputs.Copy()

	for(var/thing in interface.inputs)
		options -= interface.inputs[thing]

	if(!length(options))
		to_chat(user, span_warning("[src] has no more inputs available!"))
		return

	var/choice = tgui_input_list(user, "Link Input", "Configure Component", options)
	if(!choice)
		return

	to_chat(user, span_notice("You link [target] to [src]."))
	interface.AddInput(target.interface, choice)
	target.linked_to(src, user)
	log_message("linked to [target] at [loc_name(src)] by [key_name(user)]", LOG_MECHCOMP)
	return TRUE

///Called by create_link.
/obj/item/mcobject/proc/linked_to(obj/item/mcobject/output, mob/user)
	return


/obj/item/mcobject/proc/flash()
	animate(src, color = "#00FF00", time = 2)
	animate(color = "#FFFFFF", time = 5, loop = 2)
