/datum/traitor_objective_category/sabotage_machinery
	name = "Sabotage Worksite"
	objectives = list(
		/datum/traitor_objective/sabotage_machinery = 1,
	)

/datum/traitor_objective/sabotage_machinery
	name = "Sabotage the %MACHINE%"
	description = "Conceal the provided explosive device within the %MACHINE% to cause disarray and disrupt the operations of the %JOB%'s department."

	progression_reward = list(2 MINUTES, 8 MINUTES)
	telecrystal_reward = list(0, 1)

	progression_minimum = 0 MINUTES
	progression_maximum = 10 MINUTES

	/// The maximum amount of this type of objective a traitor can have.
	var/maximum_allowed = 2
	/// The possible target machinery and the jobs tied to each one.
	var/list/applicable_jobs = list(
		JOB_RESEARCH_DIRECTOR = /obj/machinery/rnd/production/protolathe/department/science,
		JOB_CHIEF_MEDICAL_OFFICER = /obj/machinery/rnd/production/techfab/department/medical,
		JOB_CHIEF_ENGINEER = /obj/machinery/rnd/production/protolathe/department/engineering,
		JOB_HEAD_OF_PERSONNEL = /obj/machinery/rnd/production/techfab/department/service,
		JOB_SHAFT_MINER = /obj/machinery/mineral/ore_redemption,
		JOB_QUARTERMASTER = /obj/machinery/rnd/production/techfab/department/cargo,
	)
	/// The chosen job. Used to check for duplicates
	var/chosen_job

	var/obj/item/traitor_machine_trapper/tool

/datum/traitor_objective/sabotage_machinery/can_generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(length(possible_duplicates) >= maximum_allowed)
		return FALSE
	return TRUE

/datum/traitor_objective/sabotage_machinery/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	for(var/datum/traitor_objective/sabotage_machinery/objective as anything in possible_duplicates)
		applicable_jobs -= objective.chosen_job
	if(!length(applicable_jobs))
		return FALSE
	var/list/obj/machinery/possible_machines = list()
	while(length(possible_machines) <= 0 && length(applicable_jobs) > 0)
		var/target_head = pick(applicable_jobs)
		var/obj/machinery/machine_to_find = applicable_jobs[target_head]
		applicable_jobs -= target_head

		chosen_job = target_head
		for(var/obj/machinery/machine as anything in GLOB.machines)
			if(istype(machine, machine_to_find) && is_station_level(machine.z))
				possible_machines += machine

	if(!length(possible_machines))
		return FALSE

	for(var/obj/machinery/machine as anything in possible_machines)
		AddComponent(/datum/component/traitor_objective_register, machine, succeed_signals = list(COMSIG_PARENT_QDELETING))

	replace_in_name("%JOB%", lowertext(chosen_job))
	replace_in_name("%MACHINE%", possible_machines[1].name)
	return TRUE

/// Item which you use on a machine to cause it to explode next time someone interacts with it
/obj/item/traitor_machine_trapper/
	name = "suspicious device"
	desc = "It looks dangerous."
	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "bug"

	/// How much we explode, it only does a light explosion
	var/explosion_range = 3
	/// The type of object on which this can be planted on.
	var/obj/structure/target_machine_path
	/// The time it takes to deploy the bomb.
	var/deploy_time = 10 SECONDS

/obj/item/traitor_machine_trapper/examine(mob/user)
	. = ..()
	if(!user.mind?.has_antag_datum(/datum/antagonist/traitor))
		return
	if(target_object_type)
		. += span_notice("This device must be placed by <b>clicking on a [initial(target_machine_path.name)]</b> with it. It can be removed with a screwdriver.")
	. += span_notice("Remember, you may leave behind fingerprints on the device. Wear <b>gloves</b> when handling it to be safe!")

/obj/item/traitor_machine_trapper/afterattack(atom/movable/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!target_machine_path)
		return
	if(!user.Adjacent(target))
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	balloon_alert(user, "planting device...")
	if(!do_after(user, deploy_time, src))
		return
	forceMove(target)
	RegisterSignal(target, COMSIG_ATOM_UI_INTERACT, PROC_REF(trigger_explosive))

/obj/item/traitor_machine_trapper/proc/trigger_explosive(obj/structure/attached_machine)
	SIGNAL_HANDLER

	explosion(origin = attached_machine, light_impact_range = explosion_range, explosion_cause = src)
	SEND_SIGNAL(src, COMSIG_TRAITOR_MACHINE_TRAP_TRIGGERED, attached_machine)
	qdel(src)
