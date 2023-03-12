
#define FLOODLIGHT_OFF 1
#define FLOODLIGHT_LOW 2
#define FLOODLIGHT_MED 3
#define FLOODLIGHT_HIGH 4

/obj/structure/floodlight_frame
	name = "floodlight frame"
	desc = "A bare metal frame looking vaguely like a floodlight. Requires wiring."
	max_integrity = 100
	icon = 'icons/obj/lighting.dmi'
	icon_state = "floodlight_c1"
	density = TRUE
	var/state = FLOODLIGHT_NEEDS_WIRES

/obj/structure/floodlight_frame/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/stack/cable_coil) && state == FLOODLIGHT_NEEDS_WIRES)
		var/obj/item/stack/S = O
		if(S.use(5))
			to_chat(user, span_notice("You wire [src]."))
			name = "wired [name]"
			desc = "A bare metal frame looking vaguely like a floodlight. Requires securing with a screwdriver."
			icon_state = "floodlight_c2"
			state = FLOODLIGHT_NEEDS_SECURING
			return
		else
			to_chat(user, "You need 5 cables to wire [src].")
			return
	if(O.tool_behaviour == TOOL_SCREWDRIVER && state == FLOODLIGHT_NEEDS_SECURING)
		to_chat(user, span_notice("You fasten the wiring and electronics in [src]."))
		name = "secured [name]"
		desc = "A bare metal frame that looks like a floodlight. Requires a light tube to complete."
		icon_state = "floodlight_c3"
		state = FLOODLIGHT_NEEDS_LIGHTS
		return
	if(istype(O, /obj/item/light/tube))
		var/obj/item/light/tube/L = O
		if(state == FLOODLIGHT_NEEDS_LIGHTS && L.status != 2) //Ready for a light tube, and not broken.
			to_chat(user, span_notice("You put lights in [src]."))
			new /obj/machinery/power/floodlight(loc)
			qdel(src)
			qdel(O)
			return
		else //A minute of silence for all the accidentally broken light tubes.
			return
	if(istype(O, /obj/item/lightreplacer))
		var/obj/item/lightreplacer/L = O
		if(state == FLOODLIGHT_NEEDS_LIGHTS && L.can_use(user))
			L.Use(user)
			to_chat(user, span_notice("You put lights in [src]."))
			new /obj/machinery/power/floodlight(loc)
			qdel(src)
			return
	..()

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
	/// List of power usage multipliers
	var/list/light_setting_list = list(0, 5, 10, 15)
	/// Constant coeff. for power usage
	var/light_power_coefficient = 200
	/// Intensity of the floodlight.
	var/setting = FLOODLIGHT_OFF

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
	set_light(light_setting_list[setting], light_power)
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

/obj/machinery/power/floodlight/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	change_setting(FLOODLIGHT_OFF)
	if(anchored)
		connect_to_network()
	else
		disconnect_from_network()
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/floodlight/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
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

/obj/machinery/power/floodlight/atom_break(damage_flag)
	. = ..()
	if(!.)
		return
	playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
	var/obj/structure/floodlight_frame/F = new(loc)
	F.state = FLOODLIGHT_NEEDS_LIGHTS
	new /obj/item/light/tube/broken(loc)
	qdel(src)

/obj/machinery/power/floodlight/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/effects/glasshit.ogg', 75, TRUE)
