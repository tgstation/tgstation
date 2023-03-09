/// Datum which manages references to things we are instructed to destroy
GLOBAL_DATUM_INIT(objective_machine_handler, /datum/objective_target_machine_handler, new())

/// Marks a machine as a possible traitor sabotage target
/proc/add_sabotage_machine(source, typepath)
	LAZYADD(GLOB.objective_machine_handler.machine_instances_by_path[typepath], source)
	return typepath

/// Traitor objective to destroy a machine the crew cares about
/datum/traitor_objective_category/sabotage_machinery
	name = "Sabotage Worksite"
	objectives = list(
		/datum/traitor_objective/sabotage_machinery/trap = 1,
		/datum/traitor_objective/sabotage_machinery/destroy = 1,
	)

/datum/traitor_objective/sabotage_machinery
	name = "Sabotage the %MACHINE%"
	description = "Abstract objective holder which shouldn't appear in your uplink."
	abstract_type = /datum/traitor_objective/sabotage_machinery

	/// The maximum amount of this type of objective a traitor can have, set to 0 for no limit.
	var/maximum_allowed = 0
	/// The possible target machinery and the jobs tied to each one.
	var/list/applicable_jobs = list()
	/// The chosen job. Used to check for duplicates
	var/chosen_job

/datum/traitor_objective/sabotage_machinery/can_generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(!maximum_allowed)
		return TRUE
	if(length(possible_duplicates) >= maximum_allowed)
		return FALSE
	return TRUE

/datum/traitor_objective/sabotage_machinery/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_jobs = applicable_jobs.Copy()
	for(var/datum/traitor_objective/sabotage_machinery/objective as anything in possible_duplicates)
		possible_jobs -= objective.chosen_job
	for(var/available_job in possible_jobs)
		var/job_machine_path = possible_jobs[available_job]
		if (!length(GLOB.objective_machine_handler.machine_instances_by_path[job_machine_path]))
			possible_jobs -= available_job
	if(!length(possible_jobs))
		return FALSE

	chosen_job = pick(possible_jobs)
	var/list/obj/machinery/possible_machines = GLOB.objective_machine_handler.machine_instances_by_path[possible_jobs[chosen_job]]
	for(var/obj/machinery/machine as anything in possible_machines)
		prepare_machine(machine)

	replace_in_name("%JOB%", lowertext(chosen_job))
	replace_in_name("%MACHINE%", possible_machines[1].name)
	return TRUE

/// Marks a given machine as our target
/datum/traitor_objective/sabotage_machinery/proc/prepare_machine(obj/machinery/machine)
	AddComponent(/datum/component/traitor_objective_register, machine, succeed_signals = list(COMSIG_PARENT_QDELETING))

// Destroy machines which are in annoying locations, are annoying when destroyed, and aren't directly interacted with
/datum/traitor_objective/sabotage_machinery/destroy
	name = "Destroy the %MACHINE%"
	description = "Destroy the %MACHINE% to cause disarray and disrupt the operations of the %JOB%'s department."

	progression_reward = list(5 MINUTES, 10 MINUTES)
	telecrystal_reward = list(3, 4)

	progression_minimum = 15 MINUTES
	progression_maximum = 30 MINUTES

	applicable_jobs = list(
		JOB_STATION_ENGINEER = /obj/machinery/telecomms/hub,
		JOB_SCIENTIST = /obj/machinery/rnd/server,
	)

// Rig machines which are in public locations to explode when interacted with
/datum/traitor_objective/sabotage_machinery/trap
	name = "Sabotage the %MACHINE%"
	description = "Destroy the %MACHINE% to cause disarray and disrupt the operations of the %JOB%'s department. If you can get another crew member to destroy the machine using the provided booby trap, you will be rewarded with an additional %PROGRESSION% reputation and %TC% telecrystals."

	progression_reward = list(2 MINUTES, 4 MINUTES)
	telecrystal_reward = 0 // Only from completing the bonus objective

	progression_minimum = 0 MINUTES
	progression_maximum = 10 MINUTES

	maximum_allowed = 2
	applicable_jobs = list(
		JOB_CHIEF_ENGINEER = /obj/machinery/rnd/production/protolathe/department/engineering,
		JOB_CHIEF_MEDICAL_OFFICER = /obj/machinery/rnd/production/techfab/department/medical,
		JOB_HEAD_OF_PERSONNEL = /obj/machinery/rnd/production/techfab/department/service,
		JOB_QUARTERMASTER = /obj/machinery/rnd/production/techfab/department/cargo,
		JOB_RESEARCH_DIRECTOR = /obj/machinery/rnd/production/protolathe/department/science,
		JOB_SHAFT_MINER = /obj/machinery/mineral/ore_redemption,
	)

	/// Bonus reward to grant if you booby trap successfully
	var/bonus_tc = 2
	/// Bonus progression to grant if you booby trap successfully
	var/bonus_progression = 5 MINUTES
	/// The trap device we give out
	var/obj/item/traitor_machine_trapper/tool

/datum/traitor_objective/sabotage_machinery/trap/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	. = ..()
	if (!.)
		return FALSE

	replace_in_name("%TC%", bonus_tc)
	replace_in_name("%PROGRESSION%", DISPLAY_PROGRESSION(bonus_progression))
	return TRUE

/datum/traitor_objective/sabotage_machinery/trap/prepare_machine(obj/machinery/machine)
	RegisterSignal(machine, COMSIG_TRAITOR_MACHINE_TRAP_TRIGGERED, PROC_REF(sabotage_success))
	return ..()

/// Called when you successfully proc the booby trap, gives a bonus reward
/datum/traitor_objective/sabotage_machinery/trap/proc/sabotage_success(obj/machinery/machine)
	progression_reward += bonus_progression
	telecrystal_reward += bonus_tc
	succeed_objective()

/datum/traitor_objective/sabotage_machinery/trap/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!tool)
		buttons += add_ui_button("", "Pressing this will materialize an explosive trap in your hand, which you can conceal within the target machine", "wifi", "summon_gear")
	return buttons

/datum/traitor_objective/sabotage_machinery/trap/ui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("summon_gear")
			if(tool)
				return
			tool = new(user.drop_location())
			user.put_in_hands(tool)
			tool.balloon_alert(user, "a booby trap materializes in your hand")
			tool.target_machine_path = applicable_jobs[chosen_job]

/// Item which you use on a machine to cause it to explode next time someone interacts with it
/obj/item/traitor_machine_trapper
	name = "suspicious device"
	desc = "It looks dangerous."
	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "boobytrap"

	/// Light explosion range, to hurt the person using the machine
	var/explosion_range = 3
	/// The type of object on which this can be planted on.
	var/obj/machinery/target_machine_path
	/// The time it takes to deploy the bomb.
	var/deploy_time = 10 SECONDS

/obj/item/traitor_machine_trapper/examine(mob/user)
	. = ..()
	if(!user.mind?.has_antag_datum(/datum/antagonist/traitor))
		return
	if(target_machine_path)
		. += span_notice("This device must be placed by <b>clicking on a [initial(target_machine_path.name)]</b> with it. It can be removed with a screwdriver.")
	. += span_notice("Remember, you may leave behind fingerprints on the device. Wear <b>gloves</b> when handling it to be safe!")

/obj/item/traitor_machine_trapper/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!user.Adjacent(target))
		return
	if(!istype(target, target_machine_path))
		balloon_alert(user, "invalid target!")
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	balloon_alert(user, "planting device...")
	if(!do_after(user, delay = deploy_time, target = src, interaction_key = DOAFTER_SOURCE_PLANTING_DEVICE))
		return
	target.AddComponent(\
		/datum/component/interaction_booby_trap,\
		additional_triggers = list(COMSIG_ORM_COLLECTED_ORE),\
		on_triggered_callback = CALLBACK(src, PROC_REF(on_triggered)),\
		on_defused_callback = CALLBACK(src, PROC_REF(on_defused)),\
	)
	RegisterSignal(target, COMSIG_PARENT_QDELETING, GLOBAL_PROC_REF(qdel), src)
	moveToNullspace()

/// Called when applied trap is triggered, mark success
/obj/item/traitor_machine_trapper/proc/on_triggered(atom/machine)
	SEND_SIGNAL(machine, COMSIG_TRAITOR_MACHINE_TRAP_TRIGGERED)
	qdel(src)

/// Called when applied trap has been defused, retrieve this item from nullspace
/obj/item/traitor_machine_trapper/proc/on_defused(atom/machine, mob/defuser, obj/item/tool)
	UnregisterSignal(machine, COMSIG_PARENT_QDELETING)
	playsound(machine, 'sound/effects/structure_stress/pop3.ogg', 100, vary = TRUE)
	forceMove(get_turf(machine))
	visible_message(span_warning("A [src] falls out from the [machine]!"))

/// Datum which manages references to things we are instructed to destroy
/datum/objective_target_machine_handler
	/// Existing instances of machines organised by typepath
	var/list/machine_instances_by_path = list()

/datum/objective_target_machine_handler/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_MACHINE, PROC_REF(on_machine_created))
	RegisterSignal(SSatoms, COMSIG_SUBSYSTEM_POST_INITIALIZE, PROC_REF(finalise_valid_targets))

/// Adds a newly created machine to our list of machines, if we need it
/datum/objective_target_machine_handler/proc/on_machine_created(datum/source, obj/machinery/new_machine)
	SIGNAL_HANDLER
	new_machine.add_as_sabotage_target()

/// Confirm that everything added to the list is a valid target, then prevent new targets from being added
/datum/objective_target_machine_handler/proc/finalise_valid_targets()
	SIGNAL_HANDLER
	for (var/machine_type in machine_instances_by_path)
		for (var/obj/machinery/machine as anything in machine_instances_by_path[machine_type])
			var/turf/place = get_turf(machine)
			if(!place || !is_station_level(place.z))
				machine_instances_by_path[machine_type] -= machine
				continue
			RegisterSignal(machine, COMSIG_PARENT_QDELETING, PROC_REF(machine_destroyed))
	UnregisterSignal(SSdcs, COMSIG_GLOB_NEW_MACHINE)

/datum/objective_target_machine_handler/proc/machine_destroyed(atom/machine)
	SIGNAL_HANDLER
	// Sadly can't do a direct typepath association because of some map helper subtypes
	for (var/machine_type in machine_instances_by_path)
		machine_instances_by_path[machine_type] -= machine

// Mark valid machines as targets, add a new entry here if you add a new potential target

/obj/machinery/telecomms/hub/add_as_sabotage_target()
	return add_sabotage_machine(src, /obj/machinery/telecomms/hub) // Not always our specific type because of map helper subtypes

/obj/machinery/rnd/server/add_as_sabotage_target()
	return add_sabotage_machine(src, type)

/obj/machinery/rnd/production/protolathe/department/add_as_sabotage_target()
	return add_sabotage_machine(src, type)

/obj/machinery/rnd/production/techfab/department/add_as_sabotage_target()
	return add_sabotage_machine(src, type)

/obj/machinery/mineral/ore_redemption/add_as_sabotage_target()
	return add_sabotage_machine(src, type)
