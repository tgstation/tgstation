/datum/round_event_control/bitrunning_glitch
	name = "Spawn Bitrunning Glitch"
	admin_setup = list(
		/datum/event_admin_setup/minimum_candidate_requirement/bitrunning_glitch,
		/datum/event_admin_setup/listed_options/bitrunning_glitch,
	)
	category = EVENT_CATEGORY_INVASION
	description = "Causes a short term antagonist to spawn in the virtual domain."
	dynamic_should_hijack = FALSE
	min_players = 1
	max_occurrences = 0
	typepath = /datum/round_event/ghost_role/bitrunning_glitch
	weight = 100
	/// List of servers on the station
	var/list/datum/weakref/active_servers = list()

/datum/round_event_control/bitrunning_glitch/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	if(!.)
		return .

	active_servers.Cut()

	validate_servers()

	if(length(active_servers))
		return TRUE

/// All servers currently running, has players in it, and map has valid mobs
/datum/round_event_control/bitrunning_glitch/proc/validate_servers()
	active_servers.Cut()
	for(var/obj/machinery/quantum_server/server in SSmachines.get_machines_by_type(/obj/machinery/quantum_server))
		if(server.validate_mutation_candidates() && server.generated_domain.difficulty != BITRUNNER_DIFFICULTY_NONE)
			active_servers.Add(WEAKREF(server))

	return length(active_servers) > 0

/datum/event_admin_setup/listed_options/bitrunning_glitch
	input_text = "Select a role to spawn."

/datum/event_admin_setup/listed_options/bitrunning_glitch/get_list()
	var/list/available = list("Random")
	available += subtypesof(/datum/antagonist/bitrunning_glitch)

	return available

/datum/event_admin_setup/listed_options/bitrunning_glitch/apply_to_event(datum/round_event/ghost_role/bitrunning_glitch/event)
	if(chosen == "Random")
		event.forced_role = null
	else
		event.forced_role = chosen

/datum/event_admin_setup/minimum_candidate_requirement/bitrunning_glitch
	output_text = "There must be valid mobs to mutate!"

/datum/event_admin_setup/minimum_candidate_requirement/bitrunning_glitch/count_candidates()
	var/datum/round_event_control/bitrunning_glitch/cyber_control = event_control

	cyber_control.validate_servers()

	var/total = 0
	for(var/datum/weakref/server_ref in cyber_control.active_servers)
		var/obj/machinery/quantum_server/server = server_ref?.resolve()
		if(isnull(server) || QDELETED(server))
			continue

		total += length(server.mutation_candidate_refs)

	return total

/datum/round_event/ghost_role/bitrunning_glitch
	minimum_required = 1
	role_name = "Bitrunning Glitch"
	fakeable = FALSE
	/// Admin customization: What to spawn
	var/forced_role

/datum/round_event/ghost_role/bitrunning_glitch/spawn_role()
	var/datum/round_event_control/bitrunning_glitch/cyber_control = control
	if(!length(cyber_control.active_servers))
		return WAITING_FOR_SOMETHING

	var/datum/weakref/server_ref = pick(cyber_control.active_servers)
	var/obj/machinery/quantum_server/unlucky_server = server_ref?.resolve()
	if(isnull(unlucky_server))
		return WAITING_FOR_SOMETHING

	cyber_control.active_servers.Cut()
	if(!unlucky_server.validate_mutation_candidates())
		return WAITING_FOR_SOMETHING

	var/mob/spawned = unlucky_server.setup_glitch(forced_role)
	if(isnull(spawned))
		return  WAITING_FOR_SOMETHING

	spawned_mobs += spawned

	return SUCCESSFUL_SPAWN
