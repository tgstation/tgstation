
#define FLOODLIGHT_OFF 1
#define FLOODLIGHT_LOW 2
#define FLOODLIGHT_MED 3
#define FLOODLIGHT_HIGH 4

/obj/structure/floodlight_frame
	name = "floodlight frame"
	desc = "A metal frame that requires wiring and a light tube to become a flood light."
	max_integrity = 100
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floodlight_c1"
	density = TRUE

	var/state = FLOODLIGHT_NEEDS_WIRES

/obj/structure/floodlight_frame/Initialize(mapload)
	. = ..()
	register_context()

/obj/structure/floodlight_frame/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user,
)

	if(isnull(held_item))
		return NONE

	var/message = null
	if(state == FLOODLIGHT_NEEDS_WIRES)
		if(istype(held_item, /obj/item/stack/cable_coil))
			message = "Add cable"
		else if(held_item.tool_behaviour == TOOL_WRENCH)
			message = "Dismantle frame"

	else if(state == FLOODLIGHT_NEEDS_SECURING)
		if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			message = "Secure cable"
		else if(held_item.tool_behaviour == TOOL_WIRECUTTER)
			message = "Cut cable"

	else if(state == FLOODLIGHT_NEEDS_LIGHTS)
		if(istype(held_item, /obj/item/light/tube))
			message = "Add light"
		else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			message = "Unscrew cable"

	if(isnull(message))
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = message
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/floodlight_frame/examine(mob/user)
	. = ..()
	if(state == FLOODLIGHT_NEEDS_WIRES)
		. += span_notice("It can be wired with [EXAMINE_HINT("5 cable pieces")].")
		. += span_notice("The frame can be deconstructed by [EXAMINE_HINT("unwrenching")].")
	else if(state == FLOODLIGHT_NEEDS_SECURING)
		. += span_notice("The cable needs to be [EXAMINE_HINT("screwed")] on to the frame.")
		. += span_notice("The hanging cable could be [EXAMINE_HINT("cut")] apart.")
	else if(state == FLOODLIGHT_NEEDS_LIGHTS)
		. += span_notice("It needs a [EXAMINE_HINT("light tube")] to finish it.")
		. += span_notice("The cable could be [EXAMINE_HINT("unscrewed")] from the frame.")

/obj/structure/floodlight_frame/screwdriver_act(mob/living/user, obj/item/O)
	. = ..()
	if(state == FLOODLIGHT_NEEDS_SECURING)
		icon_state = "floodlight_c3"
		state = FLOODLIGHT_NEEDS_LIGHTS
		return ITEM_INTERACT_SUCCESS
	else if(state == FLOODLIGHT_NEEDS_LIGHTS)
		icon_state = "floodlight_c2"
		state = FLOODLIGHT_NEEDS_SECURING
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/structure/floodlight_frame/wrench_act(mob/living/user, obj/item/tool)
	if(state != FLOODLIGHT_NEEDS_WIRES)
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "deconstructing...")
	if(!tool.use_tool(src, user, 30, volume=50))
		return ITEM_INTERACT_BLOCKING
	new /obj/item/stack/sheet/iron(loc, 5)
	qdel(src)

	return ITEM_INTERACT_SUCCESS

/obj/structure/floodlight_frame/wirecutter_act(mob/living/user, obj/item/tool)
	if(state != FLOODLIGHT_NEEDS_SECURING)
		return ITEM_INTERACT_BLOCKING

	icon_state = "floodlight_c1"
	state = FLOODLIGHT_NEEDS_WIRES
	new /obj/item/stack/cable_coil(loc, 5)

	return ITEM_INTERACT_SUCCESS

/obj/structure/floodlight_frame/attackby(obj/item/O, mob/user, list/modifiers)
	if(istype(O, /obj/item/stack/cable_coil) && state == FLOODLIGHT_NEEDS_WIRES)
		var/obj/item/stack/S = O
		if(S.use(5))
			icon_state = "floodlight_c2"
			state = FLOODLIGHT_NEEDS_SECURING
			return
		else
			balloon_alert(user, "need 5 cable pieces!")
			return

	if(istype(O, /obj/item/light/tube))
		if(state != FLOODLIGHT_NEEDS_LIGHTS)
			balloon_alert(user, "construction not completed!")
			return
		var/obj/item/light/tube/L = O
		if(L.status != LIGHT_BROKEN) // light tube not broken.
			new /obj/machinery/power/floodlight(loc)
			qdel(src)
			qdel(O)
			return
		else //A minute of silence for all the accidentally broken light tubes.
			balloon_alert(user, "light tube is broken!")
			return
	..()

/obj/structure/floodlight_frame/completed
	name = "floodlight frame"
	desc = "A bare metal frame that looks like a floodlight. Requires a light tube to complete."
	icon_state = "floodlight_c3"
	state = FLOODLIGHT_NEEDS_LIGHTS

/obj/machinery/power/floodlight
	name = "floodlight"
	desc = "A pole with powerful mounted lights on it. Due to its high power draw, it must be powered by a direct connection to a wire node."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floodlight"
	density = TRUE
	max_integrity = 100
	integrity_failure = 0.8
	idle_power_usage = 0
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	anchored = FALSE
	light_power = 1.75
	can_change_cable_layer = TRUE

	/// List of power usage multipliers
	var/list/light_setting_list = list(0, 5, 10, 15)
	/// Constant coeff. for power usage
	var/light_power_coefficient = 200
	/// Intensity of the floodlight.
	var/setting = FLOODLIGHT_OFF

/obj/machinery/power/floodlight/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_OBJ_PAINTED, TYPE_PROC_REF(/obj/machinery/power/floodlight, on_color_change))  //update light color when color changes
	register_context()

/obj/machinery/power/floodlight/proc/on_color_change(obj/machinery/power/flood_light, mob/user, obj/item/toy/crayon/spraycan/spraycan, is_dark_color)
	SIGNAL_HANDLER
	if(!spraycan.actually_paints)
		return

	if(setting > FLOODLIGHT_OFF)
		update_light_state()

/obj/machinery/power/floodlight/Destroy()
	UnregisterSignal(src, COMSIG_OBJ_PAINTED)
	. = ..()

/// change light color during operation
/obj/machinery/power/floodlight/proc/update_light_state()
	var/light_color =  NONSENSICAL_VALUE
	if(!isnull(color))
		light_color = color
	if (cached_color_filter)
		light_color = apply_matrix_to_color(COLOR_WHITE, cached_color_filter["color"], cached_color_filter["space"] || COLORSPACE_RGB)
	set_light(light_setting_list[setting], light_power, light_color)

/obj/machinery/power/floodlight/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user,
)

	if(isnull(held_item))
		if(panel_open)
			context[SCREENTIP_CONTEXT_LMB] = "Remove Light"
			return CONTEXTUAL_SCREENTIP_SET
		return NONE

	var/message = null
	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		message = "Open Panel"
	else if(held_item.tool_behaviour == TOOL_WRENCH)
		message = anchored ? "Unsecure light" : "Secure light"

	if(isnull(message))
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = message
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/power/floodlight/examine(mob/user)
	. = ..()
	if(!anchored)
		. += span_notice("It needs to be wrenched on top of a wire.")
	else
		. += span_notice("Its at power level [setting].")
	if(panel_open)
		. += span_notice("Its maintainence hatch is open but can be [EXAMINE_HINT("screwed")] close.")
		. += span_notice("You can remove the light tube by [EXAMINE_HINT("hand")].")
	else
		. += span_notice("Its maintainence hatch can be [EXAMINE_HINT("screwed")] open.")

/obj/machinery/power/floodlight/process()
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = locate() in T
	if(!C && powernet)
		disconnect_from_network()
	if(setting > FLOODLIGHT_OFF) //If on
		if(avail(active_power_usage))
			add_load(active_power_usage)
		else
			change_setting(FLOODLIGHT_OFF)
	else if(avail(idle_power_usage))
		add_load(idle_power_usage)

/obj/machinery/power/floodlight/proc/change_setting(newval, mob/user)
	if((newval < FLOODLIGHT_OFF) || (newval > light_setting_list.len))
		return

	setting = newval
	active_power_usage = light_setting_list[setting] * light_power_coefficient
	if(!avail(active_power_usage) && setting > FLOODLIGHT_OFF)
		return change_setting(setting - 1)
	update_light_state()
	var/setting_text = ""
	if(setting > FLOODLIGHT_OFF)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = initial(icon_state)
	switch(setting)
		if(FLOODLIGHT_OFF)
			setting_text = "OFF"
		if(FLOODLIGHT_LOW)
			setting_text = "low power"
		if(FLOODLIGHT_MED)
			setting_text = "standard lighting"
		if(FLOODLIGHT_HIGH)
			setting_text = "high power"
	if(user)
		to_chat(user, span_notice("You set [src] to [setting_text]."))

/obj/machinery/power/floodlight/cable_layer_act(mob/living/user, obj/item/tool)
	if(anchored)
		balloon_alert(user, "unanchor first!")
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/machinery/power/floodlight/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	change_setting(FLOODLIGHT_OFF)
	if(anchored)
		connect_to_network()
	else
		disconnect_from_network()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/power/floodlight/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	change_setting(FLOODLIGHT_OFF)
	panel_open = TRUE
	balloon_alert(user, "opened panel")
	return TRUE

/obj/machinery/power/floodlight/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(panel_open)
		var/obj/structure/floodlight_frame/floodlight_frame = new(loc)
		floodlight_frame.state = FLOODLIGHT_NEEDS_LIGHTS

		var/obj/item/light/tube/light_tube = new(loc)
		user.put_in_active_hand(light_tube)

		qdel(src)

	var/current = setting
	if(current == FLOODLIGHT_OFF)
		current = light_setting_list.len
	else
		current--
	change_setting(current, user)

/obj/machinery/power/floodlight/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/power/floodlight/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/power/floodlight/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	atom_break(ENERGY) // technically,
	return TRUE

/obj/machinery/power/floodlight/atom_break(damage_flag)
	. = ..()
	if(!.)
		return
	playsound(loc, 'sound/effects/glass/glassbr3.ogg', 100, TRUE)

	var/obj/structure/floodlight_frame/floodlight_frame = new(loc)
	floodlight_frame.state = FLOODLIGHT_NEEDS_LIGHTS
	var/obj/item/light/tube/our_light = new(loc)
	our_light.shatter()

	qdel(src)

/obj/machinery/power/floodlight/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/effects/glass/glasshit.ogg', 75, TRUE)

#undef FLOODLIGHT_OFF
#undef FLOODLIGHT_LOW
#undef FLOODLIGHT_MED
#undef FLOODLIGHT_HIGH
