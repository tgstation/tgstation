#define ONLY_TURF 1

/// Gives all current occupants a notification that the server is going down
/obj/machinery/quantum_server/proc/begin_shutdown(mob/user)
	if(isnull(generated_domain))
		return

	if(!length(avatar_connection_refs))
		balloon_alert(user, "powering down domain...")
		playsound(src, 'sound/machines/terminal_off.ogg', 40, 2)
		reset()
		return

	balloon_alert(user, "notifying clients...")
	playsound(src, 'sound/machines/terminal_alert.ogg', 100, TRUE)
	user.visible_message(
		span_danger("[user] begins depowering the server!"),
		span_notice("You start disconnecting clients..."),
		span_danger("You hear frantic keying on a keyboard."),
	)

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SHUTDOWN_ALERT, user)

	if(!do_after(user, 20 SECONDS, src))
		return

	reset()

/**
 * ### Quantum Server Cold Boot
 * Procedurally links the 3 booting processes together.
 *
 * This is the starting point if you have an id. Does validation and feedback on steps
 */
/obj/machinery/quantum_server/proc/cold_boot_map(mob/user, map_key)
	if(!is_ready)
		return FALSE

	if(isnull(map_key))
		balloon_alert(user, "no domain specified.")
		return FALSE

	if(generated_domain)
		balloon_alert(user, "stop the current domain first.")
		return FALSE

	if(length(avatar_connection_refs))
		balloon_alert(user, "all clients must disconnect!")
		return FALSE

	is_ready = FALSE
	playsound(src, 'sound/machines/terminal_processing.ogg', 30, 2)

	if(!initialize_domain(map_key) || !initialize_safehouse() || !initialize_map_items())
		balloon_alert(user, "initialization failed.")
		scrub_vdom()
		is_ready = TRUE
		return FALSE

	is_ready = TRUE
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 30, 2)
	balloon_alert(user, "domain loaded.")
	generated_domain.start_time = world.time
	points -= generated_domain.cost
	update_use_power(ACTIVE_POWER_USE)
	update_appearance()

	return TRUE

/// Initializes a new domain if the given key is valid and the user has enough points
/obj/machinery/quantum_server/proc/initialize_domain(map_key)
	var/datum/lazy_template/virtual_domain/to_load

	for(var/datum/lazy_template/virtual_domain/available as anything in subtypesof(/datum/lazy_template/virtual_domain))
		if(map_key != initial(available.key) || points < initial(available.cost))
			continue
		to_load = available
		break

	if(isnull(to_load))
		return FALSE

	generated_domain = new to_load()
	RegisterSignal(generated_domain, COMSIG_LAZY_TEMPLATE_LOADED, PROC_REF(on_template_loaded))
	generated_domain.lazy_load()

	return TRUE

/// Loads in necessary map items, sets mutation targets, etc
/obj/machinery/quantum_server/proc/initialize_map_items()
	var/turf/goal_turfs = list()
	var/turf/crate_turfs = list()

	for(var/thing in GLOB.landmarks_list)
		if(istype(thing, /obj/effect/landmark/bitrunning/hololadder_spawn))
			exit_turfs += get_turf(thing)
			qdel(thing) // i'm worried about multiple servers getting confused so lets clean em up
			continue

		if(istype(thing, /obj/effect/landmark/bitrunning/cache_goal_turf))
			var/turf/tile = get_turf(thing)
			goal_turfs += tile
			RegisterSignal(tile, COMSIG_ATOM_ENTERED, PROC_REF(on_goal_turf_entered))
			RegisterSignal(tile, COMSIG_ATOM_EXAMINE, PROC_REF(on_goal_turf_examined))
			qdel(thing)
			continue

		if(istype(thing, /obj/effect/landmark/bitrunning/cache_spawn))
			crate_turfs += get_turf(thing)
			qdel(thing)
			continue

	if(!length(exit_turfs))
		CRASH("Failed to find exit turfs on generated domain.")
	if(!length(goal_turfs))
		CRASH("Failed to find send turfs on generated domain.")

	if(length(crate_turfs))
		shuffle_inplace(crate_turfs)
		new /obj/structure/closet/crate/secure/bitrunning/encrypted(pick(crate_turfs))

	return TRUE

/// Loads the safehouse
/obj/machinery/quantum_server/proc/initialize_safehouse()
	var/turf/safehouse_load_turf = list()
	for(var/obj/effect/landmark/bitrunning/safehouse_spawn/spawner in GLOB.landmarks_list)
		safehouse_load_turf += get_turf(spawner)
		qdel(spawner)
		break

	if(!length(safehouse_load_turf))
		CRASH("Failed to find safehouse load landmark on map.")

	var/datum/map_template/safehouse/safehouse = new generated_domain.safehouse_path()
	safehouse.load(safehouse_load_turf[ONLY_TURF])
	generated_safehouse = safehouse

	return TRUE

/// Stops the current virtual domain and disconnects all users
/obj/machinery/quantum_server/proc/reset(fast = FALSE)
	is_ready = FALSE

	SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR)

	if(!fast)
		notify_spawned_threats()
		addtimer(CALLBACK(src, PROC_REF(scrub_vdom)), 15 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
	else
		scrub_vdom() // used in unit testing, no need to wait for callbacks

	addtimer(CALLBACK(src, PROC_REF(cool_off)), min(server_cooldown_time * capacitor_coefficient), TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)
	update_appearance()

	update_use_power(IDLE_POWER_USE)
	domain_randomized = FALSE
	domain_threats = 0
	retries_spent = 0

/// Deletes all the tile contents
/obj/machinery/quantum_server/proc/scrub_vdom()
	SEND_SIGNAL(src, COMSIG_BITRUNNER_SEVER_AVATAR) /// just in case someone's connected
	SEND_SIGNAL(src, COMSIG_BITRUNNER_DOMAIN_SCRUBBED) // avatar cleanup just in case

	if(length(generated_domain.reservations))
		var/datum/turf_reservation/res = generated_domain.reservations[1]
		res.Release()

	var/list/datum/weakref/creatures = spawned_threat_refs + mutation_candidate_refs
	for(var/datum/weakref/creature_ref as anything in creatures)
		var/mob/living/creature = creature_ref?.resolve()
		if(isnull(creature))
			continue

		creature.dust() // sometimes mobs just don't die

	avatar_connection_refs.Cut()
	exit_turfs = list()
	generated_domain = null
	generated_safehouse = null
	mutation_candidate_refs.Cut()
	spawned_threat_refs.Cut()

#undef ONLY_TURF
