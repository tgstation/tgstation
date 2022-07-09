#define TANK_PLATING_SHEETS 12

/obj/machinery/atmospherics/components/tank
	icon = 'icons/obj/atmospherics/stationary_canisters.dmi'
	icon_state = "smooth"

	name = "pressure tank"
	desc = "A large vessel containing pressurized gas."

	max_integrity = 800
	integrity_failure = 0.2
	density = TRUE
	layer = ABOVE_WINDOW_LAYER

	custom_materials = list(/datum/material/iron = TANK_PLATING_SHEETS * MINERAL_MATERIAL_AMOUNT) // plasteel is not a material to prevent two bugs: one where the default pressure is 1.5 times higher as plasteel's material modifier is added, and a second one where the tank names could be "plasteel plasteel" tanks
	material_flags = MATERIAL_EFFECTS | MATERIAL_GREYSCALE | MATERIAL_ADD_PREFIX | MATERIAL_AFFECT_STATISTICS

	pipe_flags = PIPING_ONE_PER_TURF
	device_type = QUATERNARY
	initialize_directions = NONE
	custom_reconcilation = TRUE

	smoothing_flags = SMOOTH_CORNERS | SMOOTH_OBJ
	smoothing_groups = list(SMOOTH_GROUP_GAS_TANK)
	canSmoothWith = list(SMOOTH_GROUP_GAS_TANK)
	appearance_flags = KEEP_TOGETHER|LONG_GLIDE

	greyscale_config = /datum/greyscale_config/stationary_canister
	greyscale_colors = "#ffffff"

	///The image showing the gases inside of the tank
	var/image/window

	/// The volume of the gas mixture
	var/volume = 2500 //in liters
	/// The max pressure of the gas mixture before damaging the tank
	var/max_pressure = 46000
	/// The typepath of the gas this tank should be filled with.
	var/gas_type = null

	///Reference to the gas mix inside the tank
	var/datum/gas_mixture/air_contents

	/// The sounds that play when the tank is breaking from overpressure
	var/static/list/breaking_sounds = list(
		'sound/effects/structure_stress/pop1.ogg',
		'sound/effects/structure_stress/pop2.ogg',
		'sound/effects/structure_stress/pop3.ogg',
	)

	/// Shared images for the knob overlay representing a side of the tank that is open to connections
	var/static/list/knob_overlays

	/// Number of crack states to fill the list with. This exists because I'm lazy and didn't want to keeping adding more things manually to the below list.
	var/crack_states_count = 10
	/// The icon states for the cracks in the tank dmi
	var/static/list/crack_states

	/// The merger id used to create/get the merger group in charge of handling tanks that share an internal gas storage
	var/merger_id = "stationary_tanks"
	/// The typecache of types which are allowed to merge internal storage
	var/static/list/merger_typecache

/obj/machinery/atmospherics/components/tank/Initialize(mapload)
	. = ..()

	if(!knob_overlays)
		knob_overlays = list()
		for(var/dir in GLOB.cardinals)
			knob_overlays["[dir]"] = image('icons/obj/atmospherics/stationary_canisters.dmi', icon_state = "knob", dir = dir, layer = FLOAT_LAYER)

	if(!crack_states)
		crack_states = list()
		for(var/i in 1 to crack_states_count)
			crack_states += "crack[i]"

	if(!merger_typecache)
		merger_typecache = typecacheof(/obj/machinery/atmospherics/components/tank)

	AddComponent(/datum/component/gas_leaker, leak_rate = 0.05)
	AddElement(/datum/element/volatile_gas_storage)
	AddElement(/datum/element/crackable, 'icons/obj/atmospherics/stationary_canisters.dmi', crack_states)

	RegisterSignal(src, COMSIG_MERGER_ADDING, .proc/merger_adding)
	RegisterSignal(src, COMSIG_MERGER_REMOVING, .proc/merger_removing)
	RegisterSignal(src, COMSIG_ATOM_SMOOTHED_ICON, .proc/smoothed)

	air_contents = new
	air_contents.temperature = T20C
	air_contents.volume = volume
	refresh_pressure_limit()

	if(gas_type)
		fill_to_pressure(gas_type)

	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)

	// Mapped in tanks should automatically connect to adjacent pipenets in the direction set in dir
	if(mapload)
		initialize_directions = dir

	return INITIALIZE_HINT_LATELOAD

// We late initialize here so all stationary tanks have time to set up their
// initial gas mixes and signal registrations.
/obj/machinery/atmospherics/components/tank/LateInitialize()
	. = ..()
	GetMergeGroup(merger_id, merger_typecache)

/obj/machinery/atmospherics/components/tank/Destroy()
	QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/machinery/atmospherics/components/tank/examine(mob/user, thats)
	. = ..()
	var/wrench_hint = EXAMINE_HINT("wrench")
	if(!initialize_directions)
		. += span_notice("A pipe port can be opened with a [wrench_hint].")
	else
		. += span_notice("The pipe port can be moved or closed with a [wrench_hint].")
	. += span_notice("A holographic sticker on it says that its maximum safe pressure is: [siunit_pressure(max_pressure, 0)].")

/obj/machinery/atmospherics/components/tank/set_custom_materials(list/materials, multiplier)
	. = ..()
	refresh_pressure_limit()

/// Recalculates pressure based on the current max integrity compared to original
/obj/machinery/atmospherics/components/tank/proc/refresh_pressure_limit()
	var/max_pressure_multiplier = max_integrity / initial(max_integrity)
	max_pressure = max_pressure_multiplier * initial(max_pressure)

/// Fills the tank to the maximum safe pressure.
/// Safety margin is a multiplier for the cap for the purpose of this proc so it doesn't have to be filled completely.
/obj/machinery/atmospherics/components/tank/proc/fill_to_pressure(gastype, safety_margin = 0.5)
	var/pressure_limit = max_pressure * safety_margin

	var/moles_to_add = (pressure_limit * air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.assert_gas(gastype)
	air_contents.gases[gastype][MOLES] += moles_to_add
	air_contents.archive()

/obj/machinery/atmospherics/components/tank/process_atmos()
	if(air_contents.react(src))
		update_parents()

	if(air_contents.return_pressure() > max_pressure)
		take_damage(0.1, BRUTE, sound_effect = FALSE)
		if(prob(40))
			playsound(src, pick(breaking_sounds), 30, vary = TRUE)

	refresh_window()

///////////////////////////////////////////////////////////////////
// Pipenet stuff

/obj/machinery/atmospherics/components/tank/return_analyzable_air()
	return air_contents

/obj/machinery/atmospherics/components/tank/return_airs_for_reconcilation(datum/pipeline/requester)
	. = ..()
	if(!air_contents)
		return
	. += air_contents

/obj/machinery/atmospherics/components/tank/return_pipenets_for_reconcilation(datum/pipeline/requester)
	. = ..()
	var/datum/merger/merge_group = GetMergeGroup(merger_id, merger_typecache)
	for(var/obj/machinery/atmospherics/components/tank/tank as anything in merge_group.members)
		. += tank.parents

/obj/machinery/atmospherics/components/tank/proc/toggle_side_port(new_dir)
	if(initialize_directions & new_dir)
		initialize_directions &= ~new_dir
	else
		initialize_directions |= new_dir

	for(var/i in 1 to length(nodes))
		var/obj/machinery/atmospherics/components/node = nodes[i]
		if(!node)
			continue
		if(src in node.nodes)
			node.disconnect(src)
		nodes[i] = null
		if(parents[i])
			nullify_pipenet(parents[i])

	atmos_init()

	for(var/obj/machinery/atmospherics/components/node as anything in nodes)
		if(!node)
			continue
		node.atmos_init()
		node.add_member(src)
	SSair.add_to_rebuild_queue(src)

	update_parents()

///////////////////////////////////////////////////////////////////
// Merger handling

/obj/machinery/atmospherics/components/tank/proc/merger_adding(obj/machinery/atmospherics/components/tank/us, datum/merger/new_merger)
	SIGNAL_HANDLER
	if(new_merger.id != merger_id)
		return
	RegisterSignal(new_merger, COMSIG_MERGER_REFRESH_COMPLETE, .proc/merger_refresh_complete)

/obj/machinery/atmospherics/components/tank/proc/merger_removing(obj/machinery/atmospherics/components/tank/us, datum/merger/old_merger)
	SIGNAL_HANDLER
	if(old_merger.id != merger_id)
		return
	UnregisterSignal(old_merger, COMSIG_MERGER_REFRESH_COMPLETE)

/// Handles the combined gas tank for the entire merger group, only the origin tank actualy runs this.
/obj/machinery/atmospherics/components/tank/proc/merger_refresh_complete(datum/merger/merger, list/leaving_members, list/joining_members)
	SIGNAL_HANDLER
	if(merger.origin != src)
		return
	var/shares = length(merger.members) + length(leaving_members) - length(joining_members)
	for(var/obj/machinery/atmospherics/components/tank/leaver as anything in leaving_members)
		var/datum/gas_mixture/gas_share = air_contents.remove_ratio(1 / shares--)
		air_contents.volume -= leaver.volume
		leaver.air_contents = gas_share
		leaver.update_appearance()

	for(var/obj/machinery/atmospherics/components/tank/joiner as anything in joining_members)
		if(joiner == src)
			continue
		var/datum/gas_mixture/joiner_share = joiner.air_contents
		if(joiner_share)
			air_contents.merge(joiner_share)
		joiner.air_contents = air_contents
		air_contents.volume += joiner.volume
		joiner.update_appearance()

	for(var/dir in GLOB.cardinals)
		if(dir & initialize_directions & merger.members[src])
			toggle_side_port(dir)

///////////////////////////////////////////////////////////////////
// Appearance stuff

/obj/machinery/atmospherics/components/tank/proc/smoothed()
	SIGNAL_HANDLER
	refresh_window()

/obj/machinery/atmospherics/components/tank/update_appearance()
	. = ..()
	refresh_window()

/obj/machinery/atmospherics/components/tank/update_overlays()
	. = ..()
	if(!initialize_directions)
		return
	for(var/dir in GLOB.cardinals)
		if(initialize_directions & dir)
			. += knob_overlays["[dir]"]

/obj/machinery/atmospherics/components/tank/update_greyscale()
	. = ..()
	refresh_window()

/obj/machinery/atmospherics/components/tank/proc/refresh_window()
	cut_overlay(window)

	if(!air_contents)
		window = null
		return

	window = image(icon, icon_state = "window-bg", layer = FLOAT_LAYER)

	var/list/new_underlays = list()
	for(var/obj/effect/overlay/gas/gas as anything in air_contents.return_visuals())
		var/image/new_underlay = image(gas.icon, icon_state = gas.icon_state, layer = FLOAT_LAYER)
		new_underlay.filters = alpha_mask_filter(icon = icon(icon, icon_state = "window-bg"))
		new_underlays += new_underlay

	var/image/foreground = image(icon, icon_state = "window-fg", layer = FLOAT_LAYER)
	foreground.underlays = new_underlays
	window.overlays = list(foreground)

	add_overlay(window)

///////////////////////////////////////////////////////////////////
// Tool interactions

/obj/machinery/atmospherics/components/tank/wrench_act(mob/living/user, obj/item/item)
	. = TRUE
	var/new_dir = get_dir(src, user)

	if(new_dir in GLOB.diagonals)
		return

	item.play_tool_sound(src, 10)
	if(!item.use_tool(src, user, 3 SECONDS))
		return

	toggle_side_port(new_dir)

	item.play_tool_sound(src, 50)

/obj/machinery/atmospherics/components/tank/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	. = TRUE
	if(atom_integrity >= max_integrity)
		return
	if(!tool.tool_start_check(user, amount = 0))
		return
	to_chat(user, span_notice("You begin to repair the cracks in the gas tank..."))
	var/repair_amount = max_integrity / 10
	do
		if(!tool.use_tool(src, user, 2.5 SECONDS, volume = 40))
			return
	while(repair_damage(repair_amount))
	to_chat(user, span_notice("The gas tank has been fully repaired and all cracks sealed."))

/obj/machinery/atmospherics/components/tank/welder_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	. = TRUE
	to_chat(user, span_notice("You begin cutting open the gas tank..."))
	var/turf/current_location = get_turf(src)
	var/datum/gas_mixture/airmix = current_location.return_air()

	var/time_taken = 4 SECONDS
	var/unsafe = FALSE

	var/internal_pressure = air_contents.return_pressure() - airmix.return_pressure()
	if(internal_pressure > 2 * ONE_ATMOSPHERE)
		time_taken *= 2
		to_chat(user, span_warning("The tank seems to be pressurized, are you sure this is a good idea?"))
		unsafe = TRUE

	if(!tool.use_tool(src, user, time_taken, volume = 60))
		return

	if(unsafe)
		unsafe_pressure_release(user, internal_pressure)
	deconstruct(disassembled=TRUE)
	to_chat(user, span_notice("You finish cutting open the sealed gas tank, revealing the innards."))

/obj/machinery/atmospherics/components/tank/deconstruct(disassembled)
	var/turf/location = drop_location()
	. = ..()
	location.assume_air(air_contents)
	if(!disassembled)
		return
	var/obj/structure/tank_frame/frame = new(location)
	frame.construction_state = TANK_PLATING_UNSECURED
	for(var/datum/material/material as anything in custom_materials)
		if (frame.material_end_product)
			// If something looks fishy, you get nothing
			message_admins("\The [src] had multiple materials set. Unless you were messing around with VV, yell at a coder")
			frame.material_end_product = null
			frame.construction_state = TANK_FRAME
			break
		else
			frame.material_end_product = material
	frame.update_appearance()

///////////////////////////////////////////////////////////////////
// Gas tank variants

/obj/machinery/atmospherics/components/tank/air
	name = "pressure tank (Air)"

/obj/machinery/atmospherics/components/tank/air/Initialize(mapload)
	. = ..()
	fill_to_pressure(/datum/gas/oxygen, safety_margin = (O2STANDARD * 0.5))
	fill_to_pressure(/datum/gas/nitrogen, safety_margin = (N2STANDARD * 0.5))

/obj/machinery/atmospherics/components/tank/carbon_dioxide
	gas_type = /datum/gas/carbon_dioxide

/obj/machinery/atmospherics/components/tank/plasma
	gas_type = /datum/gas/plasma

/obj/machinery/atmospherics/components/tank/nitrogen
	gas_type = /datum/gas/nitrogen

/obj/machinery/atmospherics/components/tank/oxygen
	gas_type = /datum/gas/oxygen

/obj/machinery/atmospherics/components/tank/nitrous
	gas_type = /datum/gas/nitrous_oxide

/obj/machinery/atmospherics/components/tank/bz
	gas_type = /datum/gas/bz

/obj/machinery/atmospherics/components/tank/freon
	gas_type = /datum/gas/freon

/obj/machinery/atmospherics/components/tank/halon
	gas_type = /datum/gas/halon

/obj/machinery/atmospherics/components/tank/healium
	gas_type = /datum/gas/healium

/obj/machinery/atmospherics/components/tank/hydrogen
	gas_type = /datum/gas/hydrogen

/obj/machinery/atmospherics/components/tank/hypernoblium
	gas_type = /datum/gas/hypernoblium

/obj/machinery/atmospherics/components/tank/miasma
	gas_type = /datum/gas/miasma

/obj/machinery/atmospherics/components/tank/nitrium
	gas_type = /datum/gas/nitrium

/obj/machinery/atmospherics/components/tank/pluoxium
	gas_type = /datum/gas/pluoxium

/obj/machinery/atmospherics/components/tank/proto_nitrate
	gas_type = /datum/gas/proto_nitrate

/obj/machinery/atmospherics/components/tank/tritium
	gas_type = /datum/gas/tritium

/obj/machinery/atmospherics/components/tank/water_vapor
	gas_type = /datum/gas/water_vapor

/obj/machinery/atmospherics/components/tank/zauker
	gas_type = /datum/gas/zauker

/obj/machinery/atmospherics/components/tank/helium
	gas_type = /datum/gas/helium

/obj/machinery/atmospherics/components/tank/antinoblium
	gas_type = /datum/gas/antinoblium

///////////////////////////////////////////////////////////////////
// Tank Frame Structure

/obj/structure/tank_frame
	icon = 'icons/obj/atmospherics/stationary_canisters.dmi'
	icon_state = "frame"
	anchored = FALSE
	density = TRUE
	custom_materials = list(/datum/material/alloy/plasteel = 4 * MINERAL_MATERIAL_AMOUNT)
	var/construction_state = TANK_FRAME
	var/datum/material/material_end_product

/obj/structure/tank_frame/examine(mob/user)
	. = ..()
	var/wrenched_hint = EXAMINE_HINT("wrenched")

	if(!anchored)
		. += span_notice("[src] has not been [wrenched_hint] to the floor yet.")
	else
		. += span_notice("[src] is [wrenched_hint] to the floor.")

	switch(construction_state)
		if(TANK_FRAME)
			var/screwed_hint = EXAMINE_HINT("screwed")
			var/plating_hint = EXAMINE_HINT("metal plating")
			. += span_notice("[src] is [screwed_hint] together and now just needs some [plating_hint].")
		if(TANK_PLATING_UNSECURED)
			var/crowbar_hint = EXAMINE_HINT("crowbar")
			var/welder_hint = EXAMINE_HINT("welder")
			. += span_notice("The plating has been firmly attached and would need a [crowbar_hint] to detach, but still needs to be sealed by a [welder_hint].")

/obj/structure/tank_frame/deconstruct(disassembled)
	if(disassembled)
		for(var/datum/material/mat as anything in custom_materials)
			new mat.sheet_type(drop_location(), custom_materials[mat] / MINERAL_MATERIAL_AMOUNT)
	return ..()

/obj/structure/tank_frame/update_icon(updates)
	. = ..()
	switch(construction_state)
		if(TANK_FRAME)
			icon_state = "frame"
		if(TANK_PLATING_UNSECURED)
			icon_state = "plated_frame"

/obj/structure/tank_frame/attackby(obj/item/item, mob/living/user, params)
	if(construction_state == TANK_FRAME && istype(item, /obj/item/stack) && add_plating(user, item))
		return
	return ..()

/obj/structure/tank_frame/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 0.5 SECONDS)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/tank_frame/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	if(construction_state != TANK_FRAME)
		return
	. = TRUE
	to_chat(user, span_notice("You begin taking apart [src]."))
	if(!tool.use_tool(src, user, 1 SECONDS))
		return
	deconstruct(TRUE)
	to_chat(user, span_notice("[src] has been taken apart."))

/obj/structure/tank_frame/proc/add_plating(mob/living/user, obj/item/stack/stack)
	. = FALSE
	if(!stack.material_type)
		balloon_alert(user, "invalid material!")
	var/datum/material/stack_mat = GET_MATERIAL_REF(stack.material_type)
	if(!(MAT_CATEGORY_RIGID in stack_mat.categories))
		to_chat(user, span_notice("This material doesn't seem rigid enough to hold the shape of a tank..."))
		return

	. = TRUE
	to_chat(user, span_notice("You begin adding [stack] to [src]..."))
	if(!stack.use_tool(src, user, 3 SECONDS))
		return
	if(!stack.use(TANK_PLATING_SHEETS))
		var/amount_more
		switch(100 * stack.amount / TANK_PLATING_SHEETS)
			if(0) // Wat?
				amount_more = "any at all"
			if(1 to 25)
				amount_more = "a lot more"
			if(26 to 50)
				amount_more = "about four times as much"
			if(51 to 75)
				amount_more = "about twice as much"
			if(76 to 100)
				amount_more = "just a bit more"
			else
				amount_more = "an indeterminate amount more"
		to_chat(user, span_notice("You don't have enough [stack] to add all the plating. Maybe [amount_more]."))
		return

	material_end_product = stack_mat
	construction_state = TANK_PLATING_UNSECURED
	update_appearance()
	to_chat(user, span_notice("You finish attaching [stack] to [src]."))

/obj/structure/tank_frame/crowbar_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	if(construction_state != TANK_PLATING_UNSECURED)
		return
	. = TRUE
	to_chat(user, span_notice("You start prying off the outer plating..."))
	if(!tool.use_tool(src, user, 2 SECONDS))
		return
	construction_state = TANK_FRAME
	new material_end_product.sheet_type(drop_location(), TANK_PLATING_SHEETS)
	material_end_product = null
	update_appearance()

/obj/structure/tank_frame/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(construction_state != TANK_PLATING_UNSECURED)
		return
	. = TRUE
	if(!anchored)
		to_chat(user, span_notice("You need to <b>wrench</b> [src] to the floor before finishing."))
		return
	if(!tool.tool_start_check(user, amount = 0))
		return
	to_chat(user, span_notice("You begin sealing the outer plating with the welder..."))
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 60))
		return

	var/turf/build_location = drop_location()
	if(!isturf(build_location))
		return
	var/obj/machinery/atmospherics/components/tank/new_tank = new(build_location)
	var/list/new_custom_materials = list((material_end_product) = TANK_PLATING_SHEETS * MINERAL_MATERIAL_AMOUNT)
	new_tank.set_custom_materials(new_custom_materials)
	new_tank.on_construction(new_tank.pipe_color, new_tank.piping_layer)
	to_chat(user, span_notice("[new_tank] has been sealed and is ready to accept gases."))
	qdel(src)

#undef TANK_PLATING_SHEETS
