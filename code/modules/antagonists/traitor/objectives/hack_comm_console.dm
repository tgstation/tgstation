/datum/traitor_objective_category/hack_comm_console
	name = "Hack Communication Console"
	objectives = list(
		/datum/traitor_objective/hack_comm_console = 1,
	)

/datum/traitor_objective/hack_comm_console
	name = "Hack a communication console to summon an unknown threat to the station"
	description = "Right click on a communication console to begin the hacking process. Once started, the AI will know that you are hacking a communication console, so be ready to run or have yourself disguised to prevent being caught. This objective will invalidate itself if another traitor completes it first."

	progression_minimum = 60 MINUTES
	progression_reward = list(30 MINUTES, 40 MINUTES)
	telecrystal_reward = list(7, 12)

	var/progression_objectives_minimum = 20 MINUTES

/datum/traitor_objective/hack_comm_console/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	if(SStraitor.get_taken_count(/datum/traitor_objective/hack_comm_console) > 0)
		return FALSE
	if(handler.get_completion_progression(/datum/traitor_objective) < progression_objectives_minimum)
		return FALSE
	AddComponent(/datum/component/traitor_objective_mind_tracker, generating_for, \
		signals = list(COMSIG_HUMAN_EARLY_UNARMED_ATTACK = .proc/on_unarmed_attack))
	RegisterSignal(generating_for, COMSIG_GLOB_TRAITOR_OBJECTIVE_COMPLETED, .proc/on_global_obj_completed)
	return TRUE

/datum/traitor_objective/hack_comm_console/proc/on_global_obj_completed(datum/source, datum/traitor_objective/objective)
	SIGNAL_HANDLER
	if(istype(objective, /datum/traitor_objective/hack_comm_console))
		fail_objective()

/datum/traitor_objective/hack_comm_console/proc/on_unarmed_attack(mob/user, obj/machinery/computer/communications/target, proximity_flag, modifiers)
	SIGNAL_HANDLER
	if(!proximity_flag)
		return
	if(!modifiers[RIGHT_CLICK])
		return
	if(!istype(target))
		return
	target.AI_notify_hack()
	INVOKE_ASYNC(src, .proc/begin_hack, user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/traitor_objective/hack_comm_console/proc/begin_hack(mob/user, obj/machinery/computer/communications/target)
	if(!do_after(user, 30 SECONDS, target))
		return
	succeed_objective()
	switch(rand(0, 1))
		if(0)
			priority_announce("Attention crew, it appears that someone on your station has made unexpected communication with an alien device in nearby space.", "[command_name()] High-Priority Update")
			var/datum/round_event_control/spawn_swarmer/swarmer_event = new/datum/round_event_control/spawn_swarmer
			swarmer_event.runEvent()
		if(1)
			priority_announce("Attention crew, it appears that someone on your station has made unexpected communication with a syndicate ship in nearby space.", "[command_name()] High-Priority Update")
			var/datum/round_event_control/pirates/pirate_event = new/datum/round_event_control/pirates
			pirate_event.runEvent()
