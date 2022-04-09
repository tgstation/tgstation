
/**
 * ## Teleport Spell
 *
 * Teleports the caster to a turf selected by get_destination().
 */
/datum/action/cooldown/spell/teleport
	sound = 'sound/weapons/zapbang.ogg'

	school = SCHOOL_TRANSLOCATION

	/// Whether we force the teleport to happen (ie, it cannot be blocked by noteleport areas or blessings or whatever)
	var/force_teleport = FALSE
	/// A list of flags related to determining if our destination target is valid or not.
	var/destination_flags = NONE
	/// The sound played on arrival, after the teleport.
	var/post_teleport_sound = 'sound/weapons/zapbang.ogg'

/datum/action/cooldown/spell/teleport/New(Target)
	. = ..()
	// Teleporting out of jaunts or as a non-abstract entity is always a bad idea
	spell_requirements |= (SPELL_REQUIRES_NON_ABSTRACT|SPELL_REQUIRES_UNPHASED)

/datum/action/cooldown/spell/teleport/cast(atom/cast_on)
	. = ..()
	var/turf/destination = get_destination(cast_on)
	if(!destination)
		CRASH("[type] failed to find a teleport destination.")

	do_teleport(cast_on, destination, asoundout = post_teleport_sound, channel = TELEPORT_CHANNEL_MAGIC, forced = force_teleport)

/datum/action/cooldown/spell/teleport/proc/get_destination(atom/center)
	CRASH("[type] did not implement get_destination and either has no effects or implemented the spell incorrectly.")


/**
 * ###  Radius Teleport Spell
 *
 * A subtype of teleport that will teleport the caster
 * to a random turf within a radius of themselves.
 */
/datum/action/cooldown/spell/teleport/radius_turf
	/// The inner radius around the caster that we can teleport to
	var/inner_tele_radius = 1
	/// The outer radius around the caster that we can teleport to
	var/outer_tele_radius = 2

/datum/action/cooldown/spell/teleport/radius_turf/get_destination(atom/center)
	var/list/valid_turfs = list()
	var/list/possibles = RANGE_TURFS(outer_tele_radius, center)
	if(inner_tele_radius > 0)
		possibles -= RANGE_TURFS(inner_tele_radius, center)

	for(var/turf/nearby_turf as anything in possibles)
		if(isspaceturf(nearby_turf) && (destination_flags & TELEPORT_SPELL_SKIP_SPACE))
			continue
		if(nearby_turf.density && (destination_flags & TELEPORT_SPELL_SKIP_DENSE))
			continue
		if(nearby_turf.is_blocked_turf(exclude_mobs = TRUE) && (destination_flags & TELEPORT_SPELL_SKIP_BLOCKED))
			continue

		if(nearby_turf.x > world.maxx - outer_tele_radius || nearby_turf.x < outer_tele_radius)
			continue //putting them at the edge is dumb
		if(nearby_turf.y > world.maxy - outer_tele_radius || nearby_turf.y < outer_tele_radius)
			continue
		valid_turfs += nearby_turf

	var/turf/picked_turf = length(valid_turfs) ? pick(valid_turfs) : pick(possibles)
	if(!istype(picked_turf))
		return

	return picked_turf

/datum/action/cooldown/spell/teleport/area_teleport
	force_teleport = TRUE
	destination_flags = TELEPORT_SPELL_SKIP_BLOCKED
	/// The last area we chose to teleport / where we're currently teleporting to, if mid-cast
	var/last_chosen_area_name
	/// If TRUE, the caster can select the destination area. Otherwise, random selection.
	var/randomise_selection = FALSE
	/// If the invocation appends the selected area when said. Requires invocation mode shout or whisper.
	var/invocation_says_area = TRUE

/datum/action/cooldown/spell/teleport/area_teleport/get_destination(atom/center)
	var/list/valid_turfs = list()
	for(var/turf/possible_destination as anything in get_area_turfs(GLOB.teleportlocs[last_chosen_area_name]))
		if(isspaceturf(possible_destination) && (destination_flags & TELEPORT_SPELL_SKIP_SPACE))
			continue
		if(possible_destination.density && (destination_flags & TELEPORT_SPELL_SKIP_DENSE))
			continue
		if(possible_destination.is_blocked_turf(exclude_mobs = TRUE) && (destination_flags & TELEPORT_SPELL_SKIP_BLOCKED))
			continue

		valid_turfs += possible_destination

	if(!length(valid_turfs))
		return

	return pick(valid_turfs)

/datum/action/cooldown/spell/teleport/area_teleport/before_cast(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	var/area/target_area
	if(randomise_selection)
		target_area = pick(GLOB.teleportlocs)
	else
		target_area = tgui_input_list(cast_on, "Chose an area to teleport to.", "Teleport", GLOB.teleportlocs)

	if(QDELETED(src) || QDELETED(cast_on) || !can_cast_spell(feedback = FALSE))
		return FALSE
	if(!target_area || isnull(GLOB.teleportlocs[target_area]))
		return FALSE

	last_chosen_area_name = target_area
	return TRUE

/datum/action/cooldown/spell/teleport/area_teleport/cast(atom/cast_on)
	if(isliving(cast_on))
		var/mob/living/living_cast_on = cast_on
		living_cast_on.buckled?.unbuckle_mob(cast_on, force = TRUE)
	return ..()

/datum/action/cooldown/spell/teleport/area_teleport/invocation()
	var/area/last_chosen_area = GLOB.teleportlocs[last_chosen_area_name]

	if(!invocation_says_area || isnull(last_chosen_area))
		return ..()

	switch(invocation_type)
		if(INVOCATION_SHOUT)
			owner.say("[invocation], [uppertext(last_chosen_area.name)]!", forced = "spell ([src])")
		if(INVOCATION_WHISPER)
			owner.whisper("[invocation], [uppertext(last_chosen_area.name)].")
