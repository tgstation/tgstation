///this cannablizes floor_pump code but rips specific reagents and and such just does stuff itself so it can be expanded easier in the future

/obj/machinery/plumbing/ooze_sucker
	name = "ooze sucker"
	icon = 'monkestation/code/modules/slimecore/icons/machinery.dmi'
	base_icon_state = "ooze_sucker"
	icon_state = "ooze_sucker"
	anchored = FALSE
	density = FALSE
	idle_power_usage = 10
	active_power_usage = 1000
	buffer = 3000
	category="Distribution"
	reagent_flags = NO_REACT

	/// Pump is turned on by engineer, etc.
	var/turned_on = FALSE

	var/obj/machinery/slime_pen_controller/linked_controller
	///if we have this on mapload we will look in a range for a controller
	var/mapping_id

	/// Floor tile is placed down
	var/tile_placed = FALSE

	var/processes = 0
	var/processes_required = 5

	/// Base amount to drain
	var/drain_flat = 20
	/// Additional ratio of liquid volume to drain
	var/drain_percent = 1

/obj/machinery/plumbing/ooze_sucker/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt, layer)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/plumbing/ooze_sucker/LateInitialize()
	. = ..()
	locate_machinery()

/obj/machinery/plumbing/ooze_sucker/locate_machinery(multitool_connection)
	if(!mapping_id)
		return
	for(var/obj/machinery/slime_pen_controller/main in GLOB.machines)
		if(main.mapping_id != mapping_id)
			continue
		linked_controller = main
		main.linked_sucker = src
		return

/obj/machinery/plumbing/ooze_sucker/examine(mob/user)
	. = ..()
	. += span_notice("It's currently turned [turned_on ? "ON" : "OFF"].")


/obj/machinery/plumbing/ooze_sucker/update_icon_state()
	. = ..()
	if(turned_on)
		icon_state = "[base_icon_state]-on"
	else
		icon_state = base_icon_state

/obj/machinery/plumbing/ooze_sucker/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		turned_on = FALSE
		update_icon_state()


/obj/machinery/plumbing/ooze_sucker/proc/toggle_state()
	turned_on = !turned_on
	update_appearance()

/obj/machinery/plumbing/ooze_sucker/proc/can_run()
	return is_operational \
		&& turned_on \
		&& anchored \
		&& !panel_open \
		&& isturf(loc) \
		&& are_reagents_ready()

/obj/machinery/plumbing/ooze_sucker/proc/are_reagents_ready()
	return reagents.total_volume < reagents.maximum_volume

/obj/machinery/plumbing/ooze_sucker/process(seconds_per_tick)
	if(!can_run())
		return

	// Determine what tiles should be pumped. We grab from a 3x3 area,
	// but overall try to pump the same volume regardless of number of affected tiles
	var/turf/local_turf = get_turf(src)
	var/list/turf/candidate_turfs = local_turf.get_atmos_adjacent_turfs(alldir = TRUE)
	candidate_turfs += local_turf

	var/list/turf/affected_turfs = list()

	for(var/turf/candidate as anything in candidate_turfs)
		if(isturf(candidate))
			affected_turfs += candidate

	if(!length(affected_turfs))
		return

	// note that the length was verified to be > 0 directly above and is a local var.
	var/multiplier = 1 / length(affected_turfs)

	// We're good, actually pump.
	for(var/turf/affected_turf as anything in affected_turfs)
		pump_turf(affected_turf, seconds_per_tick, multiplier)

/obj/machinery/plumbing/ooze_sucker/proc/pump_turf(turf/affected_turf, seconds_per_tick, multiplier)
	if(processes < processes_required)
		processes++
		return
	processes = 0
	if(!affected_turf.liquids || !affected_turf.liquids.liquid_group)
		return

	var/target_value = seconds_per_tick * (drain_flat + (affected_turf.liquids.liquid_group.total_reagent_volume * drain_percent)) * multiplier
	//Free space handling
	var/free_space = reagents.maximum_volume - reagents.total_volume
	if(target_value > free_space)
		target_value = free_space

	var/datum/liquid_group/targeted_group = affected_turf.liquids.liquid_group
	if(!targeted_group.reagents_per_turf)
		return
	targeted_group.transfer_specific_reagents(reagents, target_value, reagents_to_check = typesof(/datum/reagent/slime_ooze), merge = TRUE)
