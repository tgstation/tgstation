/datum/traitor_objective_category/demoralise
	name = "Demoralise Crew"
	objectives = list(
		/datum/traitor_objective/target_player/assault = 1,
		/datum/traitor_objective/destroy_item/demoralise = 1,
	)
	weight = OBJECTIVE_WEIGHT_UNLIKELY

/datum/traitor_objective/target_player/assault
	name = "Assault %TARGET% the %JOB TITLE%"
	description = "%TARGET% has been identified as a potential future agent. \
		Pick a fight and give them a good beating. \
		%COUNT% hits should reduce their morale and have them questioning their loyalties. \
		Try not to kill them just yet, we may want to recruit them in the future."

	abstract_type = /datum/traitor_objective/target_player
	duplicate_type = /datum/traitor_objective/target_player

	progression_minimum = 0 MINUTES
	progression_maximum = 30 MINUTES
	progression_reward = list(4 MINUTES, 8 MINUTES)
	telecrystal_reward = list(0, 1)

	/// Min attacks required to pass the objective. Picked at random between this and max.
	var/min_attacks_required = 2
	/// Max attacks required to pass the objective. Picked at random between this and min.
	var/max_attacks_required = 5
	/// The random number picked for the number of required attacks to pass this objective.
	var/attacks_required = 0
	/// Total number of successful attacks recorded.
	var/attacks_inflicted = 0

/datum/traitor_objective/target_player/assault/on_objective_taken(mob/user)
	. = ..()

	target.AddElement(/datum/element/relay_attackers)
	RegisterSignal(target, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/datum/traitor_objective/target_player/assault/proc/on_attacked(mob/source, mob/living/attacker, attack_flags)
	SIGNAL_HANDLER

	// Only care about attacks from the objective's owner.
	if(attacker != handler.owner.current)
		return

	// We want some sort of damaging attack to trigger this, rather than shoves and non-lethals.
	if(!(attack_flags & ATTACKER_DAMAGING_ATTACK))
		return

	attacks_inflicted++

	if(attacks_inflicted == attacks_required)
		succeed_objective()

/datum/traitor_objective/target_player/assault/ungenerate_objective()
	UnregisterSignal(target, COMSIG_ATOM_WAS_ATTACKED)
	UnregisterSignal(target, COMSIG_LIVING_DEATH)
	UnregisterSignal(target, COMSIG_QDELETING)

	target = null

/datum/traitor_objective/target_player/assault/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/already_targeting = list() //List of minds we're already targeting. The possible_duplicates is a list of objectives, so let's not mix things
	for(var/datum/objective/task as anything in handler.primary_objectives)
		if(!istype(task.target, /datum/mind))
			continue
		already_targeting += task.target //Removing primary objective kill targets from the list

	var/list/possible_targets = list()

	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target in already_targeting)
			continue

		if(possible_target == generating_for)
			continue

		if(!ishuman(possible_target.current))
			continue

		if(possible_target.current.stat == DEAD)
			continue

		if(possible_target.has_antag_datum(/datum/antagonist/traitor))
			continue

		possible_targets += possible_target

	for(var/datum/traitor_objective/target_player/objective as anything in possible_duplicates)
		possible_targets -= objective.target?.mind

	if(generating_for.late_joiner)
		var/list/all_possible_targets = possible_targets.Copy()
		for(var/datum/mind/possible_target as anything in all_possible_targets)
			if(!possible_target.late_joiner)
				possible_targets -= possible_target
		if(!possible_targets.len)
			possible_targets = all_possible_targets

	if(!possible_targets.len)
		return FALSE

	var/datum/mind/target_mind = pick(possible_targets)

	target = target_mind.current
	replace_in_name("%TARGET%", target.real_name)
	replace_in_name("%JOB TITLE%", target_mind.assigned_role.title)

	attacks_required = rand(min_attacks_required, max_attacks_required)
	replace_in_name("%COUNT%", attacks_required)

	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_target_death))
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_qdeleted))

	return TRUE

/datum/traitor_objective/target_player/assault/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(attacks_required > attacks_inflicted)
		buttons += add_ui_button("[attacks_required - attacks_inflicted]", "This tells you how many more times you have to attack the target player to succeed.", "hand-rock-o", "none")
	return buttons

/datum/traitor_objective/target_player/assault/proc/on_target_qdeleted()
	SIGNAL_HANDLER

	//don't take an objective target of someone who is already obliterated
	fail_objective()

/datum/traitor_objective/target_player/assault/proc/on_target_death()
	SIGNAL_HANDLER

	//don't take an objective target of someone who is already dead
	fail_objective()
