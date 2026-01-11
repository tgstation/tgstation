/// Element that grants an achievement to all mobs who killed the owner when it dies
/datum/element/kill_achievement
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Achievements to grant when killed
	var/list/achievement_types = null
	/// Achievement to grant when killed with a crusher
	var/crusher_achievement_type = null
	/// A memory to grant to killers, if any
	var/kill_memory_type = null
	/// Range in which to grant the achievement
	var/achievement_range = 7
	/// Threshold for damage dealt with a crusher to count it as a crusher kill
	/// If null, then no kill counts as a crusher kill
	var/crusher_kill_threshold = 0.6
	/// Blackbox tally string to record kills into
	var/tally_string = "megafauna_kills"

/datum/element/kill_achievement/Attach(datum/target, list/achievement_types, crusher_achievement_type, kill_memory_type, achievement_range = 7, crusher_kill_threshold = 0.6, tally_string = "megafauna_kills")
	. = ..()
	if (!isliving(target) || !length(achievement_types))
		return ELEMENT_INCOMPATIBLE
	src.achievement_types = achievement_types
	src.crusher_achievement_type = crusher_achievement_type
	src.kill_memory_type = kill_memory_type
	src.achievement_range = achievement_range
	src.crusher_kill_threshold = crusher_kill_threshold
	src.tally_string = tally_string
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/element/kill_achievement/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_LIVING_DEATH)

/datum/element/kill_achievement/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER

	if ((source.flags_1 & ADMIN_SPAWNED_1) || !SSachievements.achievements_enabled)
		return

	// Check whether we killed the megafauna with primarily crusher damage or not
	var/datum/status_effect/crusher_damage/crusher_dmg = source.has_status_effect(/datum/status_effect/crusher_damage)
	var/crusher_kill = (!isnull(crusher_kill_threshold) && crusher_dmg && (crusher_dmg.total_damage >= floor(source.maxHealth * 0.6)))
	var/turf/our_loc = get_turf(source)
	if (!our_loc)
		return

	for (var/mob/living/player in SSmobs.clients_by_zlevel[our_loc.z])
		var/turf/player_turf = get_turf(player)
		if (player.stat || get_dist(player_turf, source) > achievement_range)
			continue

		for (var/achievement_type in achievement_types)
			player.client.give_award(achievement_type, player)

		if (kill_memory_type)
			player.add_mob_memory(kill_memory_type, antagonist = source)

		if(crusher_kill && crusher_achievement_type && istype(player.get_active_held_item(), /obj/item/kinetic_crusher))
			player.client.give_award(crusher_achievement_type, player)

	SSblackbox.record_feedback("tally", "[tally_string][crusher_kill ? "_crusher" : ""]", 1, "[initial(source.name)]")
