/obj/machinery/atmospherics/components/unary/vent_scrubber
	icon_state = "scrub_map-3"

	name = "air scrubber"
	desc = "Has a valve and pump attached to it."
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.1
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.15
	can_unwrench = TRUE
	welded = FALSE
	layer = GAS_SCRUBBER_LAYER
	hide = TRUE
	shift_underlay_only = FALSE
	pipe_state = "scrubber"
	has_cap_visuals = TRUE
	vent_movement = VENTCRAWL_ALLOWED | VENTCRAWL_CAN_SEE | VENTCRAWL_ENTRANCE_ALLOWED
	processing_flags = NONE
	interaction_flags_click = NEED_VENTCRAWL

	///The mode of the scrubber (ATMOS_DIRECTION_SCRUBBING or ATMOS_DIRECTION_SIPHONING)
	var/scrubbing = ATMOS_DIRECTION_SCRUBBING
	///The list of gases we are filtering
	var/list/filter_types = list(/datum/gas/carbon_dioxide)
	///Rate of the scrubber to remove gases from the air
	var/volume_rate = 200
	///is this scrubber acting on the 3x3 area around it.
	var/widenet = FALSE
	///List of the turfs near the scrubber, used for widenet
	var/list/turf/adjacent_turfs = list()
	///The area this scrubber is assigned to
	var/area/assigned_area

	COOLDOWN_DECLARE(check_turfs_cooldown)

/obj/machinery/atmospherics/components/unary/vent_scrubber/Initialize(mapload)
	if(!id_tag)
		id_tag = assign_random_name()
	. = ..()

	for(var/to_filter in filter_types)
		if(istext(to_filter))
			filter_types -= to_filter
			filter_types += gas_id2path(to_filter)

	assign_to_area()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/machinery/atmospherics/components/unary/vent_scrubber/Destroy()
	disconnect_from_area()
	adjacent_turfs.Cut()
	return ..()

/obj/machinery/atmospherics/components/unary/vent_scrubber/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	var/area/old_area = get_area(old_loc)
	var/area/new_area = get_area(src)

	if (old_area == new_area)
		return

	disconnect_from_area(old_area)
	assign_to_area(new_area)

/obj/machinery/atmospherics/components/unary/vent_scrubber/on_enter_area(datum/source, area/area_to_register)
	assign_to_area(area_to_register)
	. = ..()

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/assign_to_area(area/target_area = get_area(src))
	//this scrubber is already assigned to an area. Unassign it from here first before reassigning it to an new area
	if(isnull(target_area) || !isnull(assigned_area))
		return
	assigned_area = target_area
	assigned_area.air_scrubbers += src
	update_appearance(UPDATE_NAME)

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/disconnect_from_area(area/target_area = get_area(src))
	//you cannot unassign from an area we never were assigned to
	if(isnull(target_area) || assigned_area != target_area)
		return
	assigned_area.air_scrubbers -= src
	assigned_area = null

/obj/machinery/atmospherics/components/unary/vent_scrubber/on_exit_area(datum/source, area/area_to_unregister)
	. = ..()
	disconnect_from_area(area_to_unregister)

///remove a gas or list of gases from our filter_types.used so that the scrubber can check if its supposed to be processing after each change
/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/remove_filters(filter_or_filters)
	if(!islist(filter_or_filters))
		filter_or_filters = list(filter_or_filters)

	for(var/gas_to_filter in filter_or_filters)
		var/translated_gas = istext(gas_to_filter) ? gas_id2path(gas_to_filter) : gas_to_filter

		if(ispath(translated_gas, /datum/gas))
			filter_types -= translated_gas
			continue

	atmos_conditions_changed()
	return TRUE

// WARNING: This proc takes untrusted user input from toggle_filter in air alarm's ui_act
/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/toggle_filters(filter_or_filters)
	if(!islist(filter_or_filters))
		filter_or_filters = list(filter_or_filters)

	for(var/gas_to_filter in filter_or_filters)
		var/translated_gas = istext(gas_to_filter) ? gas_id2path(gas_to_filter) : gas_to_filter

		if(ispath(translated_gas, /datum/gas))
			if(translated_gas in filter_types)
				filter_types -= translated_gas
			else
				filter_types |= translated_gas

	atmos_conditions_changed()
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/update_icon_nopipes()
	cut_overlays()
	if(showpipe)
		var/image/cap = get_pipe_image(icon, "scrub_cap", initialize_directions)
		add_overlay(cap)
	else
		PIPING_LAYER_SHIFT(src, PIPING_LAYER_DEFAULT)

	if(welded)
		icon_state = "scrub_welded"
		return

	if(!nodes[1] || !on || !is_operational)
		icon_state = "scrub_off"
		return

	if(scrubbing == ATMOS_DIRECTION_SCRUBBING)
		if(widenet)
			icon_state = "scrub_wide"
		else
			icon_state = "scrub_on"
	else //scrubbing == SIPHONING
		icon_state = "scrub_purge"

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/update_power_usage()
	idle_power_usage = initial(idle_power_usage)
	active_power_usage = initial(idle_power_usage)

	var/new_power_usage = 0
	if(scrubbing == ATMOS_DIRECTION_SCRUBBING)
		new_power_usage = idle_power_usage + idle_power_usage * length(filter_types)
		update_use_power(IDLE_POWER_USE)
	else
		new_power_usage = active_power_usage
		update_use_power(ACTIVE_POWER_USE)

	if(widenet)
		new_power_usage += new_power_usage * (length(adjacent_turfs) * (length(adjacent_turfs) / 2))

	update_mode_power_usage(scrubbing == ATMOS_DIRECTION_SCRUBBING ? IDLE_POWER_USE : ACTIVE_POWER_USE, new_power_usage)

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/set_scrubbing(scrubbing, mob/user)
	if (src.scrubbing != scrubbing)
		investigate_log("was toggled to [scrubbing ? "scrubbing" : "siphon"] mode by [isnull(user) ? "the game" : key_name(user)]", INVESTIGATE_ATMOS)

	src.scrubbing = scrubbing
	atmos_conditions_changed()
	update_power_usage()
	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/set_widenet(widenet)
	src.widenet = widenet
	update_power_usage()
	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/components/unary/vent_scrubber/update_name()
	. = ..()
	if(override_naming)
		return
	name = "\proper [get_area_name(src)] [name] [id_tag]"

/obj/machinery/atmospherics/components/unary/vent_scrubber/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	if(welded || !is_operational)
		return FALSE
	if(!nodes[1] || !on || (!filter_types && scrubbing != ATMOS_DIRECTION_SIPHONING))
		on = FALSE
		return FALSE

	var/list/changed_gas = air.gases

	if(!changed_gas)
		return FALSE

	if(scrubbing == ATMOS_DIRECTION_SIPHONING || length(filter_types & changed_gas))
		return TRUE

	return FALSE

/obj/machinery/atmospherics/components/unary/vent_scrubber/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(welded || !is_operational)
		return FALSE
	if(!nodes[1] || !on)
		on = FALSE
		return FALSE
	var/turf/open/us = loc
	if(!istype(us))
		return
	scrub(us)
	if(widenet)
		if(COOLDOWN_FINISHED(src, check_turfs_cooldown))
			check_turfs()
			COOLDOWN_START(src, check_turfs_cooldown, 2 SECONDS)

		for(var/turf/tile in adjacent_turfs)
			scrub(tile)
	return TRUE

///filtered gases at or below this amount automatically get removed from the mix
#define MINIMUM_MOLES_TO_SCRUB (MOLAR_ACCURACY*100)

/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/scrub(turf/tile)
	if(!istype(tile))
		return FALSE
	var/datum/gas_mixture/environment = tile.return_air()
	var/datum/gas_mixture/air_contents = airs[1]
	var/list/env_gases = environment.gases

	if(air_contents.return_pressure() >= 50 * ONE_ATMOSPHERE)
		return FALSE

	if(scrubbing == ATMOS_DIRECTION_SCRUBBING)
		if(length(env_gases & filter_types))
			///contains all of the gas we're sucking out of the tile, gets put into our parent pipenet
			var/datum/gas_mixture/filtered_out = new
			var/list/filtered_gases = filtered_out.gases
			filtered_out.temperature = environment.temperature

			///maximum percentage of the turfs gas we can filter
			var/removal_ratio =  min(1, volume_rate / environment.volume)

			var/total_moles_to_remove = 0
			for(var/gas in filter_types & env_gases)
				total_moles_to_remove += env_gases[gas][MOLES]

			if(total_moles_to_remove == 0)//sometimes this gets non gc'd values
				environment.garbage_collect()
				return FALSE

			for(var/gas in filter_types & env_gases)
				filtered_out.add_gas(gas)
				//take this gases portion of removal_ratio of the turfs air, or all of that gas if less than or equal to MINIMUM_MOLES_TO_SCRUB
				var/transferred_moles = max(QUANTIZE(env_gases[gas][MOLES] * removal_ratio * (env_gases[gas][MOLES] / total_moles_to_remove)), min(MINIMUM_MOLES_TO_SCRUB, env_gases[gas][MOLES]))

				filtered_gases[gas][MOLES] = transferred_moles
				env_gases[gas][MOLES] -= transferred_moles

			environment.garbage_collect()

			//Remix the resulting gases
			air_contents.merge(filtered_out)
			update_parents()

	else //Just siphoning all air

		var/transfer_moles = environment.total_moles() * (volume_rate / environment.volume)

		var/datum/gas_mixture/removed = tile.remove_air(transfer_moles)

		air_contents.merge(removed)
		update_parents()

	return TRUE

#undef MINIMUM_MOLES_TO_SCRUB

///we populate a list of turfs with nonatmos-blocked cardinal turfs AND
/// diagonal turfs that can share atmos with *both* of the cardinal turfs
/obj/machinery/atmospherics/components/unary/vent_scrubber/proc/check_turfs()
	adjacent_turfs.Cut()
	var/turf/local_turf = get_turf(src)
	adjacent_turfs = local_turf.get_atmos_adjacent_turfs(alldir = TRUE)

/obj/machinery/atmospherics/components/unary/vent_scrubber/power_change()
	. = ..()
	update_icon_nopipes()

/obj/machinery/atmospherics/components/unary/vent_scrubber/welder_act(mob/living/user, obj/item/welder)
	..()
	if(!welder.tool_start_check(user, amount=1))
		return TRUE
	to_chat(user, span_notice("Now welding the scrubber."))
	if(welder.use_tool(src, user, 20, volume=50))
		if(!welded)
			user.visible_message(span_notice("[user] welds the scrubber shut."),span_notice("You weld the scrubber shut."), span_hear("You hear welding."))
			welded = TRUE
		else
			user.visible_message(span_notice("[user] unwelds the scrubber."), span_notice("You unweld the scrubber."), span_hear("You hear welding."))
			welded = FALSE
		update_appearance()
		pipe_vision_img = image(src, loc, dir = dir)
		SET_PLANE_EXPLICIT(pipe_vision_img, ABOVE_HUD_PLANE, src)
		investigate_log("was [welded ? "welded shut" : "unwelded"] by [key_name(user)]", INVESTIGATE_ATMOS)
		add_fingerprint(user)
	return TRUE

/obj/machinery/atmospherics/components/unary/vent_scrubber/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational)
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE

/obj/machinery/atmospherics/components/unary/vent_scrubber/examine(mob/user)
	. = ..()
	if(welded)
		. += "It seems welded shut."

/obj/machinery/atmospherics/components/unary/vent_scrubber/attack_alien(mob/user, list/modifiers)
	if(!welded || !(do_after(user, 2 SECONDS, target = src)))
		return
	user.visible_message(span_warning("[user] furiously claws at [src]!"), span_notice("You manage to clear away the stuff blocking the scrubber."), span_hear("You hear loud scraping noises."))
	welded = FALSE
	update_appearance()
	pipe_vision_img = image(src, loc, dir = dir)
	SET_PLANE_EXPLICIT(pipe_vision_img, ABOVE_HUD_PLANE, src)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 100, TRUE)


/obj/machinery/atmospherics/components/unary/vent_scrubber/layer2
	piping_layer = 2
	icon_state = "scrub_map-2"

/obj/machinery/atmospherics/components/unary/vent_scrubber/layer4
	piping_layer = 4
	icon_state = "scrub_map-4"

/obj/machinery/atmospherics/components/unary/vent_scrubber/on
	on = TRUE
	icon_state = "scrub_map_on-3"

/obj/machinery/atmospherics/components/unary/vent_scrubber/on/layer2
	piping_layer = 2
	icon_state = "scrub_map_on-2"

/obj/machinery/atmospherics/components/unary/vent_scrubber/on/layer4
	piping_layer = 4
	icon_state = "scrub_map_on-4"

/obj/machinery/atmospherics/components/unary/vent_scrubber/disconnect()
	..()
	on = FALSE
