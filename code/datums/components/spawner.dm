/datum/component/spawner
	/// Time to wait between spawns
	var/spawn_time
	/// Maximum number of mobs we can have active at one time
	var/max_mobs
	/// Visible message to show when a mob spawns
	var/spawn_text
	/// List of mob types to spawn, picked randomly
	var/list/mob_types
	/// Faction to grant to mobs
	var/list/faction
	/// List of weak references to mobs we have already created
	var/list/spawned_mobs = list()
	/// Time until we next spawn
	COOLDOWN_DECLARE(spawn_delay)

/datum/component/spawner/Initialize(mob_types = list(), spawn_time = 30 SECONDS, max_mobs = 5, faction = list(FACTION_MINING), spawn_text = "emerges from")
	if (!length(mob_types))
		CRASH("No types of mob to spawn specified for spawner component!")
	src.spawn_time = spawn_time
	src.mob_types = mob_types
	src.faction = faction
	src.spawn_text = spawn_text
	src.max_mobs = max_mobs

	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(stop_spawning))
	START_PROCESSING(SSprocessing, src)

/datum/component/spawner/process()
	try_spawn_mob()

/// Stop spawning mobs
/datum/component/spawner/proc/stop_spawning(force)
	SIGNAL_HANDLER

	STOP_PROCESSING(SSprocessing, src)
	spawned_mobs = list()

/// Try to create a new mob
/datum/component/spawner/proc/try_spawn_mob()
	if(!COOLDOWN_FINISHED(src, spawn_delay))
		return
	validate_references()
	if(length(spawned_mobs) >= max_mobs)
		return
	var/atom/spawner = parent
	COOLDOWN_START(src, spawn_delay, spawn_time)

	var/chosen_mob_type = pick(mob_types)
	var/mob/living/created = new chosen_mob_type(spawner.loc)
	created.flags_1 |= (spawner.flags_1 & ADMIN_SPAWNED_1)
	spawned_mobs += WEAKREF(created)
	created.faction = src.faction
	spawner.visible_message(span_danger("[created] [spawn_text] [spawner]."))

	RegisterSignal(created, COMSIG_PARENT_QDELETING, PROC_REF(mob_deleted))
	RegisterSignal(created, COMSIG_MOB_STATCHANGE, PROC_REF(mob_stat_changed))

/// Remove weakrefs to mobs which have been killed or deleted without us picking it up somehow
/datum/component/spawner/proc/validate_references()
	for (var/datum/weakref/weak_mob as anything in spawned_mobs)
		var/mob/living/previously_spawned = weak_mob.resolve()
		if (previously_spawned && previously_spawned.stat != DEAD)
			continue
		spawned_mobs -= weak_mob

/// Called when a mob we spawned is deleted, remove it from the list
/datum/component/spawner/proc/mob_deleted(mob/living/source)
	SIGNAL_HANDLER
	spawned_mobs -= WEAKREF(source)

/// Called when a mob we spawned dies, remove it from the list and unregister signals
/datum/component/spawner/proc/mob_stat_changed(mob/living/source)
	if (source.stat != DEAD)
		return
	spawned_mobs -= WEAKREF(source)
	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_STATCHANGE))
