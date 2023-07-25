/datum/round_event_control/void_sentinel
	name = "Spawn Void Sentinel"
	typepath = /datum/round_event/ghost_role/void_sentinel
	weight = 10
	max_occurrences = 5
	category = EVENT_CATEGORY_INVASION
	dynamic_should_hijack = TRUE
	description = "Compiles a binary marshal to ensure data integrity in the virtual domain."
	admin_setup = list(/datum/event_admin_setup/minimum_candidate_requirement/void_sentinel)
	/// Mob candidates that can be converted into a sentinel.
	var/list/mutation_candidates = list()

/datum/round_event_control/void_sentinel/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	if(!.)
		return .

	generate_candidates()
	if(length(mutation_candidates))
		return TRUE

/datum/round_event_control/void_sentinel/proc/generate_candidates()
	mutation_candidates.Cut()

	for(var/obj/machinery/quantum_server/server as anything in SSmachines.get_machines_by_type(/obj/machinery/quantum_server))
		if(!length(server.occupant_mind_refs) || isnull(server.generated_domain))
			continue

		for(var/mob/living/creature as anything in server.generated_domain.created_atoms)
			if(QDELETED(creature) || !isliving(creature) || creature.key)
				continue

			mutation_candidates += creature

/datum/round_event/ghost_role/void_sentinel
	minimum_required = 1
	role_name = "void_sentinel"
	fakeable = FALSE

/datum/round_event/ghost_role/void_sentinel/spawn_role()
	var/datum/round_event_control/void_sentinel/sentinel_control = control
	var/mob/living/mutation_target = pick(sentinel_control.mutation_candidates)
	if(isnull(mutation_target))
		return MAP_ERROR

	sentinel_control.mutation_candidates.Cut()

	var/list/candidates = get_candidates(ROLE_VOID_SENTINEL)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/new_agent = new(mutation_target.loc)
	mutation_target.gib()
	mutation_target = null

	new_agent.equipOutfit(/datum/outfit/void_sentinel)
	new_agent.fully_replace_character_name(new_agent.name, pick(GLOB.sentinel_names))

	player_mind.transfer_to(new_agent)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/void_sentinel))
	player_mind.special_role = ROLE_VOID_SENTINEL
	player_mind.add_antag_datum(/datum/antagonist/void_sentinel)

	playsound(new_agent, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(new_agent)] has been made into a Void Sentinel by an event.")
	new_agent.log_message("was spawned as a Void Sentinel by an event.", LOG_GAME)
	spawned_mobs += new_agent

	return SUCCESSFUL_SPAWN

/datum/event_admin_setup/minimum_candidate_requirement/void_sentinel
	output_text = "There are no mobs eligible to mutate into a void sentinel!"

/datum/event_admin_setup/minimum_candidate_requirement/void_sentinel/count_candidates()
	var/datum/round_event_control/void_sentinel/sentinel_control = event_control
	sentinel_control.generate_candidates()
	return length(sentinel_control.mutation_candidates)
