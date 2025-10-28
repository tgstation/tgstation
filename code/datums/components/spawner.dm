

/datum/component/spawner
	/// Time to wait between spawns
	var/spawn_time
	/// Visible message to show when something spawns
	var/spawn_text
	/// List of atom types to spawn, picked randomly
	var/list/spawn_types
	/// Faction to grant to mobs (only applies to mobs)
	var/list/faction
	/// Callback to a proc that is called when a mob is spawned. Primarily used for sentient spawners.
	var/datum/callback/spawn_callback

	/// How many mobs can we spawn maximum each time we try to spawn? (1 - max) This number is applied 
	var/max_spawn_per_attempt
	/// How many types of mobs, taken from spawn_types, will be spawned in every spawn attempt?
	var/max_spawn_types_per_attempt
	/// Maximum number of atoms we can have active at one time
	var/max_spawned
	/// List of weak references to things we have already created
	var/list/spawned_things = list()

	/// Distance from the spawner to spawn mobs
	var/spawn_distance
	/// Distance from the spawner to exclude mobs from spawning
	var/spawn_distance_exclude

	/// Visual Effect to spawn before the mobs spawn in that location.
	var/obj/effect/temp_visual/effect
	/// How long of a pause do we use between the effect spawning, and the mob spawning.
	var/spawn_windup

	/// What type of behavior does this spawner have?
	var/spawner_logic
	/// If using SPAWN_BY_WAVE_BEHAVIOR, how many waves should spawn before the spawner component shuts down?
	var/max_waves
	/// Number of waves of mobs that have been spawned. Only tracked with SPAWN_BY_WAVE_BEHAVIOR.
	var/completed_waves = 0

	COOLDOWN_DECLARE(spawn_delay)

/datum/component/spawner/Initialize(
	spawn_types = list(),
	spawn_time = 30 SECONDS,
	max_spawned = 5,
	max_spawn_per_attempt = 1,
	max_spawn_types_per_attempt = 1,
	faction = list(FACTION_MINING),
	spawn_text = null,
	datum/callback/spawn_callback = null,
	spawn_distance = 1,
	spawn_distance_exclude = 0,
	initial_spawn_delay = 0 SECONDS,
	spawner_logic = SPAWN_CONTINUOUS_BEHAVIOR,
	max_waves = 1,
	effect = null,
	spawn_windup = 0.5 SECONDS
)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	if (!islist(spawn_types))
		CRASH("invalid spawn_types to spawn specified for spawner component!")

	src.spawn_time = spawn_time
	src.spawn_types = spawn_types
	src.faction = faction
	src.spawn_text = spawn_text
	src.max_spawned = max_spawned
	src.spawn_callback = spawn_callback
	src.max_spawn_per_attempt = max_spawn_per_attempt
	src.max_spawn_types_per_attempt = max_spawn_types_per_attempt
	src.spawn_distance = spawn_distance
	src.spawn_distance_exclude = spawn_distance_exclude
	// If set, doesn't instantly spawn a creature when the spawner component is applied.
	if(initial_spawn_delay)
		COOLDOWN_START(src, spawn_delay, spawn_time)
	src.spawner_logic = spawner_logic
	if(spawner_logic == SPAWN_BY_WAVE_BEHAVIOR)
		src.max_waves =  max_waves
	src.effect = effect
	if(effect)
		src.spawn_windup = spawn_windup

	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(stop_spawning))
	START_PROCESSING((spawn_time < 2 SECONDS ? SSfastprocess : SSprocessing), src)

/datum/component/spawner/process()
	try_spawn_mob()

/// Stop spawning mobs
/datum/component/spawner/proc/stop_spawning(force)
	SIGNAL_HANDLER

	STOP_PROCESSING(SSprocessing, src)
	spawned_things = list()

/// Determine if we can spawn a mob based on the current spawn logic.
/datum/component/spawner/proc/check_spawn_availability(mobs_spawned)
	if(!spawner_logic)
		CRASH("A spawner was created without selecting it's spawning logic!")

	validate_references()
	switch(spawner_logic)
		if(SPAWN_CONTINUOUS_BEHAVIOR)
			if(mobs_spawned >= max_spawned)
				return FALSE
		if(SPAWN_BY_WAVE_BEHAVIOR)
			if(mobs_spawned) //If any mobs are still alive.
				return FALSE
			if(completed_waves >= max_waves)
				stop_spawning()
				SEND_SIGNAL(parent, COMSIG_VENT_WAVE_CONCLUDED)
				return FALSE
			completed_waves++
			var/atom/spawner_atom = parent
			spawner_atom.balloon_alert_to_viewers("wave [completed_waves]/[max_waves]")
	return TRUE

/// Try to create a new mob
/datum/component/spawner/proc/try_spawn_mob()
	if(!length(spawn_types))
		return
	if(!COOLDOWN_FINISHED(src, spawn_delay))
		return
	var/spawned_total = length(spawned_things)
	if(!check_spawn_availability(spawned_total))
		return
	var/atom/spawner = parent
	COOLDOWN_START(src, spawn_delay, spawn_time)
	var/list/local_spawn_types = spawn_types.Copy()
	for(var/i in 1 to max_spawn_types_per_attempt)
		var/chosen_mob_type = pick_n_take(local_spawn_types) //This way we avoid duplicates when spawning.
		var/adjusted_spawn_count = 1
		var/max_spawn_this_attempt = min(max_spawn_per_attempt, max_spawned - spawned_total)
		if (max_spawn_this_attempt > 1)
			adjusted_spawn_count = rand(1, max_spawn_this_attempt)
		for(var/j in 1 to adjusted_spawn_count)
			var/atom/created
			var/turf/picked_spot = pick_turf(spawner)
			if(!effect || (effect && !spawn_windup))
				created = new chosen_mob_type(picked_spot)
			else
				new effect(picked_spot)
				addtimer(CALLBACK(src, PROC_REF(delayed_mob_spawn), picked_spot, chosen_mob_type, spawner), spawn_windup)

			if(created)
				setup_spawned_mob(created, spawner)

/**
 * This proc determines the tile that a spawner will place a mob on.
 * @param: atom/spawner: typed definition of the parent, used to send a signal in case a mob spawns to the default position, as well as center our circles to pick turfs from.
 */
/datum/component/spawner/proc/pick_turf(atom/spawner)
	var/turf/picked_spot
	if(spawn_distance == 1)
		picked_spot = spawner.loc
	else if(spawn_distance >= 1 && spawn_distance_exclude >= 1)
		picked_spot = pick(turf_peel(spawn_distance, spawn_distance_exclude, spawner.loc, view_based = TRUE))
		if(!picked_spot)
			picked_spot = pick(circle_range_turfs(spawner.loc, spawn_distance))
		if(picked_spot == spawner.loc)
			SEND_SIGNAL(spawner, COMSIG_SPAWNER_SPAWNED_DEFAULT)
	else if (spawn_distance >= 1)
		picked_spot = pick(circle_range_turfs(spawner.loc, spawn_distance))
	return picked_spot

/**
 * Adds handling to the created mob from the spawner component,
 * such as adding to spawned_things list,
 * weakrefs to the spawned_things list, and registering relevant signals.
 *
 * @param: turf/picked_spot: Turf to spawn the mob onto.
 * @param: mob/chosen_mob_type: Type of mob to spawn.
 * @param: atom/spawner: type definition of parent, passed for further setup on setup_spawned_mob.
 */
/datum/component/spawner/proc/delayed_mob_spawn(turf/picked_spot, mob/chosen_mob_type, atom/spawner)
	if(!picked_spot)
		stack_trace("Incorrect parameters for delayed mob spawn!")
		return

	var/atom/created = new chosen_mob_type(picked_spot)
	if(!created)
		CRASH("Failed to spawn mob!")
	setup_spawned_mob(created, spawner)

/**
 * Registers signals and flags onto a component spawned mob, to keep track of the spawned mob, as well as prevent them from getting treated as naturally spawned.
 * @param: mob/spawned_mob: Mob to have signals sent to/registered onto.
 * @param: atom/spawner:
 */
/datum/component/spawner/proc/setup_spawned_mob(mob/spawned_mob, atom/spawner)
	spawned_mob.flags_1 |= (spawner.flags_1 & ADMIN_SPAWNED_1)
	spawned_things += WEAKREF(spawned_mob)

	if(isliving(spawned_mob))
		var/mob/living/created_mob = spawned_mob
		created_mob.faction = src.faction
		RegisterSignal(created_mob, COMSIG_MOB_STATCHANGE, PROC_REF(mob_stat_changed))

	SEND_SIGNAL(src, COMSIG_SPAWNER_SPAWNED, spawned_mob)
	RegisterSignal(spawned_mob, COMSIG_QDELETING, PROC_REF(on_deleted))
	spawn_callback?.Invoke(spawned_mob)

	if(spawn_text)
		spawner.visible_message(span_danger("A [spawned_mob] [spawn_text] [spawner]."))


/// Remove weakrefs to atoms which have been killed or deleted without us picking it up somehow
/datum/component/spawner/proc/validate_references()
	for (var/datum/weakref/weak_thing as anything in spawned_things)
		var/atom/previously_spawned = weak_thing?.resolve()
		if (!previously_spawned)
			spawned_things -= weak_thing
			continue
		if (!isliving(previously_spawned))
			continue
		var/mob/living/spawned_mob = previously_spawned
		if (spawned_mob.stat != DEAD)
			continue
		spawned_things -= weak_thing

/// Called when an atom we spawned is deleted, remove it from the list
/datum/component/spawner/proc/on_deleted(atom/source)
	SIGNAL_HANDLER
	spawned_things -= WEAKREF(source)

/// Called when a mob we spawned dies, remove it from the list and unregister signals
/datum/component/spawner/proc/mob_stat_changed(mob/living/source)
	if(source.stat != DEAD)
		return
	spawned_things -= WEAKREF(source)
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_MOB_STATCHANGE))
