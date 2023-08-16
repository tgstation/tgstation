/datum/round_event_control/cyber_police
	name = "Spawn Cyber Police"
	typepath = /datum/round_event/ghost_role/cyber_police
	weight = 10
	max_occurrences = 5
	category = EVENT_CATEGORY_INVASION
	dynamic_should_hijack = TRUE
	description = "Compiles a binary marshal to ensure data integrity in the virtual domain."
	admin_setup = list(/datum/event_admin_setup/minimum_candidate_requirement/cyber_police)
	/// Mob candidates that can be converted into a sentinel.
	var/list/mutation_candidates = list()
	/// Reference to the target server
	var/datum/weakref/server_ref

/datum/round_event_control/cyber_police/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	if(!.)
		return .

	generate_candidates()
	if(length(mutation_candidates))
		return TRUE

/// Loaded domains save created_atoms, so we iterate over these lists to see if there are any valid mob/living targets that aren't players etc
/datum/round_event_control/cyber_police/proc/generate_candidates()
	mutation_candidates.Cut()

	var/obj/machinery/quantum_server/server = locate(/obj/machinery/quantum_server) in SSmachines.get_all_machines(/obj/machinery/quantum_server)
	if(isnull(server))
		return

	mutation_candidates += server.get_valid_domain_targets()

	if(length(mutation_candidates))
		server_ref = WEAKREF(server)

/datum/round_event/ghost_role/cyber_police
	minimum_required = 1
	role_name = "Cyber Police"
	fakeable = FALSE

/datum/round_event/ghost_role/cyber_police/spawn_role()
	var/datum/round_event_control/cyber_police/cyber_control = control
	var/obj/machinery/quantum_server/server = cyber_control.server_ref?.resolve()
	if(isnull(server))
		return MAP_ERROR

	var/mob/living/mutation_target = pick(cyber_control.mutation_candidates)
	if(isnull(mutation_target))
		return MAP_ERROR

	cyber_control.mutation_candidates.Cut()

	var/list/candidates = get_candidates(ROLE_CYBER_POLICE)
	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/mob/living/carbon/human/new_agent = new(mutation_target.loc)
	mutation_target.gib()
	mutation_target = null

	new_agent.equipOutfit(/datum/outfit/cyber_police)
	new_agent.fully_replace_character_name(new_agent.name, pick(GLOB.cyberauth_names))

	player_mind.transfer_to(new_agent)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/cyber_police))
	player_mind.special_role = ROLE_CYBER_POLICE
	player_mind.add_antag_datum(/datum/antagonist/cyber_police)

	SEND_SIGNAL(server, COMSIG_BITRUNNER_COP_SPAWNED, new_agent)

	playsound(new_agent, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(new_agent)] has been made into Cyber Police by an event.")
	new_agent.log_message("was spawned as a Cyber Police by an event.", LOG_GAME)
	spawned_mobs += new_agent

	return SUCCESSFUL_SPAWN

/datum/event_admin_setup/minimum_candidate_requirement/cyber_police
	output_text = "There must be valid mobs to mutate or players in the domain!"

/datum/event_admin_setup/minimum_candidate_requirement/cyber_police/count_candidates()
	var/datum/round_event_control/cyber_police/cyber_control = event_control
	cyber_control.generate_candidates()
	return length(cyber_control.mutation_candidates)
