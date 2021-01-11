/// How the condensation rate of the condenser scales with part rating
#define CONDENSER_RATE_BIN_SCALE 0.25

// Leaking:
/// The ratio of the condenser's current gas it will vent every second.
#define CONDENSER_VENT_RATIO	0.2
/// The base rate the condenser will leak reagents at when ruptured
#define CONDENSER_LEAK_BASE		1	// u/s
/// The scaling factor for leak rate relative to reagent volume
#define CONDENSER_LEAK_RATE		0.1	// u/u*s
/// The scaling factor for leak rate relative to vented gas
#define CONDENSER_LEAK_SCALE	0.1	// u/n*s
/// The ratio of vented gas to leaked reagents required to leak foam
#define LEAK_FOAM_THRESHOLD		2 * REAGENT_MOLE_DENSITY	// n/u
/// The ratio of vented gas to leaked reagents requires to produce spray
#define LEAK_SPRAY_THRESHOLD	10 * REAGENT_MOLE_DENSITY	// n/u

/**
 * # Gas Condenser
 *
 * Condenses gases in connected pipes into reagent form.
 */
/obj/machinery/atmospherics/components/unary/condenser
	name = "Gas Condenser"
	desc = "Condenses gases in connected pipes."
	icon = 'icons/obj/atmospherics/components/condenser.dmi'
	icon_state = "condenser"
	base_icon_state = "condenser"
	layer = OBJ_LAYER
	integrity_failure = 0.7	// Starts leaking at 70% integrity

	density = TRUE
	circuit = /obj/item/circuitboard/machine/condenser
	pipe_flags = PIPING_ONE_PER_TURF

	/// The rate of condensation in this condenser
	var/condensation_rate_multiplier = 0


/obj/machinery/atmospherics/components/unary/condenser/Initialize()
	. = ..()

	create_reagents(200)
	AddComponent(/datum/component/plumbing/simple_supply/north)

/obj/machinery/atmospherics/components/unary/condenser/on_construction(obj_color, set_layer)
	var/obj/item/circuitboard/machine/condenser/board = circuit
	if(board)
		piping_layer = board.piping_layer
		set_layer = piping_layer

	return ..()

/obj/machinery/atmospherics/components/unary/condenser/RefreshParts()
	. = ..()
	var/total_bin_rating = 0
	for(var/obj/item/stock_parts/matter_bin/bin in component_parts)
		total_bin_rating += bin.get_part_rating()

	condensation_rate_multiplier = total_bin_rating * CONDENSER_RATE_BIN_SCALE

/obj/machinery/atmospherics/components/unary/condenser/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][(machine_stat & BROKEN) ? "-b" : null][panel_open ? "-o" : null]"

/obj/machinery/atmospherics/components/unary/condenser/update_overlays()
	. = ..()
	. += getpipeimage(icon, "pipe", dir)


/obj/machinery/atmospherics/components/unary/condenser/attackby(obj/item/item, mob/user, params)
	var/base_icon = "[base_icon_state][(machine_stat & BROKEN) ? "-b" : null]"
	if(default_deconstruction_screwdriver(user, "[base_icon]-o", base_icon, item))
		return
	if(default_change_direction_wrench(user, item))
		return
	if(default_deconstruction_crowbar(item))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/condenser/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		if(src in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
			node.disconnect(src)
		nodes[1] = null
	if(parents[1])
		nullifyPipenet(parents[1])

	atmosinit()
	node = nodes[1]
	if(node)
		node.atmosinit()
		node.addMember(src)
	SSair.add_to_rebuild_queue(src)
	return TRUE



/obj/machinery/atmospherics/components/unary/condenser/process_atmos(delta_time)
	var/datum/gas_mixture/env = isturf(loc) ? loc.return_air() : null
	var/datum/gas_mixture/air = nodes[1] ? airs[1] : null
	if(!env && !air)
		return

	if(machine_stat & BROKEN)
		handle_venting(delta_time)

	handle_tolerance(delta_time)
	if(!QDELETED(src))
		air?.condense_gas_to(src, reagents, condensation_rate_multiplier * delta_time)
	return

/**
 * Handles the condenser venting gases and leaking reagents
 */
/obj/machinery/atmospherics/components/unary/condenser/proc/handle_venting(delta_time)
	var/turf/location = loc
	if(!istype(location))
		return

	var/vent_moles = 0
	var/datum/gas_mixture/air = nodes[1] ? airs[1] : null
	var/datum/gas_mixture/env = location.return_air()
	if(air && env)
		var/i_moles = env.total_moles()
		var/datum/gas_mixture/vented_gas = air.remove_ratio(DT_PROB_RATE(CONDENSER_VENT_RATIO, delta_time))
		vented_gas.release_gas_to(env, air.return_pressure())
		air.merge(vented_gas)
		vent_moles = env.total_moles() - i_moles
		if(vent_moles)
			location.air_update_turf()

	var/leak_vol = clamp(CONDENSER_LEAK_BASE + (CONDENSER_LEAK_RATE * reagents.total_volume) + (CONDENSER_LEAK_SCALE * vent_moles), 0, reagents.total_volume)
	if(!leak_vol)
		return

	if(vent_moles)
		switch(vent_moles / leak_vol)
			if(LEAK_FOAM_THRESHOLD to LEAK_SPRAY_THRESHOLD)
				if(DT_PROB(20, delta_time))
					visible_message(
						"<span class='danger'>[src] sprays a wave of foam!</span>",
						null,
						"<span class='danger'>You hear a rapid bubbling!</span>"
						)
					playsound(src, 'sound/effects/bubbles.ogg', 30, TRUE)

				var/datum/reagents/tmp_holder = new(1000)
				tmp_holder.my_atom = src
				reagents.trans_to(tmp_holder, leak_vol, methods=NONE)
				tmp_holder.create_foam(/datum/effect_system/foam_spread, rand(1, clamp(log(100, vent_moles+1), 1, 3)))
				qdel(tmp_holder)
				return

			if(LEAK_SPRAY_THRESHOLD to INFINITY)
				if(DT_PROB(20, delta_time))
					visible_message(
						"<span class='danger'>[src] sprays liquid from a rupture!</span>",
						null,
						"<span class='danger'>You hear a violent hissing!</span>"
						)
					playsound(src, 'sound/effects/spray.ogg', 30, TRUE)

				var/datum/reagents/tmp_holder = new(1000)
				reagents.trans_to(tmp_holder, leak_vol, methods=NONE)
				var/turf/target_turf = pick(oview(src, clamp(log(10, vent_moles+1), 0, 5)))
				var/list/spray_turfs = getline(src, target_turf)
				var/num_target_turfs = length(spray_turfs)
				if(!num_target_turfs)
					return

				var/reagent_multiplier = 1 / num_target_turfs
				for(var/i in 1 to num_target_turfs)
					var/turf/target = spray_turfs[i]
					tmp_holder.expose(target, volume_modifier = reagent_multiplier)
					for(var/atom/movable/movable_target in target)
						tmp_holder.expose(movable_target, volume_modifier = reagent_multiplier)

					if(i < num_target_turfs && !(spray_turfs[i+1] in target.atmos_adjacent_turfs))
						break
				return

	if(DT_PROB(20, delta_time))
		visible_message(
			"<span class='danger'>[src] dribbles some liquid onto the floor.</span>",
			null,
			"<span class='danger'>You hear a quiet sputtering.</span>"
		)
		playsound(src, 'sound/effects/bubbles.ogg', 10, TRUE)

	var/leak_ratio = clamp(leak_vol / reagents.total_volume, 0, 1)
	reagents.expose(location, leak_ratio)
	for(var/target in location)
		reagents.expose(target, leak_ratio)
	reagents.remove_all(leak_vol)

/**
 * Handles the condenser reacting to internal-external temperatures and pressure differences
 */
/obj/machinery/atmospherics/components/unary/condenser/proc/handle_tolerance(delta_time)
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/env = location?.return_air()
	var/datum/gas_mixture/air = nodes[1] ? airs[1] : null
	if(!env && !air)
		return

	var/high_temperature = max(env?.return_temperature(), air?.return_temperature())
	if(high_temperature > TANK_MELT_TEMPERATURE)
		take_damage(delta_time * max_integrity * sqrt((high_temperature - TANK_MELT_TEMPERATURE) / TANK_MELT_TEMPERATURE), BURN, FIRE, FALSE)
		if(DT_PROB(50, delta_time))
			visible_message("<span class='danger'>[src] warps under the heat!</span>")
			playsound(src, 'sound/items/welder.ogg', 20, TRUE)

	if(QDELETED(src))
		return

	var/pressure_delta = air?.return_pressure() - env?.return_pressure()
	if(abs(pressure_delta) > TANK_LEAK_PRESSURE)
		take_damage(delta_time * sqrt((abs(pressure_delta - TANK_LEAK_PRESSURE) / TANK_FRAGMENT_SCALE)), BRUTE, BOMB, FALSE)
		if(DT_PROB(30, delta_time))
			visible_message("<span class='danger'>[src] [pressure_delta > 0 ? "bulges" : "crumples"] under the pressure!")
			playsound(location, pick('sound/effects/creak1.ogg', 'sound/effects/creak2.ogg', 'sound/effects/creak3.ogg'), 20, TRUE)


/obj/machinery/atmospherics/components/unary/condenser/obj_break()
	. = ..()
	if(!.)
		return
	visible_message(
		"<span class='danger'>[src] ruptures and begin to spray gas!</span>",
		null,
		"<span class='danger'>You hear a loud bang followed by hissing!</span>"
	)
	playsound(get_turf(src), 'sound/effects/bang.ogg', 50)

/obj/machinery/atmospherics/components/unary/condenser/on_deconstruction()
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/env = location?.return_air()
	var/datum/gas_mixture/air = nodes[1] ? airs[1] : null
	var/pressure_delta = air?.return_pressure() - env?.return_pressure()

	var/datum/gas_mixture/vent_gas = air?.remove_ratio(1)
	if(length(vent_gas?.gases))
		location.assume_air(vent_gas)
		location.air_update_turf()

	switch(pressure_delta)
		if(-INFINITY to 1)
			reagents.expose(location)
			for(var/target in location)
				reagents.expose(target)
		if(1 to TANK_RUPTURE_PRESSURE)
			reagents.create_foam(/datum/effect_system/foam_spread, CEILING(2 * log(pressure_delta), 1))
		if(TANK_RUPTURE_PRESSURE to TANK_FRAGMENT_PRESSURE)
			var/range = LERP(1, 10, (pressure_delta - TANK_RUPTURE_PRESSURE) / (TANK_FRAGMENT_PRESSURE - TANK_RUPTURE_PRESSURE))
			var/effect_multiplier = 1 / range
			for(var/target in oview(src, range))
				reagents.expose(target, volume_modifier = effect_multiplier)
		if(TANK_FRAGMENT_PRESSURE to INFINITY)
			dyn_explosion(location, (pressure_delta - TANK_FRAGMENT_PRESSURE) / TANK_FRAGMENT_SCALE, 0, TRUE)
	return ..()




#undef CONDENSER_RATE_BIN_SCALE
#undef CONDENSER_VENT_RATIO
#undef CONDENSER_LEAK_BASE
#undef CONDENSER_LEAK_RATE
#undef CONDENSER_LEAK_SCALE
#undef LEAK_FOAM_THRESHOLD
#undef LEAK_SPRAY_THRESHOLD
