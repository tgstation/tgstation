/obj/item/circuitboard/machine/mining_ltsrbt
	name = "Mining LTSRBT"
	icon_state = "bluespacearray"
	build_path = /obj/machinery/mining_ltsrbt
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stock_parts/subspace/ansible = 1,
		/obj/item/stock_parts/micro_laser = 1,
	)
	def_components = list(
		/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial,
	)

/**
 * Mining LTSRBT
 *
 * Recieves orders from the mining produce console
 * Uses power (scaling with parts) to get that item delivered
 * Only works if it's enabled, and can only be enabled on-station.
 */
/obj/machinery/mining_ltsrbt
	name = "mining LTSRBT"
	desc = "A variant of the Long-To-Short-Range-Bluespace-Transceiver used to deliver Mining equipment to the station as required. Nanotrasen denies the existence of any other forms of the LTSRBT."
	icon_state = "exonet_node"
	circuit = /obj/item/circuitboard/machine/mining_ltsrbt
	density = TRUE

	///Boolean on whether the machine is active or not
	var/enabled = FALSE
	///The amount of power each use of the machine costs.
	var/power_usage_per_teleport = 10000

/obj/machinery/mining_ltsrbt/Initialize(mapload)
	. = ..()
	GLOB.mining_ltsrbt += src
	register_context()

/obj/machinery/mining_ltsrbt/Destroy()
	GLOB.mining_ltsrbt -= src
	return ..()

/obj/machinery/mining_ltsrbt/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!held_item)
		context[SCREENTIP_CONTEXT_LMB] = "turn [enabled ? "off" : "on"]"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item.tool_behaviour == TOOL_CROWBAR && panel_open)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET
	return .

/obj/machinery/mining_ltsrbt/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!is_station_level(z))
		balloon_alert(user, "not on station!")
		user.playsound_local(loc, 'sound/machines/buzz-two.ogg', 30, TRUE)
		return
	enabled = !enabled
	balloon_alert(user, "turned [enabled ? "on" : "off"]")
	update_appearance(UPDATE_ICON)

/obj/machinery/mining_ltsrbt/update_icon_state()
	. = ..()
	icon_state = enabled ? initial(icon_state) : "[icon_state]_idle"

/obj/machinery/mining_ltsrbt/RefreshParts()
	. = ..()
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		power_usage_per_teleport = (initial(power_usage_per_teleport) % laser.rating)

/obj/machinery/mining_ltsrbt/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(enabled)
		enabled = FALSE
		update_appearance(UPDATE_ICON)
	default_deconstruction_screwdriver(user, icon_state, icon_state, tool)
	return TRUE

/obj/machinery/mining_ltsrbt/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	default_deconstruction_crowbar(tool)
	return TRUE

/**
 * # Recieve order
 *
 * Recieves the order and, if successfully goes through, returns TRUE
 * Otherwise will return FALSE to cancel the order.
 */
/obj/machinery/mining_ltsrbt/proc/recieve_order(datum/supply_order/order)
	if(!enabled)
		return FALSE
	order.generate(get_turf(src))
	use_power(power_usage_per_teleport)
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(5, 1, get_turf(src))
	sparks.attach(src)
	sparks.start()
	return TRUE
