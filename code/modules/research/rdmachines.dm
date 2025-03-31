
//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.


/obj/machinery/rnd
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = TRUE
	use_power = IDLE_POWER_USE

	///Are we currently printing a machine
	var/busy = FALSE
	///Is this machne hacked via wires
	var/hacked = FALSE
	///Is this machine disabled via wires
	var/disabled = FALSE
	///Ref to global science techweb.
	var/datum/techweb/stored_research
	///The item loaded inside the machine, used by experimentors and destructive analyzers only.
	var/obj/item/loaded_item

/obj/machinery/rnd/Initialize(mapload)
	. = ..()
	set_wires(new /datum/wires/rnd(src))
	register_context()

/obj/machinery/rnd/post_machine_initialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)
	if(stored_research)
		on_connected_techweb()

/obj/machinery/rnd/Destroy()
	if(stored_research)
		log_research("[src] disconnected from techweb [stored_research] (destroyed).")
		stored_research = null
	return ..()

/obj/machinery/rnd/examine(mob/user)
	. = ..()
	if(!in_range(user, src) && !isobserver(user))
		return

	. += span_notice("A [EXAMINE_HINT("multitool")] with techweb designs can be uploaded here.")
	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"].")
	if(panel_open)
		. += span_notice("Use a [EXAMINE_HINT("multitool")] or [EXAMINE_HINT("wirecutters")] to interact with wires.")
		. += span_notice("The machine can be [EXAMINE_HINT("pried")] apart.")

/obj/machinery/rnd/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		return

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
		context[SCREENTIP_CONTEXT_RMB] = "[panel_open ? "Close" : "Open"] Panel"
		return CONTEXTUAL_SCREENTIP_SET

	if(panel_open)
		var/msg
		if(held_item.tool_behaviour == TOOL_CROWBAR)
			msg = "Deconstruct"
		else if(is_wire_tool(held_item))
			msg = "Open Wires"

		if(msg)
			context[SCREENTIP_CONTEXT_LMB] = msg
			context[SCREENTIP_CONTEXT_RMB] = msg
			return CONTEXTUAL_SCREENTIP_SET
	else
		if(held_item.tool_behaviour == TOOL_MULTITOOL)
			var/obj/item/multitool/tool = held_item.get_proxy_attacker_for(src, user)
			if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
				context[SCREENTIP_CONTEXT_LMB] = "Upload Techweb"
				context[SCREENTIP_CONTEXT_RMB] = "Upload Techweb"
				return CONTEXTUAL_SCREENTIP_SET

///Called when attempting to connect the machine to a techweb, forgetting the old.
/obj/machinery/rnd/proc/connect_techweb(datum/techweb/new_techweb)
	if(stored_research)
		log_research("[src] disconnected from techweb [stored_research] when connected to [new_techweb].")
	stored_research = new_techweb
	if(!isnull(stored_research))
		on_connected_techweb()

///Called post-connection to a new techweb.
/obj/machinery/rnd/proc/on_connected_techweb()
	SHOULD_CALL_PARENT(FALSE)

///Reset the state of this machine
/obj/machinery/rnd/proc/reset_busy()
	busy = FALSE

/obj/machinery/rnd/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/rnd/crowbar_act_secondary(mob/living/user, obj/item/tool)
	return crowbar_act(user, tool)

/obj/machinery/rnd/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "[initial(icon_state)]_t", initial(icon_state), tool)

/obj/machinery/rnd/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	return screwdriver_act(user, tool)

/obj/machinery/rnd/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(panel_open)
		wires.interact(user)
		return ITEM_INTERACT_SUCCESS
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		connect_techweb(tool.buffer)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/rnd/multitool_act_secondary(mob/living/user, obj/item/tool)
	return multitool_act(user, tool)

/obj/machinery/rnd/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_BLOCKING
	if(panel_open)
		wires.interact(user)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/rnd/wirecutter_act_secondary(mob/living/user, obj/item/tool)
	return wirecutter_act(user, tool)

//whether the machine can have an item inserted in its current state.
/obj/machinery/rnd/proc/is_insertion_ready(mob/user)
	if(panel_open)
		balloon_alert(user, "panel open!")
		return FALSE
	if(disabled)
		balloon_alert(user, "belts disabled!")
		return FALSE
	if(busy)
		balloon_alert(user, "still busy!")
		return FALSE
	if(machine_stat & BROKEN)
		balloon_alert(user, "machine broken!")
		return FALSE
	if(machine_stat & NOPOWER)
		balloon_alert(user, "no power!")
		return FALSE
	if(loaded_item)
		balloon_alert(user, "item already loaded!")
		return FALSE
	return TRUE

//we eject the loaded item when deconstructing the machine
/obj/machinery/rnd/on_deconstruction(disassembled)
	if(loaded_item)
		loaded_item.forceMove(drop_location())
	..()
