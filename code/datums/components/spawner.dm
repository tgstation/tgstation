/datum/component/spawner
	/// Time to wait between spawns
	var/spawn_time
	/// Maximum number of atoms we can have active at one time
	var/max_spawned
	/// Visible message to show when something spawns
	var/spawn_text
	/// List of atom types to spawn, picked randomly
	var/list/spawn_types
	/// Faction to grant to mobs (only applies to mobs)
	var/list/faction
	/// List of weak references to things we have already created
	var/list/spawned_things = list()
	/// Callback to a proc that is called when a mob is spawned. Primarily used for sentient spawners.
	var/datum/callback/spawn_callback
	/// How many mobs can we spawn maximum each time we try to spawn? (1 - max)
	var/max_spawn_per_attempt
	/// Distance from the spawner to spawn mobs
	var/spawn_distance
	/// Distance from the spawner to exclude mobs from spawning
	var/spawn_distance_exclude
	COOLDOWN_DECLARE(spawn_delay)

/datum/component/spawner/Initialize(spawn_types = list(), spawn_time = 30 SECONDS, max_spawned = 5, max_spawn_per_attempt = 1 , faction = list(FACTION_MINING), spawn_text = null, datum/callback/spawn_callback = null, spawn_distance = 1, spawn_distance_exclude = 0, initial_spawn_delay = 0 SECONDS)
	if (!islist(spawn_types))
		CRASH("invalid spawn_types to spawn specified for spawner component!")
	src.spawn_time = spawn_time
	src.spawn_types = spawn_types
	src.faction = faction
	src.spawn_text = spawn_text
	src.max_spawned = max_spawned
	src.spawn_callback = spawn_callback
	src.max_spawn_per_attempt = max_spawn_per_attempt
	src.spawn_distance = spawn_distance
	src.spawn_distance_exclude = spawn_distance_exclude
	// If set, doesn't instantly spawn a creature when the spawner component is applied.
	if(initial_spawn_delay)
		COOLDOWN_START(src, spawn_delay, spawn_time)

	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(stop_spawning))
	RegisterSignal(parent, COMSIG_VENT_WAVE_CONCLUDED, PROC_REF(stop_spawning))
	START_PROCESSING((spawn_time < 2 SECONDS ? SSfastprocess : SSprocessing), src)

/datum/component/spawner/process()
	try_spawn_mob()

/// Stop spawning mobs
/datum/component/spawner/proc/stop_spawning(force)
	SIGNAL_HANDLER

	STOP_PROCESSING(SSprocessing, src)
	spawned_things = list()

/// Try to create a new mob
/datum/component/spawner/proc/try_spawn_mob()
	if(!length(spawn_types))
		return
	if(!COOLDOWN_FINISHED(src, spawn_delay))
		return
	validate_references()
	var/spawned_total = length(spawned_things)
	if(spawned_total >= max_spawned)
		return
	var/atom/spawner = parent
	COOLDOWN_START(src, spawn_delay, spawn_time)
	var/chosen_mob_type = pick(spawn_types)
	var/adjusted_spawn_count = 1
	var/max_spawn_this_attempt = min(max_spawn_per_attempt, max_spawned - spawned_total)
	if (max_spawn_this_attempt > 1)
		adjusted_spawn_count = rand(1, max_spawn_this_attempt)
	for(var/i in 1 to adjusted_spawn_count)
		var/atom/created
		var/turf/picked_spot

		if(spawn_distance == 1)
			created = new chosen_mob_type(spawner.loc)
		else if(spawn_distance >= 1 && spawn_distance_exclude >= 1)
			picked_spot = pick(turf_peel(spawn_distance, spawn_distance_exclude, spawner.loc, view_based = TRUE))
			if(!picked_spot)
				picked_spot = pick(circle_range_turfs(spawner.loc, spawn_distance))
			if(picked_spot == spawner.loc)
				SEND_SIGNAL(spawner, COMSIG_SPAWNER_SPAWNED_DEFAULT)
			created = new chosen_mob_type(picked_spot)
		else if (spawn_distance >= 1)
			picked_spot = pick(circle_range_turfs(spawner.loc, spawn_distance))
			created = new chosen_mob_type(picked_spot)

		created.flags_1 |= (spawner.flags_1 & ADMIN_SPAWNED_1)
		spawned_things += WEAKREF(created)

		if (isliving(created))
			var/mob/living/created_mob = created
			created_mob.faction = src.faction
			RegisterSignal(created, COMSIG_MOB_STATCHANGE, PROC_REF(mob_stat_changed))

		SEND_SIGNAL(src, COMSIG_SPAWNER_SPAWNED, created)
		RegisterSignal(created, COMSIG_QDELETING, PROC_REF(on_deleted))
		spawn_callback?.Invoke(created)


	if (spawn_text)
		spawner.visible_message(span_danger("A creature [spawn_text] [spawner]."))



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
	if (source.stat != DEAD)
		return
	spawned_things -= WEAKREF(source)
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_MOB_STATCHANGE))
