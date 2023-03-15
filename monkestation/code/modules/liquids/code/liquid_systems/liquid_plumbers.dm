/**
 * Base class for underfloor plumbing machines that mess with floor liquids.
 */
/obj/machinery/plumbing/floor_pump
	icon = 'monkestation/code/modules/liquids/icons/obj/structures/drains.dmi'
	anchored = FALSE
	density = FALSE
	idle_power_usage = 10
	active_power_usage = 1000
	buffer = 300

	/// Pump is turned on by engineer, etc.
	var/turned_on = FALSE
	/// Only pump to this liquid level height. 0 means pump the most possible.
	var/height_regulator = 0

	/// The default duct layer for mapping
	var/duct_layer = 0

	/// Base amount to drain
	var/drain_flat = 20
	/// Additional ratio of liquid volume to drain
	var/drain_percent = 0.4

	/// Currently pumping.
	var/is_pumping = FALSE
	/// Floor tile is placed down
	var/tile_placed = FALSE

/obj/machinery/plumbing/floor_pump/Initialize(mapload, bolt, layer)
	. = ..()
	RegisterSignal(src, list(COMSIG_OBJ_HIDE), .proc/on_hide)

/obj/machinery/plumbing/floor_pump/examine(mob/user)
	. = ..()
	. += span_notice("It's currently turned [turned_on ? "ON" : "OFF"].")
	. += span_notice("Its height regulator [height_regulator ? "points at [height_regulator]" : "is disabled"]. Click while unanchored to change.")

/obj/machinery/plumbing/floor_pump/update_appearance(updates)
	. = ..()
	layer = tile_placed ? GAS_SCRUBBER_LAYER : BELOW_OBJ_LAYER
	plane = tile_placed ? FLOOR_PLANE : GAME_PLANE

/obj/machinery/plumbing/floor_pump/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "[base_icon_state]-open"
	else if(is_pumping)
		icon_state = "[base_icon_state]-pumping"
	else if(is_operational && turned_on)
		icon_state = "[base_icon_state]-idle"
	else
		icon_state = base_icon_state

/obj/machinery/plumbing/floor_pump/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		turned_on = FALSE
		update_icon_state()

/obj/machinery/plumbing/floor_pump/attack_hand(mob/user)
	if(!anchored)
		set_regulator(user)
		return
	balloon_alert(user, "turned [turned_on ? "off" : "on"]")
	turned_on = !turned_on
	update_icon_state()

/**
 * Change regulator level -- ie. what liquid depth we are OK with, like a thermostat.
 */
/obj/machinery/plumbing/floor_pump/proc/set_regulator(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return
	var/new_height = tgui_input_number(user,
		"At what water level should the pump stop pumping from 0 to [LIQUID_HEIGHT_CONSIDER_FULL_TILE]? 0 disables.",
		"[src]",
		default = height_regulator,
		min_value = 0,
		max_value = LIQUID_HEIGHT_CONSIDER_FULL_TILE)
	if(QDELETED(src) || new_height == null)
		return
	height_regulator = new_height

/**
 * Handle COMSIG_OBJ_HIDE to toggle whether we're on the floor
 */
/obj/machinery/plumbing/floor_pump/proc/on_hide(atom/movable/AM, should_hide)
	tile_placed = should_hide
	update_appearance()

/**
 * Can the pump actually run at all?
 */
/obj/machinery/plumbing/floor_pump/proc/can_run()
	return is_operational \
		&& turned_on \
		&& anchored \
		&& !panel_open \
		&& isturf(loc) \
		&& are_reagents_ready()

/**
 * Is the internal reagents container able to give or take liquid as appropriate?
 */
/obj/machinery/plumbing/floor_pump/proc/are_reagents_ready()
	CRASH("are_reagents_ready() must be overriden.")

/**
 * Should we actually be pumping this tile right now?
 * Arguments:
 * * affected_turf - the turf to check.
 */
/obj/machinery/plumbing/floor_pump/proc/should_pump(turf/affected_turf)
	return isturf(affected_turf) \
		&& should_regulator_permit(affected_turf)

/**
 * Should the liquid height regulator allow water to be pumped here?
 */
/obj/machinery/plumbing/floor_pump/proc/should_regulator_permit(turf/affected_turf)
	CRASH("should_regulator_permit() must be overriden.")

/obj/machinery/plumbing/floor_pump/process(delta_time)
	var/was_pumping = is_pumping

	if(!can_run())
		is_pumping = FALSE
		if(was_pumping)
			update_icon_state()
		return

	// Determine what tiles should be pumped. We grab from a 3x3 area,
	// but overall try to pump the same volume regardless of number of affected tiles
	var/turf/local_turf = get_turf(src)
	var/list/turf/candidate_turfs = local_turf.GetAtmosAdjacentTurfs(alldir = TRUE)
	candidate_turfs += local_turf

	var/list/turf/affected_turfs = list()

	for(var/turf/candidate as anything in candidate_turfs)
		if(should_pump(candidate))
			affected_turfs += candidate

	// Update state
	is_pumping = length(affected_turfs) > 0
	if(is_pumping != was_pumping)
		update_icon_state()
	if(!is_pumping)
		return

	// note that the length was verified to be > 0 directly above and is a local var.
	var/multiplier = 1 / length(affected_turfs)

	// We're good, actually pump.
	for(var/turf/affected_turf as anything in affected_turfs)
		pump_turf(affected_turf, delta_time, multiplier)

/**
 * Pump out the liquids on a turf.
 *
 * Arguments:
 * * affected_turf - the turf to pump liquids out of.
 * * delta_time - machine process delta time
 * * multiplier - Multiplier to apply to final volume we want to pump.
 */
/obj/machinery/plumbing/floor_pump/proc/pump_turf(turf/affected_turf, delta_time, multiplier)
	CRASH("pump_turf() must be overriden.")



/obj/machinery/plumbing/floor_pump/input
	name = "liquid input pump"
	desc = "Pump used to siphon liquids from a location into the plumbing pipenet."
	icon_state = "active_input"
	base_icon_state = "active_input"

/obj/machinery/plumbing/floor_pump/input/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt, layer || duct_layer)

/obj/machinery/plumbing/floor_pump/input/are_reagents_ready()
	return reagents.total_volume < reagents.maximum_volume

/obj/machinery/plumbing/floor_pump/input/should_regulator_permit(turf/affected_turf)
	return affected_turf.liquids && affected_turf.liquids.liquid_group.expected_turf_height > height_regulator

/obj/machinery/plumbing/floor_pump/input/pump_turf(turf/affected_turf, delta_time, multiplier)
	if(!affected_turf.liquids || !affected_turf.liquids.liquid_group)
		return
	var/target_value = delta_time * (drain_flat + (affected_turf.liquids.liquid_group.total_reagent_volume * drain_percent)) * multiplier
	//Free space handling
	var/free_space = reagents.maximum_volume - reagents.total_volume
	if(target_value > free_space)
		target_value = free_space

	var/datum/liquid_group/targeted_group = affected_turf.liquids.liquid_group
	if(!targeted_group.reagents_per_turf)
		return
	var/turfs_to_pull = round(target_value / targeted_group.reagents_per_turf,1)

	var/list/removed_turfs = targeted_group.return_connected_liquids_in_range(affected_turf.liquids, turfs_to_pull)
	targeted_group.trans_to_seperate_group(reagents, target_value, merge = TRUE)
	for(var/turf/listed_turf in removed_turfs)
		targeted_group.remove_from_group(listed_turf)
		qdel(listed_turf.liquids)
		for(var/dir in GLOB.cardinals)
			var/turf/open/direction_turf = get_step(listed_turf, dir)
			if(!isopenturf(direction_turf) || !direction_turf.liquids)
				continue
			listed_turf.liquids.liquid_group.check_edges(direction_turf)

	///recalculate the values here because processing
	targeted_group.total_reagent_volume = targeted_group.reagents.total_volume
	targeted_group.reagents_per_turf = targeted_group.total_reagent_volume / length(targeted_group.members)

	if(!removed_turfs.len)
		return
	while(removed_turfs.len)
		var/turf/picked_turf = pick(removed_turfs)
		var/list/output = targeted_group.try_split(picked_turf, TRUE)
		removed_turfs -= picked_turf
		for(var/turf/outputted_turf in output)
			if(outputted_turf in removed_turfs)
				removed_turfs -= outputted_turf

/obj/machinery/plumbing/floor_pump/input/on
	icon_state = "active_input-mapping"
	anchored = TRUE
	turned_on = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/plumbing/floor_pump/input/on, 0)

/obj/machinery/plumbing/floor_pump/input/on/waste
	icon_state = "active_input-mapping2"
	duct_layer = SECOND_DUCT_LAYER

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/plumbing/floor_pump/input/on/waste, 0)

/obj/machinery/plumbing/floor_pump/output
	name = "liquid output pump"
	desc = "Pump used to dump liquids out from a plumbing pipenet into a location."
	icon_state = "active_output"
	base_icon_state = "active_output"

	/// Is the turf too full to pump more?
	var/over_volume = FALSE
	/// Max liquid volume on the turf before we stop pumping.
	var/max_ext_volume = LIQUID_HEIGHT_CONSIDER_FULL_TILE

	/// Is the turf too high-pressured to pump more?
	var/over_pressure = FALSE
	/// Max pressure on the turf before we stop pumping.
	var/max_ext_kpa = WARNING_HIGH_PRESSURE

/obj/machinery/plumbing/floor_pump/output/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt, layer || duct_layer)

/obj/machinery/plumbing/floor_pump/output/examine(mob/user)
	. = ..()
	if(over_pressure)
		. += span_warning("The gas regulator light is blinking.")
	if(over_volume)
		. += span_warning("The liquid volume regulator light is blinking.")

/obj/machinery/plumbing/floor_pump/output/are_reagents_ready()
	return reagents.total_volume > 0

/obj/machinery/plumbing/floor_pump/output/should_regulator_permit(turf/affected_turf)
	// 0 means keep pumping forever.
	return !height_regulator || affected_turf.liquids.liquid_group.expected_turf_height < height_regulator

/obj/machinery/plumbing/floor_pump/output/process()
	over_pressure = FALSE
	return ..()

/obj/machinery/plumbing/floor_pump/output/should_pump(turf/affected_turf)
	. = ..()
	if(!.)
		return FALSE

	if(affected_turf.liquids?.liquid_group.expected_turf_height >= max_ext_volume)
		return FALSE
	var/turf/open/open_turf = affected_turf
	var/datum/gas_mixture/gas_mix = open_turf?.return_air()
	if(gas_mix?.return_pressure() > max_ext_kpa)
		over_pressure = TRUE
		return FALSE
	return TRUE

/obj/machinery/plumbing/floor_pump/output/pump_turf(turf/affected_turf, delta_time, multiplier)
	var/target_value = delta_time * (drain_flat + (reagents.total_volume * drain_percent)) * multiplier
	if(target_value > reagents.total_volume)
		target_value = reagents.total_volume

	var/datum/reagents/tempr = new(10000)
	reagents.trans_to(tempr, target_value, no_react = TRUE)
	affected_turf.add_liquid_from_reagents(tempr)
	qdel(tempr)

/obj/machinery/plumbing/floor_pump/output/on
	icon_state = "active_output-mapping"
	anchored = TRUE
	turned_on = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/plumbing/floor_pump/output/on, 0)

/obj/machinery/plumbing/floor_pump/output/on/supply
	icon_state = "active_output-mapping2"
	duct_layer = FOURTH_DUCT_LAYER

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/plumbing/floor_pump/output/on/supply, 0)

/obj/item/construction/plumbing/engineering
	name = "engineering plumbing constructor"
	desc = "A type of plumbing constructor designed to rapidly deploy the machines needed for logistics regarding fluids."
	icon_state = "plumberer2"
	has_ammobar = TRUE

/obj/item/construction/plumbing/engineering/set_plumbing_designs()
	plumbing_design_types = list(
		/obj/machinery/duct = 1,
		/obj/machinery/plumbing/input = 5,
		/obj/machinery/plumbing/output = 5,
		/obj/machinery/plumbing/tank = 20,
		/obj/machinery/plumbing/acclimator = 10,
		/obj/machinery/plumbing/filter = 5,
		/obj/machinery/plumbing/splitter = 5,
		/obj/machinery/plumbing/disposer = 10,
		/obj/machinery/plumbing/floor_pump/input = 20,
		/obj/machinery/plumbing/floor_pump/output = 20,
		/obj/machinery/plumbing/layer_manifold = 5,
	)

// Helpers for maps
/obj/machinery/duct/supply
	duct_color = COLOR_CYAN
	duct_layer = FOURTH_DUCT_LAYER

/obj/machinery/duct/waste
	duct_color = COLOR_BROWN
	duct_layer = SECOND_DUCT_LAYER
