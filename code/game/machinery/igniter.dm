/obj/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting plasma."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "igniter0"
	base_icon_state = "igniter"
	plane = FLOOR_PLANE
	max_integrity = 300
	armor_type = /datum/armor/machinery_igniter
	resistance_flags = FIRE_PROOF
	var/id = null
	var/on = FALSE

/obj/machinery/igniter/Initialize(mapload)
	. = ..()
	update_appearance()
	register_context()

/obj/machinery/igniter/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		return NONE

	var/tool_tip_set = FALSE

	if(held_item.tool_behaviour == TOOL_MULTITOOL)
		context[SCREENTIP_CONTEXT_LMB] = "Connect Igniter"
		tool_tip_set = TRUE

	else if(held_item.tool_behaviour == TOOL_WELDER)
		context[SCREENTIP_CONTEXT_LMB] = "Unweld"
		tool_tip_set = TRUE

	return tool_tip_set ? CONTEXTUAL_SCREENTIP_SET : NONE

/obj/machinery/igniter/examine(mob/user)
	. = ..()
	. += span_notice("Use multitool to set it's ID to match your ignition controller's ID.")
	. += span_notice("It could be [EXAMINE_HINT("welded")] apart.")

/obj/machinery/igniter/welder_act(mob/living/user, obj/item/tool)
	if(on)
		return

	if(!tool.tool_start_check(user, amount = 2))
		balloon_alert(user, "not enough fuel!")
		return

	user.visible_message(span_notice("[user] begins to dismantle [src]."),\
			span_notice("You start to unweld \the [src]..."))
	if(!tool.use_tool(src, user, delay = 2.5 SECONDS, amount = 2, volume = 50))
		return
	user.balloon_alert(user, "igniter dismantled")

	deconstruct(TRUE)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/igniter/deconstruct(disassembled)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 5)
		new /obj/item/assembly/igniter(loc)
	return ..()

/obj/machinery/igniter/multitool_act(mob/living/user, obj/item/tool)
	var/change_id = tgui_input_number(user, "Set the sparkers controllers ID", "Sparker ID", id, 100)
	if(!change_id || QDELETED(user) || QDELETED(src) || !usr.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	id = change_id
	balloon_alert(user, "id changed")
	to_chat(user, span_notice("You change the ID to [id]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

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

/obj/machinery/igniter/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	add_fingerprint(user)

	use_power(active_power_usage)
	on = !( on )
	update_appearance()

/// Have to process to ignite any gas that comes in the turf
/obj/machinery/igniter/process()
	if(!on)
		return 1

	var/turf/location = loc
	if(!isturf(location) || !isopenturf(location)) //don't ignite stuff inside walls
		on = FALSE
	if(machine_stat & NOPOWER)
		on = FALSE
	if(!on)
		update_appearance()
		return 1

	location.hotspot_expose(1000, 500, 1)
	use_power(active_power_usage) //use power to keep the turf hot
	return 1

/obj/machinery/igniter/update_icon_state()
	icon_state = "[base_icon_state][on]"
	return ..()

/obj/machinery/igniter/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	id = "[port.shuttle_id]_[id]"

// Wall mounted remote-control igniter.

/obj/item/wallframe/sparker
	name = "Sparker WallFrame"
	desc = "An unmounted sparker. Attach it to a wall to use."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "migniter"
	result_path = /obj/machinery/sparker
	pixel_shift = 26

/obj/machinery/sparker
	name = "mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/stationobjs.dmi'
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

/obj/machinery/sparker/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/machinery/sparker/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		return NONE

	var/tool_tip_set = FALSE

	if(held_item.tool_behaviour == TOOL_MULTITOOL)
		context[SCREENTIP_CONTEXT_LMB] = "Connect Sparker"
		tool_tip_set = TRUE

	else if(held_item.tool_behaviour == TOOL_WELDER)
		context[SCREENTIP_CONTEXT_LMB] = "Unweld"
		tool_tip_set = TRUE

	return tool_tip_set ? CONTEXTUAL_SCREENTIP_SET : NONE

/obj/machinery/sparker/examine(mob/user)
	. = ..()
	. += span_notice("Use multitool to set it's ID to match your ignition controller's ID.")
	. += span_notice("It could be [EXAMINE_HINT("welded")] apart.")

/obj/machinery/sparker/welder_act(mob/living/user, obj/item/tool)
	if(!tool.tool_start_check(user, amount = 1))
		balloon_alert(user, "not enough fuel!")
		return TRUE

	user.visible_message(span_notice("[user] begins to dismantle [src]."),\
			span_notice("You start to unweld \the [src]..."))
	if(!tool.use_tool(src, user, delay = 1.5 SECONDS, amount = 1, volume = 50))
		return
	user.balloon_alert(user, "sparker dismantled")

	deconstruct(TRUE)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/sparker/deconstruct(disassembled)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/wallframe/sparker(loc)
	return ..()

/obj/machinery/sparker/multitool_act(mob/living/user, obj/item/tool)
	var/change_id = tgui_input_number(user, "Set the sparkers controllers ID", "Sparker ID", id, 100)
	if(!change_id || QDELETED(user) || QDELETED(src) || !usr.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return
	id = change_id
	balloon_alert(user, "id changed")
	to_chat(user, span_notice("You change the ID to [id]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

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
	if (!(powered()))
		return

	if ((disable) || (last_spark && world.time < last_spark + 50))
		return

	flick("[initial(icon_state)]-spark", src)
	spark_system.start()
	last_spark = world.time
	use_power(active_power_usage)

	var/turf/location = loc
	if (isturf(location))
		location.hotspot_expose(1000, 2500, 1)
	return 1

/obj/machinery/sparker/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(!(machine_stat & (BROKEN|NOPOWER)))
		ignite()
