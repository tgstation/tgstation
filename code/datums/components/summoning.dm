/datum/component/summoning
	/// Types of mob we can create
	var/list/mob_types = list()
	/// Percentage chance to spawn a mob
	var/spawn_chance
	/// Maximum mobs we can have active at once
	var/max_mobs
	/// Cooldown between spawning mobs
	var/spawn_delay
	/// Text to display when spawning a mob
	var/spawn_text
	/// Sound to play when spawning a mob
	var/spawn_sound
	/// Factions to assign to a summoned mob
	var/list/faction
	/// Cooldown tracker for when we can summon another mob
	COOLDOWN_DECLARE(summon_cooldown)
	/// List containing all of our mobs
	var/list/spawned_mobs = list()

/datum/component/summoning/Initialize(
	mob_types,
	spawn_chance = 100,
	max_mobs = 3,
	spawn_delay = 10 SECONDS,
	spawn_text = "appears out of nowhere",
	spawn_sound = 'sound/effects/magic/summon_magic.ogg',
	list/faction,
)
	if(!isitem(parent) && !ishostile(parent) && !isgun(parent) && !ismachinery(parent) && !isstructure(parent) && !isprojectilespell(parent))
		return COMPONENT_INCOMPATIBLE

	src.mob_types = mob_types
	src.spawn_chance = spawn_chance
	src.max_mobs = max_mobs
	src.spawn_delay = spawn_delay
	src.spawn_text = spawn_text
	src.spawn_sound = spawn_sound
	src.faction = faction

/datum/component/summoning/RegisterWithParent()
	if(ismachinery(parent) || isstructure(parent) || isgun(parent) || isprojectilespell(parent)) // turrets, etc
		RegisterSignal(parent, COMSIG_PROJECTILE_ON_HIT, PROC_REF(projectile_hit))
	else if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(item_afterattack))
	else if(ishostile(parent))
		RegisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(hostile_attackingtarget))

/datum/component/summoning/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_AFTERATTACK, COMSIG_HOSTILE_POST_ATTACKINGTARGET, COMSIG_PROJECTILE_ON_HIT))

/datum/component/summoning/proc/item_afterattack(obj/item/source, atom/target, mob/user, list/modifiers)
	SIGNAL_HANDLER

	do_spawn_mob(get_turf(target), user)

/datum/component/summoning/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return
	do_spawn_mob(get_turf(target), attacker)

/datum/component/summoning/proc/projectile_hit(datum/fired_from, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	do_spawn_mob(get_turf(target), firer)

/datum/component/summoning/proc/do_spawn_mob(atom/spawn_location, summoner)
	if(length(spawned_mobs) >= max_mobs || !COOLDOWN_FINISHED(src, summon_cooldown) || !prob(spawn_chance))
		return
	COOLDOWN_START(src, summon_cooldown, spawn_delay)
	var/chosen_mob_type = pick(mob_types)
	var/mob/living/summoned = new chosen_mob_type(spawn_location)
	if(ishostile(summoned))
		var/mob/living/simple_animal/hostile/angry_boy = summoned
		angry_boy.friends |= summoner // do not attack our summon boy
	spawned_mobs |= summoned
	if(faction != null)
		summoned.faction = faction.Copy()
	RegisterSignals(summoned, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_spawned_death))
	spawn_location.visible_message(span_danger("[summoned] [spawn_text]!"))

/// When a spawned thing dies, remove it from our list
/datum/component/summoning/proc/on_spawned_death(mob/killed, gibbed)
	SIGNAL_HANDLER
	UnregisterSignal(killed, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING))
	spawned_mobs -= killed
