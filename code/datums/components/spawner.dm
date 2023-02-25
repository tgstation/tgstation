/datum/component/spawner
	/// List of mob types to spawn, picked randomly
	var/mob_types = list(/mob/living/basic/carp)
	/// Time to wait between spawns
	var/spawn_time = 30 SECONDS
	/// List of weak references to we have already created
	var/list/spawned_mobs = list()
	/// Time until we next spawn
	COOLDOWN_DECLARE(spawn_delay)
	/// Maximum number of mobs we can have active at one time
	var/max_mobs = 5
	/// Visible message to show when a mob spawns
	var/spawn_text = "emerges from"
	/// Faction to grant to mobs
	var/list/faction = list("mining")

/datum/component/spawner/Initialize(_mob_types, _spawn_time, _faction, _spawn_text, _max_mobs)
	if(_spawn_time)
		spawn_time=_spawn_time
	if(_mob_types)
		mob_types=_mob_types
	if(_faction)
		faction=_faction
	if(_spawn_text)
		spawn_text=_spawn_text
	if(_max_mobs)
		max_mobs=_max_mobs

	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(stop_spawning))
	START_PROCESSING(SSprocessing, src)

/datum/component/spawner/process()
	try_spawn_mob()

/// Stop spawning mobs
/datum/component/spawner/proc/stop_spawning(force)
	SIGNAL_HANDLER

	STOP_PROCESSING(SSprocessing, src)=
	spawned_mobs = list()

/// Try to create a new mob
/datum/component/spawner/proc/try_spawn_mob()
	if(!COOLDOWN_FINISHED(spawn_delay))
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
