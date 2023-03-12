/datum/traitor_objective_category/destroy_heirloom
	name = "Destroy Heirloom"
	objectives = list(
		list(
			// There's about 16 jobs in common, so assistant has a 1/21 chance of getting chosen.
			/datum/traitor_objective/destroy_heirloom/common = 20,
			/datum/traitor_objective/destroy_heirloom/common/assistant = 1,
		) = 4,
		/datum/traitor_objective/destroy_heirloom/uncommon = 3,
		/datum/traitor_objective/destroy_heirloom/rare = 2,
		/datum/traitor_objective/destroy_heirloom/captain = 1
	)

/datum/traitor_objective/destroy_heirloom
	name = "Destroy %ITEM%, the family heirloom that belongs to %TARGET% the %JOB TITLE%"
	description = "%TARGET% has been on our shitlist for a while and we want to show them we mean business. Find their %ITEM% and destroy it."

	abstract_type = /datum/traitor_objective/destroy_heirloom

	/// The jobs that this objective is targetting.
	var/list/target_jobs
	/// the item we need to destroy
	var/obj/item/target_item
	/// the owner of the item we need to destroy
	var/datum/mind/target_mind

	// The code below is for limiting how often you can get this objective. You will get this objective at a maximum of maximum_objectives_in_period every objective_period
	/// The objective period at which we consider if it is an 'objective'. Set to 0 to accept all objectives.
	var/objective_period = 10 MINUTES
	/// The maximum number of objectives that can be taken in this period.
	var/maximum_objectives_in_period = 2

/datum/traitor_objective/destroy_heirloom/common
	/// 30 minutes in, syndicate won't care about common heirlooms anymore
	progression_minimum = 0 MINUTES
	progression_maximum = 30 MINUTES
	progression_reward = list(8 MINUTES, 12 MINUTES)
	telecrystal_reward = list(1, 2)
	target_jobs = list(
		// Medical
		/datum/job/doctor,
		/datum/job/virologist,
		/datum/job/paramedic,
		/datum/job/psychologist,
		/datum/job/chemist,
		// Service
		/datum/job/clown,
		/datum/job/botanist,
		/datum/job/janitor,
		/datum/job/mime,
		/datum/job/lawyer,
		// Cargo
		/datum/job/cargo_technician,
		// Science
		/datum/job/geneticist,
		/datum/job/scientist,
		/datum/job/roboticist,
		// Engineering
		/datum/job/station_engineer,
		/datum/job/atmospheric_technician,
	)

/// This is only for assistants, because the syndies are a lot less likely to give a shit about what an assistant does, so they're a lot less likely to appear
/datum/traitor_objective/destroy_heirloom/common/assistant
	target_jobs = list(
		/datum/job/assistant
	)

/datum/traitor_objective/destroy_heirloom/uncommon
	/// 45 minutes in, syndicate won't care about uncommon heirlooms anymore
	progression_minimum = 0 MINUTES
	progression_maximum = 45 MINUTES
	progression_reward = list(8 MINUTES, 12 MINUTES)
	telecrystal_reward = list(1, 2)
	target_jobs = list(
		// Cargo
		/datum/job/shaft_miner,
		// Service
		/datum/job/chaplain,
		/datum/job/bartender,
		/datum/job/cook,
		/datum/job/curator,
	)

/datum/traitor_objective/destroy_heirloom/rare
	progression_minimum = 15 MINUTES
	/// 60 minutes in, syndicate won't care about rare heirlooms anymore
	progression_maximum = 60 MINUTES
	progression_reward = list(10 MINUTES, 14 MINUTES)
	telecrystal_reward = list(2, 3)
	target_jobs = list(
		// Security
		/datum/job/security_officer,
		/datum/job/warden,
		/datum/job/detective,
		// Heads of staff
		/datum/job/head_of_personnel,
		/datum/job/chief_medical_officer,
		/datum/job/research_director,
		/datum/job/quartermaster,
	)

/datum/traitor_objective/destroy_heirloom/captain
	progression_minimum = 30 MINUTES
	progression_reward = list(10 MINUTES, 14 MINUTES)
	telecrystal_reward = 4
	target_jobs = list(
		/datum/job/head_of_security,
		/datum/job/captain
	)

/datum/traitor_objective/destroy_heirloom/New(datum/uplink_handler/handler)
	. = ..()
	AddComponent(/datum/component/traitor_objective_limit_per_time, \
		/datum/traitor_objective/destroy_heirloom, \
		time_period = objective_period, \
		maximum_objectives = maximum_objectives_in_period \
	)

/datum/traitor_objective/destroy_heirloom/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_targets = list()
	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target == generating_for)
			continue
		if(!ishuman(possible_target.current))
			continue
		var/datum/quirk/item_quirk/family_heirloom/quirk = locate() in possible_target.current.quirks
		if(!quirk || !quirk.heirloom.resolve())
			continue
		if(!(possible_target.assigned_role.type in target_jobs))
			continue
		possible_targets += possible_target
	for(var/datum/traitor_objective/destroy_heirloom/objective as anything in possible_duplicates)
		possible_targets -= objective.target_mind
	if(!length(possible_targets))
		return FALSE
	target_mind = pick(possible_targets)
	AddComponent(/datum/component/traitor_objective_register, target_mind.current, fail_signals = list(COMSIG_PARENT_QDELETING))
	var/datum/quirk/item_quirk/family_heirloom/quirk = locate() in target_mind.current.quirks
	target_item = quirk.heirloom.resolve()
	AddComponent(/datum/component/traitor_objective_register, target_item, succeed_signals = list(COMSIG_PARENT_QDELETING))
	replace_in_name("%TARGET%", target_mind.name)
	replace_in_name("%JOB TITLE%", target_mind.assigned_role.title)
	replace_in_name("%ITEM%", target_item.name)
	return TRUE

/datum/traitor_objective/destroy_heirloom/ungenerate_objective()
	target_item = null
	target_mind = null
