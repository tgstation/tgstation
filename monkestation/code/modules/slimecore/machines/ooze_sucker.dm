#define SUCKER_UPGRADE_DISPOSER "disposer"
#define SUCKER_UPGRADE_BALANCER "balancer"
#define SUCKER_UPGRADE_CAPACITY "capacity"

GLOBAL_LIST_EMPTY_TYPED(ooze_suckers, /obj/machinery/plumbing/ooze_sucker)

///this cannablizes floor_pump code but rips specific reagents and and such just does stuff itself so it can be expanded easier in the future
/obj/machinery/plumbing/ooze_sucker
	name = "ooze sucker"
	icon = 'monkestation/code/modules/slimecore/icons/machinery.dmi'
	base_icon_state = "ooze_sucker"
	icon_state = "ooze_sucker"
	anchored = FALSE
	density = FALSE

	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.1
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.15

	buffer = 3000
	category = "Distribution"
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

	/// Whether draining was performed last process or not.
	var/drained_last_process = FALSE

	var/list/upgrade_disks = list()
	var/list/upgrades = list()

/obj/machinery/plumbing/ooze_sucker/Initialize(mapload, bolt, layer)
	. = ..()
	GLOB.ooze_suckers += src
	AddComponent(/datum/component/plumbing/simple_supply, bolt, layer)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/plumbing/ooze_sucker/LateInitialize()
	. = ..()
	locate_machinery()

/obj/machinery/plumbing/ooze_sucker/Destroy()
	GLOB.ooze_suckers -= src
	return ..()

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
	. += span_notice("It's currently turned [turned_on ? "ON" : "OFF"]. Right-click to toggle.")
	if(length(upgrade_disks))
		. += span_notice("Ctrl-click to remove an installed upgrade.")
	for(var/obj/item/disk/sucker_upgrade/upgrade as anything in upgrade_disks)
		. += span_notice(upgrade.notice)


/obj/machinery/plumbing/ooze_sucker/update_icon_state()
	. = ..()
	if(turned_on)
		icon_state = "[base_icon_state]-on"
	else
		icon_state = base_icon_state

/obj/machinery/plumbing/ooze_sucker/attackby(obj/item/item, mob/user, params)
	if(user.istate & ISTATE_HARM)
		return ..()

	if(!istype(item, /obj/item/disk/sucker_upgrade))
		return ..()

	var/obj/item/disk/sucker_upgrade/upgrade = item

	for(var/obj/item/disk/sucker_upgrade/upgrade_disk as anything in upgrade_disks)
		if(upgrade.upgrade_type in upgrade_disk.override_types)
			balloon_alert(user, "incompatible with [upgrade_disk.upgrade_type] upgrade!")
			return

	if(upgrade.upgrade_type in upgrades)
		balloon_alert(user, "already installed!")
		return

	for(var/obj/item/disk/sucker_upgrade/upgrade_disk as anything in upgrade_disks.Copy())
		if(upgrade_disk.upgrade_type in upgrade.override_types)
			remove_upgrade(upgrade_disk)

	add_upgrade(upgrade)

	to_chat(user, span_notice("You install a [upgrade.upgrade_type] upgrade into [src]."))
	playsound(user, 'sound/machines/click.ogg', 30, TRUE)

/obj/machinery/plumbing/ooze_sucker/proc/add_upgrade(obj/item/disk/sucker_upgrade/upgrade)
	upgrades += upgrade.upgrade_type
	upgrades += upgrade.additional_types
	upgrade_disks += upgrade
	upgrade.forceMove(src)
	upgrade.on_upgrade(src)

/obj/machinery/plumbing/ooze_sucker/proc/remove_upgrade(obj/item/disk/sucker_upgrade/upgrade)
	upgrades -= upgrade.upgrade_type
	upgrades -= upgrade.additional_types
	upgrade_disks -= upgrade
	upgrade.forceMove(drop_location())
	upgrade.on_remove(src)

/obj/machinery/plumbing/ooze_sucker/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		turned_on = FALSE
		update_icon_state()

/obj/machinery/plumbing/ooze_sucker/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignals(reagents, list(COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED), PROC_REF(on_reagent_change))
	RegisterSignal(reagents, COMSIG_QDELETING, PROC_REF(on_reagents_del))

/// Handles properly detaching signal hooks.
/obj/machinery/plumbing/ooze_sucker/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED, COMSIG_QDELETING))
	return NONE

/// Handles ensuring power usage becomes idle when reagents are full.
/obj/machinery/plumbing/ooze_sucker/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	update_power_usage()
	return NONE

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
	return reagents.total_volume < reagents.maximum_volume || (SUCKER_UPGRADE_DISPOSER in upgrades)

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
	update_power_usage()

/obj/machinery/plumbing/ooze_sucker/proc/update_power_usage()
	if(!turned_on)
		update_use_power(NO_POWER_USE)
	else if(reagents && reagents.total_volume >= reagents.maximum_volume)
		update_use_power(IDLE_POWER_USE)
	else if(drained_last_process)
		update_use_power(ACTIVE_POWER_USE)
	else
		update_use_power(IDLE_POWER_USE)

/obj/machinery/plumbing/ooze_sucker/proc/pump_turf(turf/affected_turf, seconds_per_tick, multiplier)
	if(processes < processes_required)
		processes++
		return
	processes = 0
	drained_last_process = FALSE

	if(!affected_turf.liquids || !affected_turf.liquids.liquid_group)
		return

	var/target_value = seconds_per_tick * (drain_flat + (affected_turf.liquids.liquid_group.total_reagent_volume * drain_percent)) * multiplier
	//Free space handling
	var/free_space = reagents.maximum_volume - reagents.total_volume
	if(target_value > free_space && (SUCKER_UPGRADE_DISPOSER in upgrades))
		if (SUCKER_UPGRADE_BALANCER in upgrades)
			reagents.remove_reagent(reagents.get_master_reagent_id(), target_value - free_space)
		else
			reagents.remove_all(target_value - free_space)
	else if(target_value > free_space)
		target_value = free_space

	var/datum/liquid_group/targeted_group = affected_turf.liquids.liquid_group
	if(!targeted_group.reagents_per_turf)
		return
	targeted_group.transfer_specific_reagents(reagents, target_value, reagents_to_check = typesof(/datum/reagent/slime_ooze), remover = affected_turf.liquids,  merge = TRUE)
	drained_last_process = TRUE

/obj/machinery/plumbing/ooze_sucker/CtrlClick(mob/user)
	if(!can_interact(user) || !length(upgrade_disks))
		return ..()

	var/list/choices = list()
	for(var/obj/item/disk/sucker_upgrade/disk as anything in upgrade_disks)
		choices += disk.upgrade_type

	var/upgrade = tgui_input_list(user, "Select an upgrade to remove.", "Upgrade Removal", choices)
	if(!upgrade)
		return

	var/upgrade_disk
	for(var/obj/item/disk/sucker_upgrade/disk as anything in upgrade_disks)
		if(disk.upgrade_type == upgrade)
			upgrade_disk = disk
	if(!upgrade_disk) // how even
		return

	remove_upgrade(upgrade_disk)
	user.put_in_hands(upgrade_disk)

	to_chat(user, span_notice("You remove \the [upgrade] upgrade from [src]."))
	playsound(user, 'sound/machines/click.ogg', 30, TRUE)

/obj/machinery/plumbing/ooze_sucker/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	toggle_state()
	balloon_alert_to_viewers("[turned_on ? "enabled" : "disabled"] ooze sucker")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/disk/sucker_upgrade
	name = "ooze sucker upgrade disk"
	desc = "An upgrade disk for an ooze sucker."
	icon_state = "rndmajordisk"

	/// A message given to the player when they examine a sucker with this installed.
	var/notice

	/// The type of this upgrade. Use a define here.
	var/upgrade_type

	/// What upgrade types this overrides.
	var/override_types = list()

	/// What additional upgrade types should be added to the sucker when this is installed.
	/// These do NOT include their notices, overrides, etc. when added.
	var/additional_types = list()

/obj/item/disk/sucker_upgrade/proc/on_upgrade(obj/machinery/plumbing/ooze_sucker/sucker)

/obj/item/disk/sucker_upgrade/proc/on_remove(obj/machinery/plumbing/ooze_sucker/sucker)

/obj/item/disk/sucker_upgrade/disposer
	name = "ooze sucker disposer upgrade disk"
	desc = "An upgrade disk for an ooze sucker that makes it automatically dispose of excess ooze."
	notice = "It's automatically disposing of excess ooze."
	upgrade_type = SUCKER_UPGRADE_DISPOSER

/obj/item/disk/sucker_upgrade/balancer
	name = "ooze sucker balancer upgrade disk"
	desc = "An upgrade disk for an ooze sucker that makes it automatically balance ooze types. Also acts as a disposer."
	notice = "It's automatically balancing ooze types and disposing of any excess."
	upgrade_type = SUCKER_UPGRADE_BALANCER
	override_types = list(SUCKER_UPGRADE_DISPOSER)
	additional_types = list(SUCKER_UPGRADE_DISPOSER)

/obj/item/disk/sucker_upgrade/capacity
	name = "ooze sucker capacity upgrade disk"
	desc = "An upgrade disk for an ooze sucker that doubles it's capacity."
	notice = "It has an increased storage capacity."
	upgrade_type = SUCKER_UPGRADE_CAPACITY

/obj/item/disk/sucker_upgrade/capacity/on_upgrade(obj/machinery/plumbing/ooze_sucker/sucker)
	sucker.reagents.maximum_volume *= 2

/obj/item/disk/sucker_upgrade/capacity/on_remove(obj/machinery/plumbing/ooze_sucker/sucker)
	sucker.reagents.maximum_volume *= 0.5

	if(sucker.reagents.total_volume > sucker.reagents.maximum_volume)
		var/turf/turf = get_turf(sucker)
		turf.add_liquid_from_reagents(sucker.reagents, amount = sucker.reagents.total_volume - sucker.reagents.maximum_volume)
		if (sucker.reagents.total_volume > sucker.reagents.maximum_volume)
			sucker.reagents.remove_all(sucker.reagents.total_volume - sucker.reagents.maximum_volume) // guh

#undef SUCKER_UPGRADE_DISPOSER
#undef SUCKER_UPGRADE_BALANCER
#undef SUCKER_UPGRADE_CAPACITY
