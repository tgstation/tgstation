#define NO_BOUND 3

/obj/machinery/atmospherics/components/unary/vent_pump
	icon_state = "vent_map-3"

	name = "air vent"
	desc = "Has a valve and pump attached to it."
	construction_type = /obj/item/pipe/directional/vent
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.15
	can_unwrench = TRUE
	welded = FALSE
	layer = GAS_SCRUBBER_LAYER
	hide = TRUE
	shift_underlay_only = FALSE
	pipe_state = "uvent"
	has_cap_visuals = TRUE
	vent_movement = VENTCRAWL_ALLOWED | VENTCRAWL_CAN_SEE | VENTCRAWL_ENTRANCE_ALLOWED
	// vents are more complex machinery and so are less resistant to damage
	max_integrity = 100
	interaction_flags_click = NEED_VENTCRAWL

	///Direction of pumping the gas (ATMOS_DIRECTION_RELEASING or ATMOS_DIRECTION_SIPHONING)
	var/pump_direction = ATMOS_DIRECTION_RELEASING
	///Should we check internal pressure, external pressure, both or none? (ATMOS_EXTERNAL_BOUND, ATMOS_INTERNAL_BOUND, NO_BOUND)
	var/pressure_checks = ATMOS_EXTERNAL_BOUND
	///The external pressure threshold (default 101 kPa)
	var/external_pressure_bound = ONE_ATMOSPHERE
	///The internal pressure threshold (default 0 kPa)
	var/internal_pressure_bound = 0
	// ATMOS_EXTERNAL_BOUND: Do not pass external_pressure_bound
	// ATMOS_INTERNAL_BOUND: Do not pass internal_pressure_bound
	// NO_BOUND: Do not pass either

	/// id of air sensor its connected to
	var/chamber_id

	///area this vent is assigned to
	var/area/assigned_area

	/// Is this vent currently overclocked, removing pressure limits but damaging the fan?
	var/fan_overclocked = FALSE

	/// Rate of damage per atmos process to the fan when overclocked. Set to 0 to disable damage.
	var/fan_damage_rate = 0.5

	/// The cached string we show for examine that lets you know how fucked up the fan is.
	var/examine_condition

	/// Datum for managing the overclock sound loop
	var/datum/looping_sound/vent_pump_overclock/sound_loop

/obj/machinery/atmospherics/components/unary/vent_pump/Initialize(mapload)
	if(!id_tag)
		id_tag = assign_random_name()
		var/static/list/tool_screentips
		if(!tool_screentips)
			tool_screentips = string_assoc_nested_list(list(
				TOOL_MULTITOOL = list(
					SCREENTIP_CONTEXT_LMB = "Log to link later with air sensor",
				),
				TOOL_SCREWDRIVER = list(
					SCREENTIP_CONTEXT_LMB = "Repair",
				),
			))
		AddElement(/datum/element/contextual_screentip_tools, tool_screentips)
	. = ..()
	sound_loop = new(src)
	assign_to_area()

/obj/machinery/atmospherics/components/unary/vent_pump/on_update_integrity(old_value, new_value)
	. = ..()
	var/condition_string
	switch(get_integrity_percentage())
		if(1)
			condition_string = "perfect"
		if(0.75 to 0.99)
			condition_string = "good"
		if(0.50 to 0.74)
			condition_string = "okay"
		if(0.25 to 0.49)
			condition_string = "bad"
		else
			condition_string = "terrible"
	examine_condition = "The fan is in [condition_string] condition."

/obj/machinery/atmospherics/components/unary/vent_pump/examine(mob/user)
	. = ..()
	. += span_notice("You can link it with an air sensor using a multitool.")

	if(fan_overclocked)
		. += span_warning("It is currently overclocked causing it to take damage over time.")

	if(get_integrity() > 0)
		. += span_notice(examine_condition)
	else
		. += span_warning("The fan is broken.")

/obj/machinery/atmospherics/components/unary/vent_pump/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	if(istype(multi_tool.buffer, /obj/machinery/air_sensor))
		var/obj/machinery/air_sensor/sensor = multi_tool.buffer
		multi_tool.set_buffer(src)
		sensor.multitool_act(user, multi_tool)
		return ITEM_INTERACT_SUCCESS

	balloon_alert(user, "vent saved in buffer")
	multi_tool.set_buffer(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/atmospherics/components/unary/vent_pump/screwdriver_act(mob/living/user, obj/item/tool)
	var/time_to_repair = (10 SECONDS) * (1 - get_integrity_percentage())
	if(!time_to_repair)
		return FALSE

	balloon_alert(user, "repairing vent...")
	if(do_after(user, time_to_repair, src))
		balloon_alert(user, "vent repaired")
		repair_damage(max_integrity)

	else
		balloon_alert(user, "interrupted!")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/atmospherics/components/unary/vent_pump/atom_fix()
	set_is_operational(TRUE)
	update_appearance(UPDATE_ICON)
	return ..()

/obj/machinery/atmospherics/components/unary/vent_pump/atom_break(damage_flag)
	set_is_operational(FALSE)
	update_appearance()
	return ..()

/obj/machinery/atmospherics/components/unary/vent_pump/Destroy()
	disconnect_from_area()
	QDEL_NULL(sound_loop)

	var/area/vent_area = get_area(src)
	if(vent_area)
		vent_area.air_vents -= src

	return ..()

/obj/machinery/atmospherics/components/unary/vent_pump/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	var/area/old_area = get_area(old_loc)
	var/area/new_area = get_area(src)

	if (old_area == new_area)
		return

	disconnect_from_area(old_area)
	assign_to_area(new_area)

/obj/machinery/atmospherics/components/unary/vent_pump/on_enter_area(datum/source, area/area_to_register)
	assign_to_area(area_to_register)
	. = ..()

/obj/machinery/atmospherics/components/unary/vent_pump/proc/assign_to_area(area/target_area = get_area(src))
	//this vent is already assigned to an area. Unassign it from here first before reassigning it to an new area
	if(isnull(target_area) || !isnull(assigned_area))
		return
	assigned_area = target_area
	assigned_area.air_vents += src
	update_appearance(UPDATE_NAME)

/obj/machinery/atmospherics/components/unary/vent_pump/proc/disconnect_from_area(area/target_area = get_area(src))
	//you cannot unassign from an area we never were assigned to
	if(isnull(target_area) || assigned_area != target_area)
		return
	assigned_area.air_vents -= src
	assigned_area = null

/obj/machinery/atmospherics/components/unary/vent_pump/on_exit_area(datum/source, area/area_to_unregister)
	. = ..()
	disconnect_from_area(area_to_unregister)

/obj/machinery/atmospherics/components/unary/vent_pump/update_overlays()
	. = ..()
	if(!powered())
		return

	if(get_integrity() <= 0)
		. += mutable_appearance(icon, "broken")

	else if(fan_overclocked)
		. += mutable_appearance(icon, "overclocked")

/obj/machinery/atmospherics/components/unary/vent_pump/update_icon_nopipes()
	cut_overlays()
	if(underfloor_state)
		var/image/cap = get_pipe_image(icon, "vent_cap", initialize_directions)
		add_overlay(cap)
	else
		PIPING_LAYER_SHIFT(src, PIPING_LAYER_DEFAULT)

	if(welded)
		icon_state = "vent_welded"
		return

	if(!nodes[1] || !on || !is_operational)
		if(icon_state == "vent_welded")
			icon_state = "vent_off"
			return

		if(pump_direction & ATMOS_DIRECTION_RELEASING)
			icon_state = "vent_off"
			flick("vent_out-shutdown", src)
		else // pump_direction == SIPHONING
			icon_state = "vent_off"
			flick("vent_in-shutdown", src)
		return

	if(icon_state == "vent_off")
		if(pump_direction & ATMOS_DIRECTION_RELEASING)
			icon_state = "vent_out"
			flick("vent_out-starting", src)
		else // pump_direction == SIPHONING
			icon_state = "vent_in"
			flick("vent_in-starting", src)
		return

	if(pump_direction & ATMOS_DIRECTION_RELEASING)
		icon_state = "vent_out"
	else // pump_direction == SIPHONING
		icon_state = "vent_in"

/obj/machinery/atmospherics/components/unary/vent_pump/proc/toggle_overclock(source, from_break = FALSE)
	fan_overclocked = !fan_overclocked

	if(from_break)
		playsound(src, 'sound/machines/fan/fan_break.ogg', 100)
		fan_overclocked = FALSE

	if(fan_overclocked)
		sound_loop.start()
	else
		sound_loop.stop()

	investigate_log("had its overlock setting [fan_overclocked ? "enabled" : "disabled"] by [source]", INVESTIGATE_ATMOS)

	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/components/unary/vent_pump/process_atmos()
	if(!is_operational)
		return
	if(!nodes[1])
		set_on(FALSE)
	if(!on || welded)
		return
	var/turf/open/us = loc
	if(!istype(us))
		return

	if(fan_overclocked)
		take_damage(fan_damage_rate, sound_effect=FALSE)
		if(get_integrity() == 0)
			investigate_log("was destroyed as a result of overclocking", INVESTIGATE_ATMOS)
			return

	var/percent_integrity = get_integrity_percentage()
	var/datum/gas_mixture/air_contents = airs[1]
	var/datum/gas_mixture/environment = us.return_air()
	var/environment_pressure = environment.return_pressure()

	if(pump_direction & ATMOS_DIRECTION_RELEASING) // internal -> external
		var/pressure_delta = 10000

		if(pressure_checks&ATMOS_EXTERNAL_BOUND)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
		if(pressure_checks&ATMOS_INTERNAL_BOUND)
			pressure_delta = min(pressure_delta, (air_contents.return_pressure() - internal_pressure_bound))

		if(pressure_delta > 0)
			if(air_contents.temperature > 0)
				if(!fan_overclocked && (environment_pressure >= 50 * ONE_ATMOSPHERE))
					return FALSE

				var/transfer_moles = (pressure_delta * environment.volume) / (air_contents.temperature * R_IDEAL_GAS_EQUATION)
				if(!fan_overclocked && (percent_integrity < 1))
					transfer_moles *= percent_integrity

				var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

				if(!removed || !removed.total_moles())
					return

				loc.assume_air(removed)
				update_parents()

	else // external -> internal
		var/pressure_delta = 10000
		if(pressure_checks&ATMOS_EXTERNAL_BOUND)
			pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))
		if(pressure_checks&ATMOS_INTERNAL_BOUND)
			pressure_delta = min(pressure_delta, (internal_pressure_bound - air_contents.return_pressure()))

		if(pressure_delta > 0 && environment.temperature > 0)
			if(!fan_overclocked && (air_contents.return_pressure() >= 50 * ONE_ATMOSPHERE))
				return FALSE

			var/transfer_moles = (pressure_delta * air_contents.volume) / (environment.temperature * R_IDEAL_GAS_EQUATION)
			if(!fan_overclocked && (percent_integrity < 1))
				transfer_moles *= percent_integrity

			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

			if(!removed || !removed.total_moles()) //No venting from space 4head
				return

			air_contents.merge(removed)
			update_parents()

/obj/machinery/atmospherics/components/unary/vent_pump/update_name()
	. = ..()
	if(override_naming)
		return
	name = "\proper [get_area_name(src)] [name] [id_tag]"

/obj/machinery/atmospherics/components/unary/vent_pump/welder_act(mob/living/user, obj/item/welder)
	..()
	if(!welder.tool_start_check(user, amount=1))
		return TRUE
	to_chat(user, span_notice("You begin welding the vent..."))
	if(welder.use_tool(src, user, 20, volume=50))
		if(!welded)
			user.visible_message(span_notice("[user] welds the vent shut."), span_notice("You weld the vent shut."), span_hear("You hear welding."))
			welded = TRUE
		else
			user.visible_message(span_notice("[user] unwelded the vent."), span_notice("You unweld the vent."), span_hear("You hear welding."))
			welded = FALSE
		update_appearance(UPDATE_ICON)
		pipe_vision_img = image(src, loc, dir = dir)
		SET_PLANE_EXPLICIT(pipe_vision_img, ABOVE_HUD_PLANE, src)
		investigate_log("was [welded ? "welded shut" : "unwelded"] by [key_name(user)]", INVESTIGATE_ATMOS)
		add_fingerprint(user)
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_pump/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE

/obj/machinery/atmospherics/components/unary/vent_pump/examine(mob/user)
	. = ..()
	if(welded)
		. += "It seems welded shut."

/obj/machinery/atmospherics/components/unary/vent_pump/power_change()
	. = ..()
	update_icon_nopipes()

/obj/machinery/atmospherics/components/unary/vent_pump/attack_alien(mob/user, list/modifiers)
	if(!welded || !(do_after(user, 2 SECONDS, target = src)))
		return
	user.visible_message(span_warning("[user] furiously claws at [src]!"), span_notice("You manage to clear away the stuff blocking the vent."), span_hear("You hear loud scraping noises."))
	welded = FALSE
	update_appearance(UPDATE_ICON)
	pipe_vision_img = image(src, loc, dir = dir)
	SET_PLANE_EXPLICIT(pipe_vision_img, ABOVE_HUD_PLANE, src)
	playsound(loc, 'sound/items/weapons/bladeslice.ogg', 100, TRUE)

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume
	name = "large air vent"
	power_channel = AREA_USAGE_EQUIP

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.volume = 1000

// mapping

/obj/machinery/atmospherics/components/unary/vent_pump/layer2
	piping_layer = 2
	icon_state = "vent_map-2"

/obj/machinery/atmospherics/components/unary/vent_pump/layer4
	piping_layer = 4
	icon_state = "vent_map-4"

/obj/machinery/atmospherics/components/unary/vent_pump/on
	on = TRUE
	icon_state = "vent_map_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/on/layer2
	piping_layer = 2
	icon_state = "vent_map_on-2"

/obj/machinery/atmospherics/components/unary/vent_pump/on/layer4
	piping_layer = 4
	icon_state = "vent_map_on-4"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon
	pump_direction = ATMOS_DIRECTION_SIPHONING
	pressure_checks = ATMOS_INTERNAL_BOUND
	internal_pressure_bound = 4000
	external_pressure_bound = 0

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/layer2
	piping_layer = 2
	icon_state = "vent_map-2"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/layer4
	piping_layer = 4
	icon_state = "vent_map-4"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on
	on = TRUE
	icon_state = "vent_map_siphon_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on/layer2
	piping_layer = 2
	icon_state = "vent_map_siphon_on-2"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/on/layer4
	piping_layer = 4
	icon_state = "vent_map_siphon_on-4"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/layer2
	piping_layer = 2
	icon_state = "vent_map-2"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/layer4
	piping_layer = 4
	icon_state = "vent_map-4"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/on
	on = TRUE
	icon_state = "vent_map_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/on/layer2
	piping_layer = 2
	icon_state = "vent_map_on-2"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/on/layer4
	piping_layer = 4
	icon_state = "vent_map_on-4"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon
	pump_direction = ATMOS_DIRECTION_SIPHONING
	pressure_checks = ATMOS_INTERNAL_BOUND
	internal_pressure_bound = 2000
	external_pressure_bound = 0

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/layer2
	piping_layer = 2
	icon_state = "vent_map-2"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/layer4
	piping_layer = 4
	icon_state = "vent_map-4"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/on
	on = TRUE
	icon_state = "vent_map_siphon_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/on/layer2
	piping_layer = 2
	icon_state = "vent_map_siphon_on-2"

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/on/layer4
	piping_layer = 4
	icon_state = "vent_map_siphon_on-4"

#undef NO_BOUND
