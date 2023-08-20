/**
 * Every so often the server will produce "glitches" which take the form of antags or other.
 *
 * Basically, I wanted ghost role antags specifically for the virtual domain but I did not want to take from normal events or dynamic.
 */
SUBSYSTEM_DEF(bitrunning)
	name = "Bitrunning"
	flags = SS_BACKGROUND
	wait = 1 MINUTES
	runlevels = RUNLEVEL_GAME
	/// Cooldown before we can spawn again
	COOLDOWN_DECLARE(glitch_cooldown)
	/// The servers currently processing domains
	var/list/datum/weakref/active_servers = list()
	/// Amount of time in between spawning
	var/glitch_frequency = 10 MINUTES
	/// Antags that can be spawned from the servers
	var/static/list/possible_antags = list(
		ROLE_CYBER_POLICE,
	)

/datum/controller/subsystem/bitrunning/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/bitrunning/fire()
	if(!length(active_servers) || !COOLDOWN_FINISHED(src, glitch_cooldown) || prob(95))
		return

	if(initialize_glitch())
		COOLDOWN_START(src, glitch_cooldown, glitch_frequency)

/// Adds a server once it starts processing a domain
/datum/controller/subsystem/bitrunning/proc/add_server(obj/machinery/quantum_server/server)
	var/datum/weakref/server_ref = WEAKREF(server)
	if(!locate(server_ref) in active_servers)
		active_servers.Add(server_ref)

/// Polls for a ghost that wants to run it
/datum/controller/subsystem/bitrunning/proc/get_ghost_mind(role_name)
	var/list/mob/dead/observer/ghosties = poll_ghost_candidates("A short term antagonist role is available. Would you like to spawn as a '[role_name]'?", role_name)

	if(!length(ghosties))
		return

	shuffle_inplace(ghosties)

	var/mob/dead/selected = pick(ghosties)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	return player_mind

/// Generates a list of candidates for mutation into antags
/datum/controller/subsystem/bitrunning/proc/get_mutation_candidates()
	var/list/mutation_candidates = list()

	for(var/datum/weakref/server_ref in active_servers)
		var/obj/machinery/quantum_server/server = server_ref.resolve()
		if(isnull(server))
			active_servers.Remove(server_ref)
			continue

		var/list/mob/living/targets = server.get_valid_domain_targets()
		if(!length(targets))
			continue

		var/list/candidates_assoc = list(list(
			server = server,
			candidates = targets,
		))

		mutation_candidates += candidates_assoc

	return shuffle(mutation_candidates)

/// Procedurally chains the spawn events together to create a glitch
/datum/controller/subsystem/bitrunning/proc/initialize_glitch(forced_role)
	var/list/mutation_candidates = get_mutation_candidates()
	if(!length(mutation_candidates))
		return

	var/chosen = pick(mutation_candidates)
	if(isnull(chosen) || !length(chosen["candidates"]))
		return

	var/obj/machinery/quantum_server/server = chosen["server"]

	var/mob/living/mutation_target = pick(chosen["candidates"])

	var/chosen_role = forced_role || pick(possible_antags)

	var/datum/mind/ghost_mind = get_ghost_mind(chosen_role)

	var/mob/living/antag_mob
	switch(chosen_role)
		if(ROLE_CYBER_POLICE)
			antag_mob = spawn_cybercop(mutation_target, ghost_mind)

	playsound(antag_mob, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(antag_mob)] has been made into virtual antagonist by an event.")
	antag_mob.log_message("was spawned as a virtual antagonist by an event.", LOG_GAME)

	SEND_SIGNAL(server, COMSIG_BITRUNNER_SPAWN_GLITCH, antag_mob)

	return antag_mob

/// Removes a server once it stops processing a domain
/datum/controller/subsystem/bitrunning/proc/remove_server(obj/machinery/quantum_server/server)
	var/datum/weakref/server_ref = WEAKREF(server)
	if(locate(server_ref) in active_servers)
		active_servers.Remove(server_ref)

/// Spawns a cybercop on the mutation target
/datum/controller/subsystem/bitrunning/proc/spawn_cybercop(mob/living/mutation_target, datum/mind/player_mind)
	var/mob/living/carbon/human/new_agent = new(mutation_target.loc)
	mutation_target.gib()
	mutation_target = null

	player_mind.transfer_to(new_agent)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/cyber_police))
	player_mind.special_role = ROLE_CYBER_POLICE
	player_mind.add_antag_datum(/datum/antagonist/cyber_police)

	return new_agent
