/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon = 'icons/obj/machines/floor.dmi'
	icon_state = "igniter0"
	base_icon_state = "igniter"
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	max_integrity = 300
	armor_type = /datum/armor/machinery_igniter
	resistance_flags = FIRE_PROOF
	processing_flags = NONE
	var/id = null
	var/on = FALSE

/obj/machinery/igniter/Initialize(mapload)
	. = ..()
	update_appearance()
	register_context()

/obj/machinery/igniter/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		return NONE

	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_MULTITOOL)
		context[SCREENTIP_CONTEXT_LMB] = "Connect [src]"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_WELDER)
		context[SCREENTIP_CONTEXT_LMB] = "Unweld"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/machinery/igniter/examine(mob/user)
	. = ..()
	. += span_notice("Use a [EXAMINE_HINT("multitool")] to set its ID to match your ignition controller's ID.")
	. += span_notice("It could be [EXAMINE_HINT("welded")] apart.")

/obj/machinery/igniter/welder_act(mob/living/user, obj/item/tool)
	if(on)
		return

	if(!tool.tool_start_check(user, amount = 2))
		balloon_alert(user, "not enough fuel!")
		return

	loc.balloon_alert(user, "dismantling [src]")
	if(!tool.use_tool(src, user, delay = 2.5 SECONDS, amount = 2, volume = 50))
		return
	loc.balloon_alert(user, "[src] dismantled")

	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/igniter/on_deconstruction(disassembled)
	new /obj/item/stack/sheet/iron(loc, 5)
	new /obj/item/assembly/igniter(loc)

/obj/machinery/igniter/multitool_act(mob/living/user, obj/item/tool)
	var/change_id = tgui_input_number(user, "Set the igniter controller's ID", "Igniter ID", id, 100)
	if(!change_id || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	id = change_id
	balloon_alert(user, "id set to [id]")
	to_chat(user, span_notice("You change the ID to [id]."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/igniter/incinerator_ordmix
	id = INCINERATOR_ORDMIX_IGNITER

/obj/machinery/igniter/incinerator_atmos
	id = INCINERATOR_ATMOS_IGNITER

/obj/machinery/igniter/incinerator_syndicatelava
	id = INCINERATOR_SYNDICATELAVA_IGNITER

/obj/machinery/igniter/on
	on = TRUE
	icon_state = "igniter1"

/datum/armor/machinery_igniter
	melee = 50
	bullet = 30
	laser = 70
	energy = 50
	bomb = 20
	fire = 100
	acid = 70

/// turns the igniter on/off
/obj/machinery/igniter/proc/toggle()
	on = !( on )
	if(on)
		begin_processing()
	else
		end_processing()
	update_appearance()

/obj/machinery/igniter/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	add_fingerprint(user)
	toggle()

/// Have to process to ignite any gas that comes in the turf
/obj/machinery/igniter/process()
	var/turf/location = loc
	if(!isturf(location) || !isopenturf(location)) //don't ignite stuff inside walls
		on = FALSE
	if(machine_stat & NOPOWER)
		on = FALSE
	if(!use_energy(active_power_usage, force = FALSE)) // Use energy to keep the turf hot. Doesn't necessarily use the correct amount of energy though (this should be changed).
		on = FALSE
	if(!on)
		update_appearance()
		return PROCESS_KILL

	location.hotspot_expose(1000, 500, 1)

/obj/machinery/igniter/update_icon_state()
	icon_state = "[base_icon_state][on]"
	return ..()

/obj/machinery/igniter/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	id = "[port.shuttle_id]_[id]"

// Wall mounted remote-control igniter.

/obj/item/wallframe/sparker
	name = "Sparker WallFrame"
	desc = "An unmounted sparker. Attach it to a wall to use."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "migniter"
	result_path = /obj/machinery/sparker
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	pixel_shift = 26

/obj/machinery/sparker
	name = "mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "migniter"
	base_icon_state = "migniter"
	resistance_flags = FIRE_PROOF
	var/id = null
	var/disable = 0
	var/last_spark = 0
	var/datum/effect_system/spark_spread/spark_system

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/sparker, 26)

/obj/machinery/sparker/ordmix
	id = INCINERATOR_ORDMIX_IGNITER

/obj/machinery/sparker/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(2, 1, src)
	spark_system.attach(src)
	register_context()
	find_and_hang_on_wall()

/obj/machinery/sparker/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/machinery/sparker/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_MULTITOOL)
		context[SCREENTIP_CONTEXT_LMB] = "Connect [src]"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_WELDER)
		context[SCREENTIP_CONTEXT_LMB] = "Unweld"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/machinery/sparker/examine(mob/user)
	. = ..()
	. += span_notice("Use a [EXAMINE_HINT("multitool")] to set its ID to match your ignition controller's ID.")
	. += span_notice("It could be [EXAMINE_HINT("welded")] apart.")

/obj/machinery/sparker/welder_act(mob/living/user, obj/item/tool)
	if(!tool.tool_start_check(user, amount = 1))
		balloon_alert(user, "not enough fuel!")
		return TRUE

	loc.balloon_alert(user, "dismantling [src]")
	if(!tool.use_tool(src, user, delay = 1.5 SECONDS, amount = 1, volume = 50))
		return
	loc.balloon_alert(user, "[src] dismantled")

	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/sparker/on_deconstruction(disassembled)
	new /obj/item/wallframe/sparker(loc)

/obj/machinery/sparker/multitool_act(mob/living/user, obj/item/tool)
	var/change_id = tgui_input_number(user, "Set the sparker controller's ID", "Sparker ID", id, 100)
	if(!change_id || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	id = change_id
	balloon_alert(user, "id set to [id]")
	to_chat(user, span_notice("You change the ID to [id]."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/sparker/update_icon_state()
	if(disable)
		icon_state = "[base_icon_state]-d"
		return ..()
	icon_state = "[base_icon_state][powered() ? null : "-p"]"
	return ..()

/obj/machinery/sparker/powered()
	if(disable)
		return FALSE
	return ..()

/obj/machinery/sparker/screwdriver_act(mob/living/user, obj/item/tool)
	add_fingerprint(user)
	tool.play_tool_sound(src, 50)
	disable = !disable
	if (disable)
		user.visible_message(span_notice("[user] disables \the [src]!"), span_notice("You disable the connection to \the [src]."))
	if (!disable)
		user.visible_message(span_notice("[user] reconnects \the [src]!"), span_notice("You fix the connection to \the [src]."))
	update_appearance()
	return TRUE

/obj/machinery/sparker/attack_ai()
	if (anchored)
		return ignite()
	else
		return

/obj/machinery/sparker/proc/ignite()
	if(!(powered()))
		return FALSE

	if((disable) || (last_spark && world.time < last_spark + 50))
		return FALSE

	var/turf/location = loc
	if(!isturf(location) || !isopenturf(location))
		return FALSE

	if(!use_energy(active_power_usage, force = FALSE))
		return FALSE

	flick("[initial(icon_state)]-spark", src)
	spark_system.start()
	last_spark = world.time
	location.hotspot_expose(1000, 2500, 1)

	return TRUE

/obj/machinery/sparker/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(machine_stat & (BROKEN|NOPOWER)))
		ignite()
