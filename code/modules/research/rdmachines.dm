
//All devices that link into the R&D console fall into thise type for easy identification and some shared procs.


/obj/machinery/rnd
	name = "R&D Device"
	icon = 'icons/obj/machines/research.dmi'
	density = TRUE
	use_power = IDLE_POWER_USE
	var/busy = FALSE
	var/hacked = FALSE
	var/console_link = TRUE //allow console link.
	var/disabled = FALSE
	/// Ref to global science techweb.
	var/datum/techweb/stored_research
	///The item loaded inside the machine, used by experimentors and destructive analyzers only.
	var/obj/item/loaded_item

/obj/machinery/rnd/proc/reset_busy()
	busy = FALSE

/obj/machinery/rnd/Initialize(mapload)
	. = ..()
	set_wires(new /datum/wires/rnd(src))

/obj/machinery/rnd/LateInitialize()
	. = ..()
	if(!CONFIG_GET(flag/no_default_techweb_link) && !stored_research)
		CONNECT_TO_RND_SERVER_ROUNDSTART(stored_research, src)
	if(stored_research)
		on_connected_techweb()

/obj/machinery/rnd/Destroy()
	if(stored_research)
		log_research("[src] disconnected from techweb [stored_research] (destroyed).")
		stored_research = null
	QDEL_NULL(wires)
	return ..()

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

/obj/machinery/rnd/proc/shock(mob/user, prb)
	if(machine_stat & (BROKEN|NOPOWER)) // unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/rnd/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/rnd/crowbar_act_secondary(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool)

/obj/machinery/rnd/screwdriver_act(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "[initial(icon_state)]_t", initial(icon_state), tool)

/obj/machinery/rnd/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, "[initial(icon_state)]_t", initial(icon_state), tool)

/obj/machinery/rnd/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(panel_open)
		wires.interact(user)
		return TRUE
	if(!QDELETED(tool.buffer) && istype(tool.buffer, /datum/techweb))
		connect_techweb(tool.buffer)
		return TRUE
	return FALSE

/obj/machinery/rnd/multitool_act_secondary(mob/living/user, obj/item/tool)
	if(panel_open)
		wires.interact(user)
		return TRUE

/obj/machinery/rnd/wirecutter_act(mob/living/user, obj/item/tool)
	if(panel_open)
		wires.interact(user)
		return TRUE

/obj/machinery/rnd/wirecutter_act_secondary(mob/living/user, obj/item/tool)
	if(panel_open)
		wires.interact(user)
		return TRUE

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
/obj/machinery/rnd/on_deconstruction()
	if(loaded_item)
		loaded_item.forceMove(drop_location())
	..()

/obj/machinery/rnd/proc/AfterMaterialInsert(item_inserted, id_inserted, amount_inserted)
	var/stack_name
	if(istype(item_inserted, /obj/item/stack/ore/bluespace_crystal))
		stack_name = "bluespace"
		use_power(SHEET_MATERIAL_AMOUNT / 10)
	else
		var/obj/item/stack/S = item_inserted
		stack_name = S.name
		use_power(min(active_power_usage, (amount_inserted / 100)))
	add_overlay("protolathe_[stack_name]")
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, cut_overlay), "protolathe_[stack_name]"), 10)
